class Export
#  validate :yaml_provided_when_embl_or_genbank_format_requested
#  validates_presence_of :genome_id, :experiment_ids, :destination

  attr_accessor :yaml_file, :export_format, :genome_id, :experiment_ids, :destination, :filenames, :meta

  def initialize(opts)
    @filenames = []
    @yaml_file = opts['yaml_file'] || nil
    @export_format = opts['export_format'] || nil
    @genome_id = opts['genome_id'] || nil
    @experiment_ids = opts['experiment_ids'] || nil
    @destination = opts['destination'] || nil
  end
end