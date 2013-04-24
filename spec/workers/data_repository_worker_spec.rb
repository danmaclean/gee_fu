require 'spec_helper'
require 'sidekiq/testing'

describe DataRepositoryWorker do
  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  let(:root_repository) { mock(RootRepository, create: :specified_later) }
  let(:git_committer)   { mock(GitCommitter, commit: :specified_later) }

  before(:each) do
    RootRepository.stub(new: root_repository)
    GitCommitter.stub(new: git_committer)
  end

  it "uses a RootRepository to create the data repository" do
    RootRepository.should_receive(:new).with(full_repo_path).ordered
    root_repository.should_receive(:create).ordered
    GitCommitter.should_receive(:new).with(full_repo_path).ordered
    git_committer.should_receive(:commit).ordered
    subject.perform
  end
end