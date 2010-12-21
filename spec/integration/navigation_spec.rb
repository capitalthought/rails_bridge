require 'spec_helper'

describe "nagivation test" do
  it "is" do
    Rails.application.kind_of?( Dummy::Application ).should == true
  end
end
