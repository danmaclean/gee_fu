require 'spec_helper'
require 'fakefs/spec_helpers'
require 'organism'
require 'genome'
require 'experiment'
require 'experiment_repository'

describe GenomeRepository do
  include FakeFS::SpecHelpers

  let(:repo_path)       { "#{GeeFu::Application.app_config[:repository_directory]}/#{organism.local_name}" }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  def directory_listing(path="*")
    Dir.glob("#{full_repo_path}/#{path}")
  end

  def with_repo_path(elements)
    elements.map { |e| "#{repo_path}/#{e}"  }
  end

  def directories_within(elements)
    elements.select { |e| File.directory?(e) }
  end

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
      meta: {
        "institution" => 
          {
            "name" => "Your Institute",
            "logo" => "images/institute_logo.png",
            "url"  => "http://www.your_place.etc"
          }, 
        "service" => 
          {
            "format"  => "Unspecified", 
            "title"   => "Sample GeeFu served browser (TAIR 9 Gene Models)",
            "server"  => "Unspecified",
            "version" => "Vers 1",
            "access"  => "public",
            "description" => "Free text description of the service"
          }, 
        "engineer" => 
          {
            "name"  => "Mick Jagger",
            "email" => "street.fighting.man@stones.net"
          }, 
        "genome" => 
          {
            "version" => "TAIR9", 
            "description" => "Chr1 from TAIR9", 
            "species" => "Arabidopsis thaliana"
          }
      }.to_json,
      fasta_file: "dummy/not/actually/used/in/the/spec"    
    )
  }

  describe "#create" do
    subject { GenomeRepository.new(genome, full_repo_path) }

    before(:each) do
      FileUtils.mkdir_p(full_repo_path)
      directory_listing.should be_empty
    end

    it "creates a folder for itself based on the build_version" do
      subject.create
      directory_listing.should =~ with_repo_path(['TAIR 9'])
    end

    it "writes a genome.yml file to the genome folder" do
      subject.create
      directory_listing('TAIR 9/*').should =~ with_repo_path([ 'TAIR 9/genome.yml' ])
    end

    it "writes a genome.yml file that represents the genome's attributes" do
      subject.create
      data = YAML.load_file "#{full_repo_path}/TAIR 9/genome.yml"
      data["genome"].should eq(
        {
          "Build version" => "TAIR 9"
        }
      )
    end
  
    context "when there are no Experiments for the Genome" do
      it "doesn't create any folders" do
        subject.create
        directories_within(directory_listing('TAIR 9/*')).should be_empty
      end
    end

    context "there is an Experiment for the Genome" do
      before(:each) do
        Experiment.create!(
          genome_id: genome.id,
          name: "TAIR 9 GFF",
          description: "my first experiment",
          bam_file_path: nil, 
          meta: {}.to_json
        )
      end

      it "creates a folder for the experiment" do
        subject.create
        directories_within(directory_listing('TAIR 9/*')).should =~ with_repo_path([ "TAIR 9/TAIR 9 GFF" ])
      end
    end

    context "there is more than one Experiment for the Genome" do
      before(:each) do
        Experiment.create!(
          genome_id: genome.id,
          name: "TAIR 9 GFF",
          description: "my first experiment",
          bam_file_path: nil, 
          meta: {}.to_json
        )

        Experiment.create!(
          genome_id: genome.id,
          name: "TAIR 9 GFF V2",
          description: "my other experiment",
          bam_file_path: nil, 
          meta: {}.to_json
        )
      end

      it "creates the folders for the experiments" do
        subject.create
        directories_within(directory_listing('TAIR 9/*')).should =~ with_repo_path([ "TAIR 9/TAIR 9 GFF", "TAIR 9/TAIR 9 GFF V2" ])
      end
    end

    context "there is an Experiment for another Genome" do
      let(:other_genome) { 
        Genome.create!(
          organism_id: organism.id,
          build_version: "Another genome",
          meta: { }.to_json,
          fasta_file: "dummy/not/actually/used/in/the/spec"    
        )
      }

      before(:each) do
        Experiment.create!(
          genome_id: genome.id,
          name: "TAIR 9 GFF",
          description: "my first experiment",
          bam_file_path: nil, 
          meta: {}.to_json
        )

        Experiment.create!(
          genome_id: other_genome.id,
          name: "TAIR 9 GFF",
          description: "my other experiment",
          bam_file_path: nil, 
          meta: {}.to_json
        )
      end

      it "creates the folders only for the experiment of the genome" do
        subject.create
        directories_within(directory_listing('TAIR 9/*')).should =~ with_repo_path([ "TAIR 9/TAIR 9 GFF" ])
      end
    end

    context "when removing existing folders" do
      context "when there is already an experiment folder" do
        let(:experiment) {  
          Experiment.create!(
            genome_id: genome.id,
            name: "TAIR 9 GFF",
            description: "my first experiment",
            bam_file_path: nil, 
            meta: {}.to_json
          )
        }

        before(:each) do
          FileUtils.mkdir_p("#{full_repo_path}/TAIR 9/TAIR 9 GFF")
          directories_within(directory_listing('TAIR 9/*')).should =~ with_repo_path([ "TAIR 9/TAIR 9 GFF" ])
        end

        it "removes the folder if the Experiment is removed" do
          experiment.delete
          subject.create
          directories_within(directory_listing('TAIR 9/*')).should be_empty
        end
      end 

      context "when there are other folders in the genome repo folder" do
        before(:each) do
          FileUtils.mkdir_p("#{full_repo_path}/TAIR 9/shouldnt_be_here")
          directory_listing('TAIR 9/*').should =~ with_repo_path([ 'TAIR 9/shouldnt_be_here' ])
        end

        it "removes any other folders that aren't related to the Genome" do
          subject.create
          directories_within(directory_listing('TAIR 9/*')).should be_empty
        end
      end
    end
  end

  describe "with mocks" do
    let(:experiment) { mock(Experiment, name: :specified_later) }
    let(:organism)   { mock(Organism, local_name: "mock_organism") }
    let(:genome)     { mock(Genome, experiments: [ experiment ], build_version: "mock") }

    let(:genome_yaml) { mock(GenomeYaml, dump: :specified_later)  }

    let(:experiment_repository) { mock(ExperimentRepository, create: :specified_later) }

    subject { GenomeRepository.new(genome, full_repo_path) }

    before(:each) do
      GenomeYaml.stub(new: genome_yaml)
      ExperimentRepository.stub(new: experiment_repository)
    end

    it "uses an ExperimentRepository with the repo path and the experment" do
      ExperimentRepository.should_receive(:new).with(experiment, "#{full_repo_path}/mock").and_return(experiment_repository)
      experiment_repository.should_receive(:create)
      subject.create
    end

    it "uses an GenomeYaml to dump the file" do
      GenomeYaml.should_receive(:new).with(genome)
      genome_yaml.should_receive(:dump)
      subject.create
    end
  end
end