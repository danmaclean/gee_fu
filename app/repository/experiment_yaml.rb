require 'version_info'

class ExperimentYaml
  attr_reader :experiment
  def initialize(experiment)
    @experiment = experiment
  end

  def dump
    {
      "experiment" => {
        "Name"            => experiment.name,
        "Description"     => experiment.description,
        "Last updated by" => version_info.user_name,
        "Last updated on" => version_info.last_updated_on
      }
    }.to_yaml
  end

  private

  def version_info
    @version_info ||= VersionInfo.new(experiment)
  end
end