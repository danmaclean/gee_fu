require 'experiment_repository'

class GenomeRepository
  attr_reader :genome, :repo_path
  def initialize(genome, repo_path)
    @genome    = genome
    @repo_path = repo_path
  end

  def create
    create_genome_directory
    remove_unused_experiment_folders
    write_to_yaml(genome, "#{genome_directory}/genome.yml")
    genome.experiments.each do |experiment|
      ExperimentRepository.new(experiment, genome_directory).create
    end
  end

  private

  def create_genome_directory
    FileUtils.mkdir_p(genome_directory)
  end

  def write_to_yaml(genome, path)
    File.open(path, 'w') { |file| file.write GenomeYaml.new(genome).dump } 
  end

  def folder_name
    genome.build_version
  end

  def genome_directory
    repo(folder_name)
  end

  def repo(other_path="")
    "#{repo_path}/#{other_path}"
  end   

  def remove_unused_experiment_folders
    experiment_directories.each do |dir|
      FileUtils.rm_r("#{genome_directory}/#{dir}") unless existing_folders.include?(dir)
    end
  end

  def existing_folders
    genome.experiments.map(&:name)
  end

  def experiment_directories
    Dir.chdir(genome_directory) do
      Dir.glob("*").select { |entry| File.directory?(entry) }
    end
  end

end