require 'spec_helper'
require 'sidekiq/testing'

describe DataRepositoryWorker do
  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  let(:root_repository) { mock(RootRepository, create: :specified_later) }

  it "uses a DataRepositoryCreator to do the work" do
    RootRepository.should_receive(:new).with(full_repo_path).and_return(root_repository)
    root_repository.should_receive(:create)
    subject.perform
  end
end