require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe RailsBridge::ContentRequest do
  
  def default_options
    {
      :protocol => 'http', 
      :host => 'localhost', 
      :port => 5678, 
      :path => '/path', 
      :params => {:p1=>'p1'}, 
      :default_content => 'Default Content'
    }
  end
  
  it "initializes with options", :focus=>true do
    request = RailsBridge::ContentRequest.new( default_options )
    request.protocol.should == default_options[:protocol]
    request.host.should == default_options[:host]
    request.port.should == default_options[:port]
    request.params.should == default_options[:params]
    request.default_content.should == default_options[:default_content]
  end

  it "returns a properly formed URL", :focus=>true do
    request = RailsBridge::ContentRequest.new( default_options )
    request.url.should == 'http://localhost:5678/path?p1=p1'
  end
end
