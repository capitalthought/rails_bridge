require 'typhoeus'

module RailsBridge
  # = ContentBridge
  # 
  # An abstraction for embedding content from a remote application within a Rails request.
  class ContentBridge
    
    class_inheritable_accessor :protocol, :hostname, :port
    
    def initialize
    end
    
    def method_missing( method, *args )
      super
    end
    
    class << self
      def get_remote_content( remote_path, options={} )
        hydra = Typhoeus::Hydra.new
        request = Typhoeus::Request.new(remote_path)
        result = nil
        request.on_complete do |response|
          result = response.body
        end
        hydra.queue request
        hydra.queue request
        hydra.run # this is a blocking call that returns once all requests are complete
        result
      end
    end
    
  end
end