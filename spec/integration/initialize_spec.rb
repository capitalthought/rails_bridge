require 'spec_helper'

describe "initialize test" do
  it "is" do
    Rails.application.kind_of?( Dummy::Application ).should == true
  end

  it "sets the ContentBridge logger to the Rails logger" do
    Rails.logger.should_receive(:info)
    RailsBridge::ContentBridge.logger.info "test"
  end

  it "sets the ContentBridge cache to Rails cache" do
    Rails.cache.should_receive(:set)
    RailsBridge::ContentBridge.cache.set( "key", "value" )
  end
end
