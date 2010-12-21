require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe RailsBridge::ContentBridge do
  class ContentBridgeTest < RailsBridge::ContentBridge
    content_request :chang do |request|
      request.protocol = 'http'
      request.host = 'locahost'
      request.port = 3000
      request.path = '/'
      request.params = {}
      request.default_content = "Chang's Default Content"
    end
  end
  
  it "requires content_bridge name to be a symbol", :focus=>true do
    lambda {
      class ContentBridgeTest < RailsBridge::ContentBridge
        content_request 'name'
      end
    }.should raise_error RuntimeError
  end

  it "defines method for content_request", :focus=>true do
      ContentBridgeTest.get_chang
  end
end
