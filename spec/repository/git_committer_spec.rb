require 'spec_helper'

describe GitCommitter do
  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  subject { GitCommitter.new(full_repo_path) }

  describe "#commit" do
    it "exists, testing is done manually" do
      Grit::Repo.should_receive(:new).with(full_repo_path)
      -> { subject.commit }.should_not raise_error
    end
  end
end