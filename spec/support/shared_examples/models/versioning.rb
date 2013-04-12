shared_examples_for "a model with versioning" do
  it "supports PaperTrail", versioning: true do
    subject.versions.count.should eq 1
    subject.update_attributes(attributes_to_update)
    subject.versions.count.should eq 2
    subject.versions.last.changeset.should eq(changeset)
  end
end
