require 'experiment_yaml'

class ExperimentRepository
  attr_reader :experiment, :repo_path
  def initialize(experiment, repo_path)
    @experiment = experiment
    @repo_path  = repo_path
  end

  def create
    create_experiment_directory
    write_to_yaml(experiment, "#{experiment_directory}/experiment.yml")
  end

  private

  def create_experiment_directory
    FileUtils.mkdir_p(experiment_directory)
  end

  def write_to_yaml(experiment, path)
    File.open(path, 'w') { |file| file.write ExperimentYaml.new(experiment).dump } 
  end

  def folder_name
    experiment.name
  end

  def experiment_directory
    repo(folder_name)
  end

  def repo(other_path="")
    "#{repo_path}/#{other_path}"
  end   
end