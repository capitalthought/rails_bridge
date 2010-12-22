require 'uri'

module RailsBridge
  class ContentRequest
    attr_accessor :default_content, :request_timeout, :cache_timeout, :protocol, :host, :port, :path, :params, :url, :content_bridge
    
    # Options:
    # * :default_content - Content to be returned in test mode or when the remote server is unavailable
    # * :request_timeout - Maximum time to wait for successful response in ms
    # * :cache_timeout - TTL expiry for cache in seconds - nil or 0 will prevent caching
    # * :protocol - Protocol of remote server (http|https).  Default is 'http'
    # * :host - Host of remote server.  
    # * :port - Port of remote server.  Default is 80.
    # * :path - Path for remote request.  Default is '/'
    # * :params - URL query params for remote request.  
    # * :fragment - URL part after the '#' for remote request.
    # * :url - Explicit URL for remote request.
    #     if the :url option is passed, the :protocol, :host, :port, :path, :params, and :fragment options are ignored
    def initialize options={}
      if url = options[:url]
        uri = URI.parse( url )
        self.protocol = uri.scheme
        self.host = uri.host
        self.port = uri.port
        self.path = uri.path
        self.params = extract_query_params( uri.query )
      else
        self.protocol = options[:protocol] || 'http'
        self.host = options[:host]
        self.port = options[:port] || 80
        self.path = options[:path] || '/'
        self.params = options[:params]
      end
      self.default_content = options[:default_content]
      self.request_timeout = options[:request_timeout]
      self.cache_timeout = options[:cache_timeout]
    end
    
    # We don't include the params in the URL, because Typhoeus::Request takes them as a separate argument
    def url
      # query = self.params ? encode_query_params( self.params ) : nil
      URI::Generic.new( self.protocol, nil, self.host, self.port, nil, self.path, nil, nil, nil, true ).to_s
    end
    
    def get_remote_content( options={} )
      if self.content_bridge
        self.content_bridge.get_remote_content( self, options )
      else
        RailsBridge::ContentBridge.get_remote_content( self, options )
      end
    end
    
    private 
     def extract_query_params query
       query = CGI::unescape( query )
       pairs = query.split("&")
       params = pairs.inject({}){|hash, pair| k,v=pair.split('='); v.nil? ? hash : (hash[k.to_sym]=v;hash)}
       params.keys.empty? ? nil : params
     end
     
     def encode_query_params params
       params = escape_query_params( params )
       params.keys.map{|k| "#{k}=#{params[k]}"}.join('&')
     end
     
     def escape_query_params params
       return unless params
       new_params = {}
       params.each do |k,v|
         new_params[k] = CGI::escape( v.to_s )
       end
       new_params
     end
      
  end
end
