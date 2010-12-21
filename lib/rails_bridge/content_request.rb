require 'uri'

module RailsBridge
  class ContentRequest
    attr_accessor :default_content, :protocol, :host, :port, :path, :params, :url
    
    DEFAULT_CONTENT = 'Remote Content Unavailable'
    
    # Options:
    # * :default_content - Content to be returned in test mode or when the remote server is unavailable
    # * :protocol - Protocol of remote server (http|https).  Default is 'http'
    # * :host - Host of remote server.  
    # * :port - Port of remote server.  Default is 80.
    # * :path - Path for remote request.  Default is '/'
    # * :params - URL query params for remote request.  
    # * :url - Explicit URL for remote request.
    #     if the :url option is passed, the :protocol, :host, :port, :path, and :params options are ignored
    def initialize options={}
      if options[:url]
        self.protocol = uri.scheme
        self.host = uri.host
        self.port = uri.port
        self.path = uri.path
        self.params = uri.queruy
      else
        self.protocol = options[:protocol] || 'http'
        self.host = options[:host]
        self.port = options[:port] || 80
        self.path = options[:path] || '/'
        self.params = options[:params]
      end
      self.default_content = options[:default_content] || DEFAULT_CONTENT
    end
    
    def url
      query = self.params ? self.params.keys.map{|k| "#{k}=#{self.params[k]}"}.join('&') : nil
      URI::Generic.new( self.protocol, nil, self.host, self.port, nil, self.path, nil, query, nil ).to_s
    end
  end
end
