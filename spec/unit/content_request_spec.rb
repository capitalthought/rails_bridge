require File.join(File.dirname(__FILE__),'..','spec_helper')

describe RailsBridge::ContentRequest do
  
  DEFAULT_OPTIONS = {
    :protocol => 'httpq', 
    :host => 'localhosty', 
    :port => 5678, 
    :path => '/path', 
    :params => {:p1=>'p1'}, 
    :default_content => 'Default Content'
  }
  
  def default_options; DEFAULT_OPTIONS; end
  
  it "initializes with options", :focus=>false do
    request = RailsBridge::ContentRequest.new( default_options )
    request.protocol.should == default_options[:protocol]
    request.host.should == default_options[:host]
    request.port.should == default_options[:port]
    request.params.should == default_options[:params]
    request.default_content.should == default_options[:default_content]
  end

  it "the accessors work", :focus=>false do
    request = RailsBridge::ContentRequest.new
    default_options.each do |k,v|
      request.send("#{k}=".to_sym, v)
    end
    request.protocol.should == default_options[:protocol]
    request.host.should == default_options[:host]
    request.port.should == default_options[:port]
    request.params.should == default_options[:params]
    request.default_content.should == default_options[:default_content]
  end

  it "initializes its URL attributes components from :url when specified", :focus=>false do
    request = RailsBridge::ContentRequest.new( {:url=>'http://localhost:5678/path?p1=p1'} )
    request.url.should == 'http://localhost:5678/path'
    request.params.should == {:p1=>'p1'}
    
    request = RailsBridge::ContentRequest.new
    request.url = "http://server.com:8080/some/path"
    request.params = {:param1=>'a value', :param2=>'another value'}
    request.url.should == 'http://server.com:8080/some/path'
    request.params.should == {:param1=>'a value', :param2=>'another value'}
    
  end

  it "returns a properly formed URL without params", :focus=>false do
    request = RailsBridge::ContentRequest.new( default_options )
    request.url.should == 'httpq://localhosty:5678/path'
  end

  it ":on_success stores a block when passed and returns it when no block is passed", :focus=>false do
    request = RailsBridge::ContentRequest.new( default_options )
    executed = "concat"
    request.on_success do |response|
      response + "enated"
    end
    executed = request.on_success.call( executed )
    executed.should == "concatenated"
  end

  it "uses the bridges attributes when none are specified on the request" do
    class ContentBridgeTest3 < RailsBridge::ContentBridge
      self.protocol        = DEFAULT_OPTIONS[:protocol]
      self.host            = DEFAULT_OPTIONS[:host]
      self.port            = DEFAULT_OPTIONS[:port]
      self.path            = DEFAULT_OPTIONS[:path]
      self.params          = DEFAULT_OPTIONS[:params]
      self.default_content = DEFAULT_OPTIONS[:default_content]
      content_request :test
    end
    test_request = ContentBridgeTest3.content_requests[:test]
    test_request.protocol.should == DEFAULT_OPTIONS[:protocol]
    test_request.host.should == DEFAULT_OPTIONS[:host]
    test_request.port.should == DEFAULT_OPTIONS[:port]
    test_request.path.should == DEFAULT_OPTIONS[:path]
    test_request.params.should == DEFAULT_OPTIONS[:params]
    test_request.url.should == "httpq://localhosty:5678/path"
  end
  
end
