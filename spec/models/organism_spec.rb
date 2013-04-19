require 'spec_helper'

describe Organism do
  def valid_attributes(overrides={})
    {
      :local_name => "My best organism",
      :genus => "Arabidopsis",
      :species => "thaliana",
      :strain => "Col 0",
      :pv => "A",
      :taxid  => "3702"
    }.merge(overrides)
  end

  describe "#to_s" do
    subject { Organism.new(valid_attributes) }

    it "is the local name" do
      subject.to_s.should eq "My best organism"
    end
  end

  describe "validations" do
    subject { Organism.new(valid_attributes) }

    it "sanity checks it is valid" do
      subject.should be_valid
    end

    it "isn't valid unless we have a local name" do
      subject.local_name = ""
      subject.should_not be_valid
    end

    it "isn't valid unless we have a species" do
      subject.species = ""
      subject.should_not be_valid
    end

    it "isn't valid unless we have a genus" do
      subject.genus = ""
      subject.should_not be_valid
    end

    it "isn't valid unless we have a taxonomy id" do
      subject.taxid = ""
      subject.should_not be_valid
    end

    it "isn't valid unless we have a strain" do
      subject.strain = ""
      subject.should_not be_valid
    end

    it "isn't valid unless the local name is unique" do
      Organism.create!(valid_attributes)
      subject.save.should be_false
      subject.errors[:local_name].should include "The local name of the organism must be unique."
    end
  end

  describe "persistence", versioning: true do
    subject { Organism.new(valid_attributes) }

    before(:each) do
      subject.save!
    end
        
    it_behaves_like "a model with versioning" do
      let(:attributes_to_update) { 
        {
          genus: "sispodibarA",
          species:  "anailaht"
        }  
      }

      let(:changeset) { 
        {
          "genus" => [ "Arabidopsis", "sispodibarA" ],
          "species" => [ "thaliana", "anailaht" ]
        }
      }
    end
  end
end