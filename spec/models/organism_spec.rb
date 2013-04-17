require 'spec_helper'

describe Organism do
  def valid_attributes(overrides={})
    {
      :genus => "Arabidopsis",
      :species => "thaliana",
      :strain => "Col 0",
      :pv => "A",
      :taxid  => "3702"
    }.merge(overrides)
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