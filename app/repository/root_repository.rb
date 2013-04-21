require 'organism_repository'

class RootRepository
  attr_reader :repo_path
  def initialize(repo_path)
    @repo_path = repo_path
  end

  def create
    make_repo
    remove_unused_organism_folders
    make_organism_folders
  end

  private

  def repo(other_path="")
    "#{repo_path}/#{other_path}"
  end

  def make_repo
    FileUtils.mkdir_p(repo)
  end

  def make_organism_folders
    Organism.all.each do |organism|
      OrganismRepository.new(organism, repo).create
    end
  end

  def existing_organism_folders
    Organism.all.map(&:local_name)
  end

  def remove_unused_organism_folders
    repo_root_directories.each do |dir|
      FileUtils.rm_r(repo(dir)) unless existing_organism_folders.include?(dir)
    end
  end

  def repo_root_directories
    Dir.chdir(repo) do
      Dir.glob("*").select { |entry| File.directory?(entry) }
    end
  end
end 