require 'typhoeus'

module RailsBridge
  # = ContentBridge
  # 
  # An abstraction for embedding content from a remote application within a Rails request.
  class ContentBridge
    
    # Class Constants
    DEFAULT_CONTENT = 'Remote Content Unavailable'
    DEFAULT_REQUEST_TIMEOUT = 2000 # miliseconds
    DEFAULT_CACHE_TIMEOUT = 0

    # Class Attributes
    class_inheritable_accessor :protocol, :host, :port, :request_timeout, :cache_timeout, :default_content
    @@content_requests = {}
    @@cache = nil
    @@logger = Logger.new(STDOUT)
        
    # Initialize Default Class Attribute Values
    self.request_timeout = DEFAULT_REQUEST_TIMEOUT
    self.cache_timeout = DEFAULT_CACHE_TIMEOUT
    self.default_content = DEFAULT_CONTENT    
    
    
    class << self
      # custom accessor methods
      def content_requests; @@content_requests; end
      def logger; @@logger; end
      def logger=(logger); @@logger=logger; end
      def cache; @@cache; end
      def cache=(cache); @@cache=cache; end
        
      def cache_set key, body, time_to_live
        if time_to_live && time_to_live > 0
          expire_time = Time.now + time_to_live
          cache_envelope = {
            :body => body,
            :expire_time => expire_time
          }
          @@cache.write( key, cache_envelope )
        else
          @@cache.delete(key)
        end
      end
      
      def cache_get key
        cache_envelope = @@cache.read(key)
        body = if cache_envelope
          if cache_envelope[:expire_time] > Time.now
            cache_envelope[:body]
          else
            @@cache.delete(key)
            nil
          end
        else
          nil
        end
        body
      end

      
      def get_remote_content( remote, options={} )
        hydra = Typhoeus::Hydra.hydra # the singleton Hydra
        hydra.disable_memoization
        if remote.is_a? Symbol
          raise "Undefined content_request :#{remote}" unless remote = @@content_requests[remote]
        end
        if remote.is_a? RailsBridge::ContentRequest
          content_request = remote
          remote_url = content_request.url
          options[:params] ||= content_request.params
          options[:request_timeout] ||= content_request.request_timeout
          options[:cache_timeout] ||= content_request.cache_timeout
          options[:default_content] ||= content_request.default_content
        else
          remote_url = remote
        end
        options[:request_timeout] ||= self.request_timeout
        options[:cache_timeout] ||= self.cache_timeout
        options[:timeout] = options.delete(:request_timeout)  # Rename the request timeout param for Typhoeus
        default_content = options.delete(:default_content) || self.default_content
        # options[:verbose] = true # for debugging only
        
        request = Typhoeus::Request.new(remote_url, options)
        unless @@cache && result = cache_get( request.cache_key )
          result = default_content
          request.on_complete do |response|
            case response.code
            when 200
              result = response.body
              cache_set( request.cache_key, result, request.cache_timeout ) if @@cache && request.cache_timeout && request.cache_timeout > 0
              logger.debug "ContentBridge : Request Received Content: #{result}"
            when 0
              logger.error "ContentBridge : Request Timeout for #{remote_url}"
            else
              logger.error "ContentBridge : Request for #{remote_url}\mRequest Failed with HTTP result code: #{response.code}\n#{response.body}"
            end        
          end
          hydra.queue request
          hydra.run # this is a blocking call that returns once all requests are complete
        end
        result
      end
      
      def content_request name, options={}
        raise "name must be a symbol" unless name.is_a? Symbol
        begin
          raise "WARNING: Already defined content_request '#{name}'" if @@content_requests.key?( name )
        rescue
          logger.warning $!.message
          logger.warning $!.backtrace * "\n"
        end
        new_request = ContentRequest.new options
        yield new_request
        @@content_requests[name] = new_request
        new_request.content_bridge = self
        new_request
      end
      
      def method_missing method, *args
        if matches = method.to_s.match( /^get_(.*)$/ )
          request_name = matches[1]
          self.get_remote_content( request_name.to_sym, *args )
        else
          super
        end
      end
      
    end
    
  end
end