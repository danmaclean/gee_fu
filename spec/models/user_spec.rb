require 'spec_helper'

describe User do
  def valid_attributes(overrides={})
    {
      email:                  "fred@fred.com",
      password:               "password",
      password_confirmation:  "password",
      first_name:             "Fred",
      last_name:              "Bloggs"
    }.merge(overrides)
  end    

  describe "#full_name_with_email" do
    it "is the user's full name" do
      User.new(valid_attributes).full_name_with_email.should eq "Fred Bloggs (fred@fred.com)"
    end
  end

  describe "validations" do
    it "sanity checks it is valid" do
      User.new(valid_attributes).should be_valid
    end

    it "isn't valid unless we have a valid email" do
      User.new(valid_attributes(email: "root@localhost")).should_not be_valid
    end

    it "isn't valid unless we have a first name" do
      User.new(valid_attributes(first_name: "")).should_not be_valid
    end

    it "isn't valid unless we have a last name" do
      User.new(valid_attributes(last_name: " ")).should_not be_valid
    end
  end

  describe "affiliation (place of work)" do
    subject { User.create!(valid_attributes(affiliation: "The Sainsbury Laboratory")) }
    its(:affiliation) { should eq "The Sainsbury Laboratory" }
  end

  describe "role" do
    subject { User.create!(valid_attributes(role: "Scientist")) }
    its(:role) { should eq "Scientist" }
  end

  describe "admin" do
    it "is false by default" do
      User.new(valid_attributes).should_not be_admin
    end

    it "can be set to true" do
      user = User.new(valid_attributes)
      user.admin = true
      user.should be_admin
    end

    it "can be set to false, once true" do
      user = User.new(valid_attributes)
      user.admin = true
      user.should be_admin
      user.admin = false
      user.should_not be_admin
    end

    it "can be set to by update_attributes" do
      user = User.create!(valid_attributes)
      user.update_attributes(admin: true)
      User.find(user.id).should be_admin
    end
  end

  describe "persistence", versioning: true do
    subject { User.new(valid_attributes) }

    before(:each) do
      subject.save!
    end
        
    it_behaves_like "a model with versioning" do
      let(:attributes_to_update) { 
        {
          first_name: "Frederick",
          last_name:  "Blogger"
        }  
      }

      let(:changeset) { 
        {
          "first_name" => [ "Fred", "Frederick" ],
          "last_name" => [ "Bloggs", "Blogger" ]
        }
      }
    end
  end
end
