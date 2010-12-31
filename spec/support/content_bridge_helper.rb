module ContentBridgeSpecHelper
  DEFAULT_RETURN_DATA = "RETURN DATA"
  
  TEST_SERVER_PORT=1234
  
  DEFAULT_REQUEST_VALUES = {
    :protocol => 'http', 
    :host => 'localhost', 
    :port => TEST_SERVER_PORT, 
    :path => '/path', 
    :params => {:return_data=>DEFAULT_RETURN_DATA}, 
    :default_content => 'Request Default Content',
    :cache_timeout => 0
  }

  class ContentBridgeTest < RailsBridge::ContentBridge
    content_request :chang do |request|
      request.protocol = DEFAULT_REQUEST_VALUES[:protocol]
      request.host = DEFAULT_REQUEST_VALUES[:host]
      request.port = DEFAULT_REQUEST_VALUES[:port]
      request.path = DEFAULT_REQUEST_VALUES[:path]
      request.params = DEFAULT_REQUEST_VALUES[:params]
      request.default_content = DEFAULT_REQUEST_VALUES[:default_content]
    end
  end
end