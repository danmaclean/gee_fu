require 'spec_helper'

describe "annoj param sanitising" do
  context "POSTing" do
    it "should extract the action param and add it as annoj_action" do
      post("/features/annoj/1", "action" => "serialize")
      request.parameters["annoj_action"].should eq "serialize"
    end  

    it "shouldn't affect any other params" do
      post("/features/annoj/1", "action" => "serialize", "foo" => "bar", "baz" => "quux")
      request.parameters["foo"].should eq "bar"
      request.parameters["baz"].should eq "quux"
    end  
  end

  context "GETting" do
    it "extracts the action params and adds it as annoj_action" do
      get("/features/annoj/1", "action" => "serialize")
      request.parameters["annoj_action"].should eq "serialize"
    end

    it "doesn't affect any other params" do
      get("/features/annoj/1", "action" => "serialize", "foo" => "bar", "baz" => "quux")
      request.parameters["foo"].should eq "bar"
      request.parameters["baz"].should eq "quux"
    end
  end
end