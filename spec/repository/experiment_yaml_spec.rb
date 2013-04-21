require 'spec_helper'

describe ExperimentYaml do
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

  let(:experiment) {  
    Experiment.create!(
      genome_id: genome.id,
      name: "TAIR 9 GFF",
      description: "my first experiment",
      bam_file_path: nil, 
      meta: {}.to_json
    )
  }

  subject { ExperimentYaml.new(experiment) }

  describe "#dump" do
    let(:yaml) { YAML.load(subject.dump) }

    it "writes an experiment out as a YAML file" do
      yaml.should eq(
        "experiment" => {
          "Name"        => "TAIR 9 GFF",
          "Description" => "my first experiment"#,
          # "Created by"        => "Fred Bloggs",
          # "Created on"        => "19 Apr 2013"
        }
      )
    end
  end
end