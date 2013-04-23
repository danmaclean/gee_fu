class PredecessorsGffExporter
  attr_reader :experiment
  def initialize(experiment)
    @experiment = experiment
  end

  def export
    experiment.features.map do |feature| 
      feature.predecessors.map do |predecessor| 
        predecessor.to_gff
      end
    end.flatten.join("\n")
  end
end