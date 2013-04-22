require 'spec_helper'

describe Experiment do
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
      meta: {}.to_json,
      fasta_file: "dummy/not/actually/used/in/the/spec"
    ) 
  }

  def valid_attributes(overrides={})
    {
      genome_id: genome.id,
      name: "TAIR 9 GFF",
      description: "my first experiment",
      bam_file_path: nil, 
      meta: {}.to_json
    }.merge(overrides)   
  end

  it_behaves_like "a model with user audits"

  describe "persistence", versioning: true do
    subject { Experiment.new(valid_attributes) }

    before(:each) do
      subject.save!
    end
        
    it_behaves_like "a model with versioning" do
      let(:attributes_to_update) { 
        {
          name:         "TAIR 9 GFF (revised)",
          description:  "botched"
        }  
      }

      let(:changeset) { 
        {
          "name" => [ "TAIR 9 GFF", "TAIR 9 GFF (revised)" ],
          "description" => [ "my first experiment", "botched" ]
        }
      }
    end
  end

end