require 'spec_helper'

describe Feature do
  include FastaGffSetup
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

  describe "#to_gff (a simple spec to play with the data format)" do
    before(:each) do
      import_fasta
      import_gff
    end

    it "outputs the feature data as GFF" do
      gff_output = Feature.last.to_gff
      "#{gff_output}\n".should eq <<-GFF
Chr1\tTAIR9\tthree_prime_UTR\t11649\t11863\t.\t-\t.\tParent=AT1G01030.1
GFF
    end
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