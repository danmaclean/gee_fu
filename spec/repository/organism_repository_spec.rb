require 'spec_helper'
require 'fakefs/spec_helpers'
require 'organism'
require 'organism_yaml'
require 'genome'
require 'experiment'

describe OrganismRepository do
  include FakeFS::SpecHelpers

  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
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


  before(:each) do
    FileUtils.mkdir_p(full_repo_path)
    directory_listing.should be_empty
  end

  describe "#create" do
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

    subject { OrganismRepository.new(organism, full_repo_path) }
  
    it "creates a folder for itself based on its attributes" do
      subject.create
      directory_listing.should =~ with_repo_path(['My favourite organism'])
    end

    it "writes a organism.yml file to the organism folder" do
      subject.create
      directory_listing('My favourite organism/*').should =~ with_repo_path([ 'My favourite organism/organism.yml' ])
    end

    it "writes a yaml file that represents the organism's attributes" do
      subject.create
      data = YAML.load_file "#{full_repo_path}/My favourite organism/organism.yml"
      data.should be_true
    end

    it "the yaml file contains the correct attributes" do
      subject.create
      data = YAML.load_file "#{full_repo_path}/My favourite organism/organism.yml"
      data["organism"].should eq(
        {
          "Local name" => "My favourite organism",
          "Genus"   => "Arabidopsis",
          "Species" => "thaliana",
          "Strain" => "Col 0",
          "Pathovar" => "A",
          "NCBI Taxonomy ID" => "3702"
        }
      )
    end

    context "when there are no Genomes for the Organism" do
      it "doesn't create any folders" do
        subject.create
        directories_within(directory_listing('My favourite organism/*')).should be_empty
      end
    end

    context "there is a Genome for the Organism" do
      before(:each) do
        Genome.create!(
          organism_id:    organism.id,
          build_version:  "TAIR 9",
          meta:           { }.to_json,
          fasta_file:      "dummy/not/actually/used/in/the/spec"
        )
      end

      it "creates a folder for the genome" do
        subject.create
        directories_within(directory_listing('My favourite organism/*')).should =~ with_repo_path([ "My favourite organism/TAIR 9" ])
      end
    end

    context "there is more than one Genome for the Organism" do
      before(:each) do
        Genome.create!(
          organism_id:    organism.id,
          build_version:  "TAIR 9",
          meta:           { }.to_json,
          fasta_file:      "dummy/not/actually/used/in/the/spec"
        )

        Genome.create!(
          organism_id:    organism.id,
          build_version:  "TAIR 19",
          meta:           { }.to_json,
          fasta_file:      "dummy/not/actually/used/in/the/spec"
        )
      end

      it "creates the folders for the genome" do
        subject.create
        directories_within(directory_listing('My favourite organism/*')).should =~ with_repo_path([ "My favourite organism/TAIR 9", "My favourite organism/TAIR 19" ])
      end
    end

    context "there is a Genome for another Organism" do
      let(:other_organism) { 
        Organism.create!(
          :local_name => "My mother's organism",
          :genus => "Ardisia",
          :species => "Myrsinaceae",
          :strain => "Col 10",
          :pv => "B",
          :taxid  => "1234"
        ) 
      }

      before(:each) do
        Genome.create!(
          organism_id:    other_organism.id,
          build_version:  "TAIR 9",
          meta:           { }.to_json,
          fasta_file:      "dummy/not/actually/used/in/the/spec"
        )

        Genome.create!(
          organism_id:    organism.id,
          build_version:  "TAIR 19",
          meta:           { }.to_json,
          fasta_file:      "dummy/not/actually/used/in/the/spec"
        )
      end

      it "creates the folders only for the genome of the organism" do
        subject.create
        directories_within(directory_listing('My favourite organism/*')).should =~ with_repo_path([ "My favourite organism/TAIR 19" ])
      end
    end

    context "when removing existing folders" do
      context "when there is already a genome folder" do
        let(:genome) {  
          Genome.create!(
            organism_id:    organism.id,
            build_version:  "TAIR 19",
            meta:           { }.to_json,
            fasta_file:      "dummy/not/actually/used/in/the/spec"
          )
        }

        before(:each) do
          FileUtils.mkdir_p("#{full_repo_path}/My favourite organism/TAIR 19")
          directories_within(directory_listing('My favourite organism/*')).should =~ with_repo_path([ "My favourite organism/TAIR 19" ])
        end

        it "removes the folder if the Genome is removed" do
          genome.delete
          subject.create
          directories_within(directory_listing('My favourite organism/*')).should be_empty
        end
      end 

      context "when there are other folders in the organism repo folder" do
        before(:each) do
          FileUtils.mkdir_p("#{full_repo_path}/My favourite organism/shouldnt_be_here")
          directory_listing('My favourite organism/*').should =~ with_repo_path([ 'My favourite organism/shouldnt_be_here' ])
        end

        it "removes any other folders that aren't related to the Organism" do
          subject.create
          directories_within(directory_listing('My favourite organism/*')).should be_empty
        end
      end
    end
  end

  describe "with mocks" do
    let(:genome)   { mock(Genome, build_version: :specified_later) }
    let(:organism) { mock(Organism, genomes: [ genome ], local_name: "mock") }
    let(:organism_yaml) { mock(OrganismYaml, dump: :specified_later) }

    let(:genome_repository) { mock(GenomeRepository, create: :specified_later) }

    subject { OrganismRepository.new(organism, full_repo_path) }

    before(:each) do
      OrganismYaml.stub(new: organism_yaml)
      GenomeRepository.stub(new: genome_repository)
    end

    it "uses a GenomeRepository with the repo path and the genome" do
      GenomeRepository.should_receive(:new).with(genome, "#{full_repo_path}/mock")
      genome_repository.should_receive(:create)
      subject.create
    end

    it "uses an OrganismYaml to dump the file" do
      OrganismYaml.should_receive(:new).with(organism)
      organism_yaml.should_receive(:dump)
      subject.create
    end
  end
end