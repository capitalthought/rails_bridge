require File.join(File.dirname(__FILE__),'..','spec_helper')

describe RailsBridge::LayoutBridgeController do
  
  include LayoutBridgeSpecHelper
  
  it "the index action returns the applications layouts" do
    visit rails_bridge_layouts_path
    tm_safe_debug page.source
  end

  it "the show action returns the specified layout" do
    visit rails_bridge_layout_path(:id=>'application')
    tm_safe_debug page.source
  end
end