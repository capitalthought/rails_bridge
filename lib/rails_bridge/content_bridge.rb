require 'typhoeus'

module RailsBridge
  # = ContentBridge
  # 
  # An abstraction for embedding content from a remote application within a Rails request.
  class ContentBridge
    
    class_inheritable_accessor :protocol, :host, :port, :request_timeout, :cache_timeout, :content_requests
    
    request_timeout = 1000 # miliseconds
    
    @@content_requests = {}
    
    def initialize
    end
    
    def method_missing( method, *args )
      super
    end
    
    class << self
      def get_remote_content( remote, options={} )
        hydra = Typhoeus::Hydra.new
        if remote.is_a? Symbol
          content_request = @@content_requests[remote]
          raise "Undefined content_request :#{remote}" unless content_request
          remote_url = content_request.url
        else
          remote_url = remote
        end
        puts "remote_url: #{remote_url}"
        request = Typhoeus::Request.new(remote_url, 
          :timeout => self.request_timeout
        )
        result = nil
        request.on_complete do |response|
          result = response.body
        end
        hydra.queue request
        hydra.run # this is a blocking call that returns once all requests are complete
        result
      end
      
      def content_request name, options={}
        raise "name must be a symbol" unless name.is_a? Symbol
        begin
          raise "WARNING: Already defined content_request '#{name}'" if @@content_requests.key?( name )
        rescue
          puts $!.message
          puts $!.backtrace * "\n"
        end
        new_request = ContentRequest.new options
        yield new_request
        @@content_requests[name] = new_request
      end
      
      def method_missing method, *args
        if matches = method.to_s.match( /^get_(.*)$/ )
          request_name = matches[1]
          self.get_remote_content( request_name.to_sym, *args )
        end
      end
      
    end
    
  end
end