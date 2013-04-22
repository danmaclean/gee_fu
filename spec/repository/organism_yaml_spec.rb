require 'spec_helper'

describe OrganismYaml do
  let(:user) {  
    user = User.new(
      email:                  "fred@fred.com",
      password:               "password",
      password_confirmation:  "password",
      first_name:             "Fred",
      last_name:              "Bloggs",
      admin:                   true
    )
    user.confirm!
    user.save
    user
  }

  let(:organism) { 
    Timecop.freeze(Time.zone.local(2013, 4, 19, 12, 0, 0)) do
      Organism.create!(
        :local_name => "My favourite organism",
        :genus => "Arabidopsis",
        :species => "thaliana",
        :strain => "Col 0",
        :pv => "A",
        :taxid  => "3702"
      )
    end
  }

  before(:each) do
    PaperTrail.whodunnit = user.id
  end

  subject { OrganismYaml.new(organism) }
  let(:yaml) { YAML.load(subject.dump) }

  describe "#dump", versioning: true  do
    it "writes organism out as a YAML file" do
      yaml.should eq(
        "organism" => {
          "Local name"        => "My favourite organism",
          "Genus"             => "Arabidopsis",
          "Species"           => "thaliana",
          "Strain"            => "Col 0",
          "Pathovar"          => "A",
          "NCBI Taxonomy ID"  => "3702",
          "Last updated by"   => "Fred Bloggs",
          "Last updated on"   => "19 April 2013"
        }
      )
    end
  end

  describe "#dump without versioning" do
    it "should mark changes as Unknown" do
      yaml.should eq(
        "organism" => {
          "Local name"        => "My favourite organism",
          "Genus"             => "Arabidopsis",
          "Species"           => "thaliana",
          "Strain"            => "Col 0",
          "Pathovar"          => "A",
          "NCBI Taxonomy ID"  => "3702",
          "Last updated by"   => "Unknown",
          "Last updated on"   => "Unknown"
        }
      )
    end
  end
end