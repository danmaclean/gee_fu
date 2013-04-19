require 'organism_attributes'
require 'genome_repository'

class OrganismRepository
  attr_reader :organism, :repo_path
  def initialize(organism, repo_path)
    @organism  = organism
    @repo_path = repo_path
  end

  def create
    FileUtils.mkdir_p(organism_directory)
    # TODO - put the 'info' in here?
    # TODO - iterate over the genomes for the organism and create the folders
    # have it remove unused folders, per the RootRepository
    GenomeRepository.new(organism, organism_directory).create
  end

  def folder_name
    OrganismAttributes.new(organism).combine
  end

  def organism_directory
    "#{repo_path}/#{folder_name}"
  end
end