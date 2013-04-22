require 'version_info'

class OrganismYaml
  attr_reader :organism
  def initialize(organism)
    @organism = organism
  end

  def dump
    {
      "organism" => {
        "Local name"        => organism.local_name,
        "Genus"             => organism.genus,
        "Species"           => organism.species,
        "Strain"            => organism.strain,
        "Pathovar"          => organism.pv,
        "NCBI Taxonomy ID"  => organism.taxid.to_s,
        "Last updated by"   => version_info.user_name,
        "Last updated on"   => version_info.last_updated_on
      }
    }.to_yaml
  end

  private

  def version_info
    @version_info ||= VersionInfo.new(organism)
  end
end