require 'root_repository'
require 'git_committer'

class DataRepositoryWorker
  include Sidekiq::Worker

  def perform
    RootRepository.new(repo_path).create
    GitCommitter.new(repo_path).commit
  end

  def repo_path
    "#{Rails.root}/#{GeeFu::Application.app_config[:repository_directory]}"
  end
end