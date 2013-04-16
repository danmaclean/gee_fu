require 'spec_helper'
require_relative '../../app/presenters/feature_parent_presenter'

describe FeatureParentPresenter do
  let(:feature) { mock(Feature) }
  subject       { FeatureParentPresenter.new(feature) }

  #     <% g = 'none' %>
  # <% if @feature.has_parent? %>
  #   <% g = @feature.parents.collect {|x| '<a href=/features/' + x.parent_obj.id.to_s + '/edit>' + x.parent_obj.id.to_s + '</a>'}.join(',') %>
  # <% end %>

  describe "parent_list" do
    context "the feature doesn't have parents" do
      before(:each) do
        feature.stub(:has_parent? => false)
      end

      it "is 'none'" do
        subject.parent_list.should eq 'none'
      end
    end

    context "the feature does have parents" do
      let(:grand_parent_1)  { mock("Grandparent", id: "A820FB48-566D-4650-B077-A855007EB184")  }
      let(:grand_parent_2)  { mock("Grandparent", id: "blah-blah-blah")  }
      let(:grand_parent_3)  { mock("Grandparent", id: 42)  }
      let(:parent_1)        { mock("Parent", parent_obj: grand_parent_1) }
      let(:parent_2)        { mock("Parent", parent_obj: grand_parent_2) }
      let(:parent_3)        { mock("Parent", parent_obj: grand_parent_3) }

      let(:list_of_parents) { [ parent_1, parent_2, parent_3 ] }

      before(:each) do
        feature.stub(:has_parent? => true)
        feature.stub(:parents => list_of_parents)
      end

      it "should be an array of anchor tags to edit the parents" do
        subject.parent_list.should eq(
          '<a href="/features/A820FB48-566D-4650-B077-A855007EB184/edit">A820FB48-566D-4650-B077-A855007EB184</a>,<a href="/features/blah-blah-blah/edit">blah-blah-blah</a>,<a href="/features/42/edit">42</a>'
        )
      end
    end
  end
end