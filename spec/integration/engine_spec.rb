require 'spec_helper'

describe "initialize test" do
  it "verify the Dummy app gets loaded" do
    Rails.application.kind_of?( Dummy::Application ).should == true
  end

  it "verify the LayoutBridgeController class is loaded" do
    defined?( RailsBridge::LayoutBridgeController ).should == "constant"
  end

  it "sets the ContentBridge logger to the Rails logger" do
    Rails.logger.should_receive(:info)
    RailsBridge::ContentBridge.logger.info "test"
  end

  it "sets the ContentBridge cache to Rails cache" do
    Rails.cache.should_receive(:set)
    RailsBridge::ContentBridge.cache.set( "key", "value" )
  end

  it "autoloads classes in the app/rails_bridge path" do
    defined?( TwitterContentBridge ).should == "constant"
  end
end
