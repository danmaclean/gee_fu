require 'spec_helper'
require 'genome_yaml'

describe GenomeYaml do
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
    Timecop.freeze(Time.zone.local(2013, 4, 19, 12, 0, 0)) do
      Genome.create!(
        organism_id: organism.id,
        build_version: "TAIR 9",
        meta: { }.to_json,
        fasta_file: "dummy/not/actually/used/in/the/spec"
      )
    end
  }

  before(:each) do
    PaperTrail.whodunnit = user.id
  end

  subject    { GenomeYaml.new(genome) }
  let(:yaml) { YAML.load(subject.dump) }

  describe "#dump", versioning: true do
    it "writes a genome out as a YAML file" do
      yaml.should eq(
        "genome" => {
          "Build version"   => "TAIR 9",
          "Last updated by" => "Fred Bloggs (fred@fred.com)",
          "Last updated on" => "19 April 2013"
        }
      )
    end
  end

  describe "#dump without versioning" do
    it "should mark changes as Unknown" do
      yaml.should eq(
        "genome" => {
          "Build version"   => "TAIR 9",
          "Last updated by" => "Unknown",
          "Last updated on" => "Unknown"
        }
      )
    end
  end
end