namespace :repo do
  desc "Export the database to a repository folder"
  task :export => [:environment] do
    RootRepository.new("#{Rails.root}/#{GeeFu::Application.app_config[:repository_directory]}").create
  end
end