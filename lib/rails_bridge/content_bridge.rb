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
    class_inheritable_accessor :cache, :logger, :on_success
    @@content_requests = {}
        
    # Initialize Default Class Attribute Values
    self.request_timeout = DEFAULT_REQUEST_TIMEOUT
    self.cache_timeout = DEFAULT_CACHE_TIMEOUT
    self.default_content = DEFAULT_CONTENT    
    self.cache = nil
    self.logger = Logger.new(File.open("/dev/null", 'w'))
    
    
    class << self
      # custom accessor methods
      def content_requests; @@content_requests; end

      alias :cia_on_sucess :on_success
      def on_success
        if block_given?
          self.on_success= Proc.new
        else
          self.cia_on_sucess
        end
      end
        
      def cache_set key, content, expires_in
        logger.debug "set key: #{key}"
        self.cache.write( key, content, :expires_in=>expires_in )
      end
      
      def cache_get key
        logger.debug "get key: #{key}"
        content = self.cache.fetch(key, :race_condition_ttl=>5.seconds)
      end
      
      def get_content_request_from_remote( remote )
        if remote.is_a? Symbol
          raise "Undefined content_request :#{remote}" unless remote = @@content_requests[remote]
        end
        if remote.is_a? Hash
          remote = RailsBridge::ContentRequest.new remote
          remote.content_bridge = self
        elsif remote.is_a? String
          remote = RailsBridge::ContentRequest.new(:url=>remote)
          remote.content_bridge = self
        elsif !remote.is_a? RailsBridge::ContentRequest
          raise "Unexpected remote type: #{remote.class}"
        end
        remote
      end
      
      # collect options by precedence
      def get_merged_options( content_request, options )
        options[:params]          =   content_request.params.merge( options[:params] || {} )
        options[:request_timeout] ||= content_request.request_timeout || self.request_timeout
        options[:cache_timeout]   ||= content_request.cache_timeout || self.cache_timeout
        options[:on_success]      ||= content_request.on_success || self.on_success
        options[:default_content] ||= content_request.default_content || self.default_content
        options
      end
      
      def request_remote_content( remote, options={}, &block )
        content_request = get_content_request_from_remote( remote )
        options = get_merged_options( content_request, options )
        
        # convert options for Typhoeus
        options[:timeout] =   options.delete(:request_timeout)  # Rename the request timeout param for Typhoeus
        on_success_proc = options.delete(:on_success)
        default_content = options.delete(:default_content)
        
        # options[:verbose] = true # for debugging only

        request = Typhoeus::Request.new(content_request.url, options)
        if self.cache && request.cache_timeout && request.cache_timeout > 0 && result = cache_get( request.cache_key )
          block.call(result)
        else
          result = default_content
          request.on_complete do |response|
            case response.code
            when 200
              result = response.body
              result = on_success_proc.call(result) if on_success_proc
              cache_set( request.cache_key, result, request.cache_timeout ) if self.cache && request.cache_timeout && request.cache_timeout > 0
              logger.debug "ContentBridge : Request Succeeded - Content: #{result}"
            when 0
              logger.warn "ContentBridge : Request Timeout for #{content_request.url}"
            else
              logger.warn "ContentBridge : Request for #{content_request.url}\mRequest Failed with HTTP result code: #{response.code}\n#{response.body}"
            end
            block.call(result)
          end
          hydra = Typhoeus::Hydra.hydra # the singleton Hydra
          hydra.disable_memoization
          hydra.queue request
        end
        nil
      end
      
      def execute_requests
        hydra = Typhoeus::Hydra.hydra # the singleton Hydra
        hydra.run
      end
      
      def get_remote_content( remote, options={} )
        result = nil
        request_remote_content( remote, options ) do |r_result|
          result = r_result
        end
        execute_requests
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
      
      def method_missing method, *args, &block
        if matches = method.to_s.match( /^get_(.*)$/ )
          request_name = matches[1]
          self.get_remote_content( request_name.to_sym, *args )
        elsif matches = method.to_s.match( /^request_(.*)$/ )
          request_name = matches[1]
          self.request_remote_content( request_name.to_sym, *args, &block )
        else
          super
        end
      end
      
    end
    
  end
end