require 'spec_helper'

describe RailsBridge do
  it "truth" do
    RailsBridge.kind_of?( Module ).should == true
  end
end
