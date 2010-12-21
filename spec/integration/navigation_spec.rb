require 'spec_helper'

describe "nagivation test" do
  it "truth" do
    Rails.application.kind_of?( Dummy::Application ).should == true
  end
end
