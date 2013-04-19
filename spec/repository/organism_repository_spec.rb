require 'spec_helper'
require 'fakefs/spec_helpers'
require 'organism'
require 'genome_repository'

describe OrganismRepository do
  include FakeFS::SpecHelpers

  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  def directory_listing(path="*", path_to_remove=repo_path)
    Dir.glob("#{full_repo_path}/#{path}").map { |entry| entry.sub(path_to_remove + '/', '')  }
  end

  let(:organism) { 
    Organism.create!(
      :genus => "Arabidopsis",
      :species => "thaliana",
      :strain => "Col 0",
      :pv => "A",
      :taxid  => "3702"
    )
  }

  let(:genome_repository) { mock(GenomeRepository) }

  before(:each) do
    FileUtils.mkdir_p(full_repo_path)
    directory_listing.should be_empty
  end

  subject { OrganismRepository.new(organism, full_repo_path) }

  it "creates a folder for itself based on its attributes" do
    subject.create
    directory_listing.should =~ ['3702_Arabidopsis_thaliana_Col 0']
  end

  it "creates the folders for all the genomes" do
    fail "need to deal with 0, 1, n genomes"
  end

  it "removes unused folders" do
    fail "look at the duplication with RootRepository here"
  end

  it "uses a GenomeRepository to populate the genome subfolder" do
    fail "until we get the data hierarchy in place"
    # GenomeRepository.should_receive(:new).
    #   with(organism, "#{full_repo_path}/3702_Arabidopsis_thaliana_Col 0").
    #   and_return(genome_repository)
    # genome_repository.should_receive(:create)
    subject.create
  end
end