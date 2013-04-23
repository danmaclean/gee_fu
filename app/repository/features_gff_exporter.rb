class FeaturesGffExporter
  attr_reader :experiment
  def initialize(experiment)
    @experiment = experiment
  end

  def export
    experiment.features.map { |feature| feature.to_gff }.join("\n")
  end
end