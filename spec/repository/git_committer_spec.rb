require 'spec_helper'

describe GitCommitter do
  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  subject { GitCommitter.new(full_repo_path) }

  describe "#commit" do
    it "changes to the data repo folder" do
      Dir.should_receive(:chdir).with(full_repo_path)
      subject.commit
    end

    it "calls `git add .`" do
      subject.should_receive(:`).with("git add .").ordered
      subject.should_receive(:`).with("git commit -am 'Update GeeFU data'").ordered
      subject.should_receive(:`).with("git push origin master").ordered
      subject.commit
    end
  end
end