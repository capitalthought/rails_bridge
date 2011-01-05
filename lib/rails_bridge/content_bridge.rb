require 'typhoeus'
require 'active_support/core_ext/logger'

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
    class_inheritable_accessor :protocol, :host, :port, :path, :params, :request_timeout, :cache_timeout, :default_content
    class_inheritable_accessor :cache, :logger
    @@content_requests = {}
    @@on_success = nil
        
    # Initialize Default Class Attribute Values
    self.request_timeout = DEFAULT_REQUEST_TIMEOUT
    self.cache_timeout = DEFAULT_CACHE_TIMEOUT
    self.default_content = DEFAULT_CONTENT    
    self.cache = nil
    self.logger = Logger.new(File.open("/dev/null", 'w'))
    
    
    class << self
      # custom accessor methods
      def content_requests; @@content_requests; end

      def on_success
        if block_given?
          @@on_success = Proc.new
        else
          @@on_success
        end
      end

      def on_success=(proc)
        @@on_success = proc
      end

        
      def cache_set key, content, expires_in
        logger.debug "set key: #{key}"
        self.cache.write( key, content, :expires_in=>expires_in )
      end
      
      def cache_get key
        logger.debug "get key: #{key}"
        content = self.cache.fetch(key, :race_condition_ttl=>5.seconds)
      end
      
      def process_remote_and_options( remote, options )
        if remote.is_a? Symbol
          raise "Undefined content_request :#{remote}" unless remote = @@content_requests[remote]
        end
        if remote.is_a? Hash
          remote = RailsBridge::ContentRequest.new remote
          remote.content_bridge = self
        end
        if remote.is_a? RailsBridge::ContentRequest
          content_request = remote
          remote_url = content_request.url
          options[:params] = content_request.params.merge( options[:params] || {} )
          options[:request_timeout] ||= content_request.request_timeout
          options[:cache_timeout] ||= content_request.cache_timeout
          options[:default_content] ||= content_request.default_content
          on_success = content_request.on_success
        else
          remote_url = remote
          on_sucess = nil
        end
        options[:request_timeout] ||= self.request_timeout
        options[:cache_timeout] ||= self.cache_timeout
        options[:timeout] = options.delete(:request_timeout)  # Rename the request timeout param for Typhoeus
        [remote_url, options]
      end
      
      def get_remote_content( remote, options={} )
        hydra = Typhoeus::Hydra.hydra # the singleton Hydra
        hydra.disable_memoization
        remote_url, options = process_remote_and_options( remote, options )
        default_content = options.delete(:default_content) || self.default_content
        # options[:verbose] = true # for debugging only
        request = Typhoeus::Request.new(remote_url, options)
        unless self.cache && request.cache_timeout && request.cache_timeout > 0 && result = cache_get( request.cache_key )
          result = default_content
          request.on_complete do |response|
            case response.code
            when 200
              if on_success
                result = on_success.call(response.body)
              else
                result = response.body
              end
              cache_set( request.cache_key, result, request.cache_timeout ) if self.cache && request.cache_timeout && request.cache_timeout > 0
              logger.debug "ContentBridge : Request Succeeded - Content: #{result}"
            when 0
              logger.warn "ContentBridge : Request Timeout for #{remote_url}"
            else
              logger.warn "ContentBridge : Request for #{remote_url}\mRequest Failed with HTTP result code: #{response.code}\n#{response.body}"
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
          logger.warn $!.message
          logger.warn $!.backtrace * "\n"
        end
        new_request = ContentRequest.new options
        yield new_request if block_given?
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