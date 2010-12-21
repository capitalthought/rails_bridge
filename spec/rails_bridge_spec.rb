require 'spec_helper'

describe RailsBridge do
  it "exists" do
    RailsBridge.kind_of?( Module ).should == true
  end

  it "loads necessary classes" do
    RailsBridge::ContentBridge.new.is_a?( RailsBridge::ContentBridge ).should == true
  end
end
