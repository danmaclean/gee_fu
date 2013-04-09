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
end
