require 'spec_helper'
require 'organism'
require 'genome'
require 'experiment'
require 'feature'
require 'reference'
require 'sequence'

describe FeaturesGffExporter do
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

  it "exports the features in GFF format" do
    gff_export = FeaturesGffExporter.new(experiment).export
    "#{gff_export}\n".should eq <<-GFF
Chr1\tTAIR9\tgene\t3631\t5899\t.\t+\t.\tID=AT1G01010;Note=protein_coding_gene;Name=AT1G01010
Chr1\tTAIR9\tmRNA\t3631\t5899\t.\t+\t.\tID=AT1G01010.1;Parent=AT1G01010;Name=AT1G01010.1;Index=1
Chr1\tTAIR9\texon\t3631\t3913\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tfive_prime_UTR\t3631\t3759\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tCDS\t3760\t3913\t.\t+\t0\tParent=AT1G01010.1
Chr1\tTAIR9\texon\t3996\t4276\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tCDS\t3996\t4276\t.\t+\t2\tParent=AT1G01010.1
Chr1\tTAIR9\texon\t4486\t4605\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tCDS\t4486\t4605\t.\t+\t0\tParent=AT1G01010.1
Chr1\tTAIR9\texon\t4706\t5095\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tCDS\t4706\t5095\t.\t+\t0\tParent=AT1G01010.1
Chr1\tTAIR9\texon\t5174\t5326\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tCDS\t5174\t5326\t.\t+\t0\tParent=AT1G01010.1
Chr1\tTAIR9\texon\t5439\t5899\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tCDS\t5439\t5630\t.\t+\t0\tParent=AT1G01010.1
Chr1\tTAIR9\tthree_prime_UTR\t5631\t5899\t.\t+\t.\tParent=AT1G01010.1
Chr1\tTAIR9\tgene\t5928\t8737\t.\t-\t.\tID=AT1G01020;Note=protein_coding_gene;Name=AT1G01020
Chr1\tTAIR9\tmRNA\t5928\t8737\t.\t-\t.\tID=AT1G01020.1;Parent=AT1G01020;Name=AT1G01020.1;Index=1
Chr1\tTAIR9\tfive_prime_UTR\t8667\t8737\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t8571\t8666\t.\t-\t0\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t8571\t8737\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t8417\t8464\t.\t-\t0\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t8417\t8464\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t8236\t8325\t.\t-\t0\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t8236\t8325\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t7942\t7987\t.\t-\t0\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t7942\t7987\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t7762\t7835\t.\t-\t2\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t7762\t7835\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t7564\t7649\t.\t-\t0\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t7564\t7649\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t7384\t7450\t.\t-\t1\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t7384\t7450\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t7157\t7232\t.\t-\t0\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t7157\t7232\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tCDS\t6915\t7069\t.\t-\t2\tParent=AT1G01020.1
Chr1\tTAIR9\tthree_prime_UTR\t6437\t6914\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t6437\t7069\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tthree_prime_UTR\t5928\t6263\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\texon\t5928\t6263\t.\t-\t.\tParent=AT1G01020.1
Chr1\tTAIR9\tmRNA\t6790\t8737\t.\t-\t.\tID=AT1G01020.2;Parent=AT1G01020;Name=AT1G01020.2;Index=1
Chr1\tTAIR9\tfive_prime_UTR\t8667\t8737\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t8571\t8666\t.\t-\t0\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t8571\t8737\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t8417\t8464\t.\t-\t0\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t8417\t8464\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t8236\t8325\t.\t-\t0\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t8236\t8325\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t7942\t7987\t.\t-\t0\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t7942\t7987\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t7762\t7835\t.\t-\t2\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t7762\t7835\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t7564\t7649\t.\t-\t0\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t7564\t7649\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tCDS\t7315\t7450\t.\t-\t1\tParent=AT1G01020.2
Chr1\tTAIR9\tthree_prime_UTR\t7157\t7314\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t7157\t7450\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tthree_prime_UTR\t6790\t7069\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\texon\t6790\t7069\t.\t-\t.\tParent=AT1G01020.2
Chr1\tTAIR9\tthree_prime_UTR\t11649\t11863\t.\t-\t.\tParent=AT1G01030.1
GFF
  end
end