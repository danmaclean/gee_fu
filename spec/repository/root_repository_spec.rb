require 'spec_helper'
require 'fakefs/spec_helpers'
require 'organism'

describe RootRepository do
  include FakeFS::SpecHelpers

  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  subject { RootRepository.new(full_repo_path) }

  def repo_path_with(other_path=nil)
    "#{full_repo_path}/#{other_path}"
  end

  def directory_listing(path="*", path_to_remove=repo_path)
    Dir.glob("#{full_repo_path}/#{path}").map { |entry| entry.sub(path_to_remove + '/', '')  }
  end

  describe "creating the repository folder" do
    context "when the repo folder doesn't exist" do
      it "sanity checks the folder isn't there" do
        File.directory?(full_repo_path).should be_false
      end

      it "creates the repo folder" do
        subject.create
        File.directory?(full_repo_path).should be_true
      end
    end

    context "when the repo folder exists" do
      before(:each) do
        FileUtils.mkdir_p(full_repo_path)
      end

      it "sanity checks that the configured repository folder is there" do
        subject.create
        File.directory?(full_repo_path).should be_true
      end
    end
  end

  describe "creating top level folders for organisms" do
    context "when there are many organisms in the database" do
      before(:each) do
        Organism.create!(
          :genus => "Arabidopsis",
          :species => "thaliana",
          :strain => "Col 0",
          :pv => "A",
          :taxid  => "3702"
        )

        Organism.create!(
          :genus => "Oceanobacillus",
          :species => "iheyensis"
        )
      end

      it "should create a folder for each organism" do
        subject.create
        directory_listing.should =~ [ 
          '3702_Arabidopsis_thaliana_Col 0',
          'no-ncbi-taxid_Oceanobacillus_iheyensis_no-strain' 
        ]    
      end
    end

    context "when there is 1 organism in the database" do
      before(:each) do
        Organism.create!(
          :genus => "Arabidopsis",
          :species => "thaliana",
          :strain => "Col 0",
          :pv => "A",
          :taxid  => "3702"
        )
      end

      it "should create a folder for each organism" do
        subject.create
        directory_listing.should =~ [ '3702_Arabidopsis_thaliana_Col 0' ]    
      end
    end

    context "when there are no organisms in the database" do
      it "sanity checks there are no Organisms" do
        Organism.count.should eq 0
      end

      it "the repo folder should be empty" do
        subject.create
        directory_listing.should be_empty
      end
    end
  end

  describe "removing existing folders" do
    context "when there is already an organism folder" do
      let!(:organism) {  
        Organism.create!(
          :genus => "Arabidopsis",
          :species => "thaliana"
        )
      }

      before(:each) do
        FileUtils.mkdir_p(repo_path_with('3702_Arabidopsis_thaliana_Col 0'))
        directory_listing.should =~ [ '3702_Arabidopsis_thaliana_Col 0' ]
      end

      it "removes the folder if the Organism is removed" do
        organism.delete
        subject.create
        directory_listing.should be_empty
      end
    end 

    context "when there are other folders in the top level repo folder" do
      before(:each) do
        FileUtils.mkdir_p(repo_path_with("shouldnt_be_here"))
        directory_listing.should =~ [ 'shouldnt_be_here' ]
      end

      it "removes any top level folders that aren't related to Organisms" do
        subject.create
        directory_listing.should be_empty
      end
    end
  end
end
