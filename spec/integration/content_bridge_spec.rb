require File.join(File.dirname(__FILE__),'..','spec_helper')

describe RailsBridge::ContentBridge do
  
  include ContentBridgeSpecHelper
  
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