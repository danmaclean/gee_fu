shared_examples_for "a model with versioning" do
  it "supports PaperTrail", versioning: true do
    subject.versions.count.should eq 1
    subject.update_attributes(attributes_to_update)
    subject.versions.count.should eq 2
    subject.versions.last.changeset.should eq(changeset)
  end
end

shared_examples_for "a model with user audits" do
  describe "#last_updated_by" do
    context "when no one is logged in" do
      it "#last_updated_by is nil" do
        described_class.create!(valid_attributes).last_updated_by.should be_nil
      end
    end

    context "when PaperTrail has a user ID", versioning: true do
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

      before(:each) do
        PaperTrail.whodunnit = user.id
      end
      
      it "is the user" do
        described_class.create!(valid_attributes).last_updated_by.should eq user.id
      end
    end
  end

  describe "#last_updated_on", versioning: true do
    it "is when the model was last updated" do
      time_to_travel_to = Time.new(2013, 19, 4, 12, 0, 0)
      Timecop.freeze(time_to_travel_to) do
        described_class.create!(valid_attributes).last_updated_on.should eq time_to_travel_to
      end
    end

    it "is today" do
      described_class.create!(valid_attributes).last_updated_on.to_date.should eq Time.now.to_date
    end
  end
end