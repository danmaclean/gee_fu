require 'spec_helper'

describe PredecessorsGffExporter do
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
    Genome.new(
      organism_id: organism.id,
      build_version: "TAIR 9",
      meta: {}.to_json,
      fasta_file: "dummy/not/actually/used/in/the/spec"
    ) 
  }

  let(:experiment) {  
    Experiment.new(
      genome_id: genome.id,
      name: "TAIR 9 GFF",
      description: "my first experiment",
      bam_file_path: nil, 
      meta: {}.to_json
    )
  }

  before(:each) do
    import_fasta
    import_gff
  end

  subject { PredecessorsGffExporter.new(experiment) }

  describe "#export (a simple spec to play with the data)" do
    let(:feature) { Feature.last }
    let(:predecessor) { Predecessor.new(
      :seqid          => feature.seqid,
      :source         => feature.source,
      :feature        => feature.feature,
      :start          => feature.start,
      :end            => feature.end,
      :score          => feature.score,
      :strand         => feature.strand,
      :phase          => feature.phase,
      :gff_id         => feature.gff_id,
      :reference_id   => feature.reference_id,
      :experiment_id  => feature.experiment_id,
      :created_at     => feature.created_at,
      :group          => feature.group,
      :old_id         => feature.id
      ) 
    }

    before(:each) do
      predecessor.save
      feature.predecessors << predecessor
      feature.save!
    end

    it "exports a Predecessor out as GFF" do
      "#{subject.export}\n".should eq <<-GFF
Chr1\tTAIR9\tthree_prime_UTR\t11649\t11863\t.\t-\t.\told_id=60;Parent=AT1G01030.1
GFF
    end
  end
end