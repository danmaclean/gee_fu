require 'spec_helper'

describe OrganismYaml do
  let(:organism) {  
    Organism.create!(
      :local_name => "My favourite organism",
      :genus => "Arabidopsis",
      :species => "thaliana",
      :strain => "Col 0",
      :pv => "A",
      :taxid  => "3702"
    )
  }

  subject { OrganismYaml.new(organism) }

  describe "#dump" do
    let(:yaml) { YAML.load(subject.dump) }

    it "writes organism out as a YAML file" do
      yaml.should eq(
        "organism" => {
          "Local name"        => "My favourite organism",
          "Genus"             => "Arabidopsis",
          "Species"           => "thaliana",
          "Strain"            => "Col 0",
          "Pathovar"          => "A",
          "NCBI Taxonomy ID"  => "3702"#,
          # "Created by"        => "Fred Bloggs",
          # "Created on"        => "19 Apr 2013"
        }
      )
    end
  end
end