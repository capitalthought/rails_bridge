require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe RailsBridge::ContentBridge do
  
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
  
  describe "without test server running" do
    
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
  
  describe "with test server running" do

    before(:each) do 
      ContentBridgeTest.request_timeout = 2000
      TestServer.startup(TEST_SERVER_PORT)
    end

    after(:each) do
      TestServer.shutdown
    end
    
    it "verify the TestServer is running" do
      response = Typhoeus::Request.get("http://localhost:#{TEST_SERVER_PORT}/hi?return_data=verified")
      response.body.should == 'verified'
    end
    
    it ":get_remote_content fetches by explicit URL" do
      ContentBridgeTest.get_remote_content("http://localhost:#{TEST_SERVER_PORT}/")
    end
    
    it "fetches the server's content" do
      ContentBridgeTest.get_chang.should == DEFAULT_RETURN_DATA
    end

    it "honors the bridge's request_timeout on a hung connection" do
      cbt = ContentBridgeTest
      wang = ContentBridgeTest.content_requests[:chang].dup
      wang.params = wang.params.merge(:sleep=>2)
      cbt.content_requests[:wang] = wang
      cbt.request_timeout = 10
      cbt.get_wang().should == wang.default_content
    end

    it "honors the request's request_timeout on a hung connection" do
      cbt = ContentBridgeTest
      cbt.request_timeout = 4000
      cbt.get_chang(:params=>{:sleep=>20},:request_timeout=>10).should == cbt.content_requests[:chang].default_content
    end
    
    it "does not cache a request's content when the cache_timeout is 0 or nil" do
      cbt = ContentBridgeTest
      cbt.get_chang(:cache_timeout=>0).should == DEFAULT_RETURN_DATA
      TestServer.shutdown
      cbt.get_chang(:cache_timeout=>0,:request_timeout=>10).should == cbt.content_requests[:chang].default_content
      TestServer.startup(TEST_SERVER_PORT)
      cbt.get_chang(:cache_timeout=>0).should == DEFAULT_RETURN_DATA
      TestServer.shutdown
      cbt.get_chang(:cache_timeout=>0,:request_timeout=>10).should == cbt.content_requests[:chang].default_content
    end

    it "caches a request's content when the cache_timeout is > 0" do
      unique = __LINE__
      cbt = ContentBridgeTest
      chang = cbt.content_requests[:chang]
      cbt.get_chang(:cache_timeout=>60,:params=>chang.params.merge(:unique=>unique)).should == DEFAULT_RETURN_DATA
      TestServer.shutdown
      cbt.get_chang(:cache_timeout=>60,:params=>chang.params.merge(:unique=>unique)).should == DEFAULT_RETURN_DATA
    end

    it "the cache expires correctly" do
      unique = __LINE__
      cbt = ContentBridgeTest
      chang = cbt.content_requests[:chang]
      cbt.get_chang(:cache_timeout=>2,:params=>chang.params.merge(:unique=>unique)).should == DEFAULT_RETURN_DATA
      TestServer.shutdown
      cbt.get_chang(:cache_timeout=>2,:params=>chang.params.merge(:unique=>unique)).should == DEFAULT_RETURN_DATA
      sleep 2
      cbt.get_chang(:cache_timeout=>2,:params=>chang.params.merge(:unique=>unique)).should == cbt.content_requests[:chang].default_content
    end
  end
  
end
