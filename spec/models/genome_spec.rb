require 'spec_helper'

describe Genome do
  def valid_attributes(overrides={})
    {
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
    }.merge(overrides)
  end

  describe "persistence", versioning: true do
    subject { Genome.new(valid_attributes) }

    before(:each) do
      subject.save!
    end
        
    it_behaves_like "a model with versioning" do
      let(:attributes_to_update) { 
        {
          build_version: "TAIR 10"
        }  
      }

      let(:changeset) { 
        {
          "build_version" => [ "TAIR 9", "TAIR 10" ]
        }
      }
    end
  end
end