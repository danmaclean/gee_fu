require 'root_repository'

class DataRepositoryWorker
  include Sidekiq::Worker

  def perform
    RootRepository.new("#{Rails.root}/#{GeeFu::Application.app_config[:repository_directory]}").create
  end
end