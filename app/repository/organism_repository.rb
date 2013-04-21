require 'genome'
require 'genome_repository'

class OrganismRepository
  attr_reader :organism, :repo_path
  def initialize(organism, repo_path)
    @organism  = organism
    @repo_path = repo_path
  end

  def create
    make_organism_directory
    remove_unused_genome_folders
    write_to_yaml(organism, "#{organism_directory}/organism.yml")

    organism.genomes.each do |genome|
      GenomeRepository.new(genome, organism_directory).create
    end
  end

  private

  def make_organism_directory
    FileUtils.mkdir_p(organism_directory)
  end

  def write_to_yaml(organism, path)
    File.open(path, 'w') { |file| file.write OrganismYaml.new(organism).dump } 
  end

  def folder_name
    organism.local_name
  end

  def organism_directory
    repo(folder_name)
  end

  def repo(other_path="")
    "#{repo_path}/#{other_path}"
  end

  def remove_unused_genome_folders
    genome_directories.each do |dir|
      FileUtils.rm_r("#{organism_directory}/#{dir}") unless existing_folders.include?(dir)
    end
  end

  def existing_folders
    organism.genomes.map(&:build_version)
  end

  def genome_directories
    Dir.chdir(organism_directory) do
      Dir.glob("*").select { |entry| File.directory?(entry) }
    end
  end
end