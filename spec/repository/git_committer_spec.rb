require 'spec_helper'

describe GitCommitter do
  let(:repo_path)       { GeeFu::Application.app_config[:repository_directory] }
  let(:full_repo_path)  { "#{Rails.root}/#{repo_path}" }

  it "should exist" do
    -> { GitCommitter.new(full_repo_path).commit }.should_not raise_error
  end

  it "fails" do
    fail "work out how to mock git actions (using Grit)?"
  end
end