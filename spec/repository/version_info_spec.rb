require 'spec_helper'

describe VersionInfo do
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

  subject { VersionInfo.new(organism) }

  describe "with versioning", versioning: true do
    describe "#user_name_with_email" do
      it "is the name (and email) of the user who made the change" do
        subject.user_name_with_email.should eq "Fred Bloggs (fred@fred.com)"
      end
    end

    describe "#last_updated_on" do
      it "is the time the change was made" do
        subject.last_updated_on.should eq "19 April 2013"
      end
    end

    describe "#unknown?" do
      it "is false" do
        subject.should_not be_unknown
      end
    end
  end

  describe "without versioning", versioning: false do
    describe "#user_name_with_email" do
      it "is 'Unknown'" do
        subject.user_name_with_email.should eq "Unknown"
      end      
    end    

    describe "#last_updated_on" do
      it "is 'Unknown'" do
        subject.last_updated_on.should eq "Unknown"
      end
    end

    describe "#unknown?" do
      it "is true" do
        subject.should be_unknown
      end
    end
  end
end