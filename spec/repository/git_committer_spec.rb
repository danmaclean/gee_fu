require 'spec_helper'

describe GitCommitter do
  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  let(:git_remote)      { mock(Grit::Remote) }
  let(:raw_git)         { mock(Grit::Git, push: :specified_later) }
  let(:grit_repo)       { mock(Grit::Repo, add: :specified_later, commit_all: :specified_later, git: raw_git, remotes: [ git_remote ]) }

  before(:each) do
    Grit::Repo.stub(new: grit_repo)
  end

  subject { GitCommitter.new(full_repo_path) }

  describe "#commit" do
    it "creates a Grit::Repo to do the work" do
      Grit::Repo.should_receive(:new).with(full_repo_path)
      subject.commit
    end

    it "adds all the things then pushes" do
      grit_repo.should_receive(:add).with(".").ordered
      grit_repo.should_receive(:commit_all).with("Update GeeFU data").ordered
      raw_git.should_receive(:push).with({}, git_remote).ordered
      subject.commit
    end
  end
end