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
  
  it "fetches the server's content using get" do
    ContentBridgeTest.get_chang.should == DEFAULT_RETURN_DATA
  end

  it "fetches the server's content in parallel using request" do
    cbt = ContentBridgeTest
    wang = ContentBridgeTest.content_requests[:chang].dup
    wang.params = wang.params.merge({:return_data=>"other"})
    cbt.content_requests[:wang] = wang
    chang_result = wang_result = nil
    cbt.request_wang do |result|
      wang_result = result
    end
    cbt.request_chang do |result|
      chang_result = result
    end
    wang_result.should == nil
    chang_result.should == nil
    cbt.execute_requests
    chang_result.should == DEFAULT_RETURN_DATA
    wang_result.should == "other"
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
  
  it "calls the bridge's on_success proc when defined" do
    cbt = ContentBridgeTest
    cbt.on_success do |content|
      content +"ext"
    end
    cbt.get_chang(:cache_timeout=>0).should == DEFAULT_RETURN_DATA+"ext"
    cbt.on_success = nil
  end
  
  it "calls the request's on_success proc when defined" do
    cbt = ContentBridgeTest
    cbt.on_success do |content|
      content +"ext"
    end
    ContentBridgeTest.content_requests[:chang].on_success do |content|
      content +"ext2"
    end
    cbt.get_chang(:cache_timeout=>0).should == DEFAULT_RETURN_DATA+"ext2"
    cbt.on_success = nil
    ContentBridgeTest.content_requests[:chang].on_success = nil
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
    cbt.get_chang(:cache_timeout=>60,:params=>{:unique=>unique}).should == DEFAULT_RETURN_DATA
    TestServer.shutdown
    cbt.get_chang(:cache_timeout=>60,:params=>{:unique=>unique}).should == DEFAULT_RETURN_DATA
  end

  it "the cache expires correctly" do
    unique = __LINE__
    cbt = ContentBridgeTest
    chang = cbt.content_requests[:chang]
    cbt.get_chang(:cache_timeout=>2,:params=>{:unique=>unique}).should == DEFAULT_RETURN_DATA
    TestServer.shutdown
    cbt.get_chang(:cache_timeout=>2,:params=>{:unique=>unique}).should == DEFAULT_RETURN_DATA
    sleep 2
    cbt.get_chang(:cache_timeout=>2,:params=>{:unique=>unique}).should == cbt.content_requests[:chang].default_content
  end
  
  it "allows get_remote_content to be called directly with request options" do
    ContentBridgeTest.get_remote_content(DEFAULT_REQUEST_VALUES).should == DEFAULT_RETURN_DATA
  end
  
  it "automatically loads class in the app/rails_bridge/content_bridges directory" do
    defined?( TwitterContentBridge ).should == 'constant'
    defined?( Tester ).should == 'constant'
  end
end