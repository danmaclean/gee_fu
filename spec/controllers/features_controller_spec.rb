require 'spec_helper'

describe FeaturesController do
  describe "#search_by_id" do
    it "should check whether the feature exists" do
      Feature.should_receive(:exists?).with("foo")
      post :search_by_id, feature: { id: :foo }
    end

    context "the id is of an existing feature" do
      before(:each) do
        Feature.stub(:exists? => true)
      end

      it "redirects to the feature path" do
        post(:search_by_id, feature: { id: :foo }).should redirect_to feature_path("foo")
      end

      it "doesn't set the flash" do
        post :search_by_id, feature: { id: :foo }
        flash.should be_empty
      end
    end

    context "the id is of non-existant feature" do
      before(:each) do
        Feature.stub(:exists? => false)
      end

      it "redirects to the index page" do
        post(:search_by_id, feature: { id: :foo }).should redirect_to features_path
      end

      it "sets the flash alert" do
        post :search_by_id, feature: { id: :foo }
        flash[:alert].should eq "No feature found with that ID"
      end
    end
  end

  describe "#search_by_attribute" do
    before(:each) do
      Feature.stub(where: [])
    end

    it "should check whether the feature group contains the search string" do
      Feature.should_receive(:where).with()
      post :search_by_attribute, feature: { group: "bar" }
    end

    context "there is a match" do
      let(:feature) { mock(Feature) }

      before(:each) do
        Feature.stub(where: [ feature ]) 
      end

      it "renders the template" do
        post(:search_by_attribute, feature: { group: "bar" }).should render_template :search_by_attribute
      end
    end

    context "there is no match" do
      it "redirects to the index page" do
        post(:search_by_attribute, feature: { group: "bar" }).should redirect_to features_path
      end

      it "sets the flash" do
        post :search_by_attribute, feature: { group: "bar" }     
        flash[:alert].should eq "No features found searching for: 'bar'"
      end
    end
  end
end