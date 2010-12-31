require File.join(File.dirname(__FILE__),'..','spec_helper')

describe RailsBridge::ContentBridge do

  include ContentBridgeSpecHelper
  
  before(:all) do
    ContentBridgeTest.request_timeout = 1
  end
  
  after(:all) do
    ContentBridgeTest.request_timeout = 1000
  end
  
  it "requires content_bridge name to be a symbol", :focus=>false do
    lambda {
      ContentBridgeTest.content_request 'name'
    }.should raise_error RuntimeError
  end

  it "allows block level setting of defined content request's attributes ", :focus=>false do
    request = ContentBridgeTest.content_requests[:chang]
    request.protocol.should == DEFAULT_REQUEST_VALUES[:protocol]
    request.host.should == DEFAULT_REQUEST_VALUES[:host]
    request.port.should == DEFAULT_REQUEST_VALUES[:port]
    request.params.should == DEFAULT_REQUEST_VALUES[:params]
    request.default_content.should == DEFAULT_REQUEST_VALUES[:default_content]
  end

  it "automatically defines method for content_request", :focus=>false do
      lambda{ContentBridgeTest.get_chang}.should_not raise_error Exception
  end

  it "returns request's default content when defined", :focus=>false do
    ContentBridgeTest.get_chang.should == DEFAULT_REQUEST_VALUES[:default_content]
  end

  it "returns bridge's default content when request's is undefined", :focus=>false do
    ContentBridgeTest.content_requests[:chang].default_content = nil
    ContentBridgeTest.get_chang.should == ContentBridgeTest.default_content
    ContentBridgeTest.content_requests[:chang].default_content = DEFAULT_REQUEST_VALUES[:default_content]
  end

  it "request options can be overriden at request time", :focus=>false do
    ContentBridgeTest.get_chang(:default_content=>"YADA YADA").should == "YADA YADA"
  end

  it "subclassing a ContentBridge does not change parent class' attributes", :focus=>false do
    class ContentBridgeTest2 < ContentBridgeTest
      self.default_content = "Some other content."
    end
    ContentBridgeTest2.default_content.should == "Some other content."
    ContentBridgeTest.content_requests[:chang].default_content = nil
    ContentBridgeTest.get_chang.should == ContentBridgeTest.default_content
    ContentBridgeTest2.get_chang.should == "Some other content."
    ContentBridgeTest.content_requests[:chang].default_content = DEFAULT_REQUEST_VALUES[:default_content]
  end

end
