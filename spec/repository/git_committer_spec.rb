require 'spec_helper'
require 'fakefs/spec_helpers'

describe GitCommitter do
  include FakeFS::SpecHelpers

  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  subject { GitCommitter.new(full_repo_path) }

  before(:each) do
    FileUtils.mkdir_p(full_repo_path)
  end

  describe "#commit" do
    it "changes to the data repo folder" do
      Dir.should_receive(:chdir).with(full_repo_path)
      subject.commit
    end

    context "there is a git repo in this folder" do
      before(:each) do
        FileUtils.mkdir_p("#{full_repo_path}/.git")
      end

      it "shells out to git" do
        subject.should_receive(:`).with("git add .").ordered
        subject.should_receive(:`).with("git commit -am 'Update GeeFU data'").ordered
        subject.should_receive(:`).with("git push origin master").ordered
        subject.commit
      end
    end

    context "there is no git repo in this folder" do
      it "doesn't shell out to git" do
        subject.should_not_receive(:`)
        subject.commit
      end
    end
  end
end