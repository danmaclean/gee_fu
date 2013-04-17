require 'spec_helper'

describe Feature do
  let(:genome) { 
    Genome.create!(
      build_version: "TAIR 9",
      meta: {}.to_json,
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


  def valid_attributes(overrides={})
    {
      seqid:    "Chr1", 
      source:   "TAIR9", 
      feature:  "exon", 
      start:    3631, 
      end:      3913, 
      score:    "", 
      strand:   "+", 
      phase:    "", 
      group: [
                [ "Parent", "AT1G01010.1" ]
      ].to_json, 
      gff_id:   "",
      sequence: "", 
      quality:  "", 
      experiment: experiment#, 
      # reference_id: reference.id
    }.merge(overrides)
  end

  describe "persistence", versioning: true do
    subject { Feature.new(valid_attributes) }

    before(:each) do
      subject.save!
    end
        
    it_behaves_like "a model with versioning" do
      let(:attributes_to_update) { 
        {
          seqid:  "Chr2",
          start:  1500,
          end:    2000
        }  
      }

      let(:changeset) { 
        {
          "seqid" => [ "Chr1", "Chr2" ],
          "start" => [ 3631, 1500 ],
          "end"   => [ 3913, 2000 ]
        }
      }
    end
  end
end