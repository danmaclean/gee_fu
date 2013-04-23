require 'spec_helper'

describe ExperimentYaml do
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
    Genome.create!(
      organism_id: organism.id,
      build_version: "TAIR 9",
      meta: { }.to_json,
      fasta_file: "dummy/not/actually/used/in/the/spec"
    )
  }

  let(:experiment) {  
    Timecop.freeze(Time.zone.local(2013, 4, 19, 12, 0, 0)) do
      Experiment.create!(
        genome_id: genome.id,
        name: "TAIR 9 GFF",
        description: "my first experiment",
        bam_file_path: nil, 
        meta: {}.to_json
      )
    end
  }

  before(:each) do
    PaperTrail.whodunnit = user.id
  end

  subject { ExperimentYaml.new(experiment) }
  let(:yaml) { YAML.load(subject.dump) }

  describe "#dump", versioning: true do
    it "writes an experiment out as a YAML file" do
      yaml.should eq(
        "experiment" => {
          "Name"            => "TAIR 9 GFF",
          "Description"     => "my first experiment",
          "Last updated by" => "Fred Bloggs (fred@fred.com)",
          "Last updated on" => "19 April 2013"
        }
      )
    end
  end

  describe "#dump without versioning" do
    it "should mark changes as Unknown" do
      yaml.should eq(
        "experiment" => {
          "Name"            => "TAIR 9 GFF",
          "Description"     => "my first experiment",
          "Last updated by" => "Unknown",
          "Last updated on" => "Unknown"
        }
      )
    end
  end

end