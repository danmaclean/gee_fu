require 'spec_helper'
require 'fakefs/spec_helpers'
require 'organism'
require 'genome'
require 'experiment'
require 'features_gff_exporter'
require 'predecessors_gff_exporter'

describe ExperimentRepository do
  include FakeFS::SpecHelpers

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

  let(:repo_path)       { "#{GeeFu::Application.app_config[:repository_directory]}/#{organism.local_name}/#{genome.build_version}" }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  def directory_listing(path="*")
    Dir.glob("#{full_repo_path}/#{path}")
  end

  def with_repo_path(elements)
    elements.map { |e| element_with_path(e)  }
  end

  def element_with_path(element)
    "#{repo_path}/#{element}"
  end

  def directories_within(elements)
    elements.select { |e| File.directory?(e) }
  end
  
  subject { ExperimentRepository.new(experiment, full_repo_path) }

  describe "#create" do
    before(:each) do
      FileUtils.mkdir_p(full_repo_path)
      directory_listing.should be_empty
    end

    it "creates a folder for itself based on the name" do
      subject.create
      directory_listing.should =~ with_repo_path(['TAIR 9 GFF'])
    end

    it "writes a experiment.yml file to the experiment folder" do
      subject.create
      directory_listing('TAIR 9 GFF/*').should include(element_with_path('TAIR 9 GFF/experiment.yml'))
    end

    it "writes a features.gff file to the experiment folder" do
      subject.create
      directory_listing('TAIR 9 GFF/*').should include(element_with_path('TAIR 9 GFF/features.gff'))
    end

    it "writes a predecessor.gff file to the experiment folder" do
      subject.create
      directory_listing('TAIR 9 GFF/*').should include(element_with_path('TAIR 9 GFF/predecessor.gff'))
    end

    it "writes an experiment.yml file that represents the experiment's attributes" do
      subject.create
      data = YAML.load_file "#{full_repo_path}/TAIR 9 GFF/experiment.yml"
      data["experiment"].should include(
        {
          "Name"        => "TAIR 9 GFF",
          "Description" => "my first experiment"
        }
      )
    end

    describe "using a FeaturesGffExporter" do
      let(:exported_gffs)         { "ExportedGFFs" }
      let(:feature_gff_exporter)  { mock(FeaturesGffExporter, export: exported_gffs) }

      before(:each) do
        FeaturesGffExporter.stub(new: feature_gff_exporter)
      end

      it "creates a FeaturesGffExporter" do
        FeaturesGffExporter.should_receive(:new).with(experiment)
        subject.create
      end

      it "writes the results of FeaturesGffExporter#export to the features.gff" do
        subject.create
        File.read(element_with_path('TAIR 9 GFF/features.gff')).should eq exported_gffs
      end
    end

    describe "using a PredecessorsGffExporter" do
      let(:exported_gffs)             { "ExportedGFFs" }
      let(:predecessor_gff_exporter)  { mock(PredecessorsGffExporter, export: exported_gffs) }

      before(:each) do
        PredecessorsGffExporter.stub(new: predecessor_gff_exporter)
      end

      it "creates a PredecessorsGffExporter" do
        PredecessorsGffExporter.should_receive(:new).with(experiment)
        subject.create
      end

      it "writes the results of PredecessorsGffExporter#export to the predecessor.gff" do
        subject.create
        File.read(element_with_path('TAIR 9 GFF/predecessor.gff')).should eq exported_gffs
      end
    end
  end
end
