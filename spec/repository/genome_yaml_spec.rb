require 'spec_helper'
require 'genome_yaml'

describe GenomeYaml do
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

  let(:genome) {  
    Genome.create!(
      organism_id: organism.id,
      build_version: "TAIR 9",
      meta: { }.to_json,
      fasta_file: "dummy/not/actually/used/in/the/spec"
    )
  }

  subject { GenomeYaml.new(genome) }

  describe "#dump" do
    let(:yaml) { YAML.load(subject.dump) }

    it "writes a genome out as a YAML file" do
      yaml.should eq(
        "genome" => {
          "Build version"  => "TAIR 9"#,
          # "Created by"        => "Fred Bloggs",
          # "Created on"        => "19 Apr 2013"
        }
      )
    end
  end
end