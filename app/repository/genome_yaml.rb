require 'version_info'

class GenomeYaml
  attr_reader :genome
  def initialize(genome)
    @genome = genome
  end

  def dump
    {
      "genome" => {
        "Build version"   => genome.build_version,
        "Last updated by" => version_info.user_name_with_email,
        "Last updated on" => version_info.last_updated_on
      }
    }.to_yaml
  end

  private

  def version_info
    VersionInfo.new(genome)
  end
end