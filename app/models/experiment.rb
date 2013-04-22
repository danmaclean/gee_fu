class Experiment < ActiveRecord::Base
  include Concerns::Versioning
  
  has_many :features, :dependent => :destroy
  belongs_to :genome

  validates_presence_of :name, :description, :genome_id
  validate              :gff_file_or_bam_file_path_is_provided
  
  attr_accessor   :gff_file, :yaml_file, :expected_file, :find_parents, :merge
  attr_accessible :name, :description, :gff_file, :bam_file_path, :genome_id, :find_parents, :expected_file, :meta

  has_paper_trail
  
  def gff_file_or_bam_file_path_is_provided
    if self.expected_file == "gff"
      errors.add_to_base("A GFF3 file must be provided") unless self.gff_file
    elsif self.expected_file == "bam"
      errors.add_to_base("A path to a BAM file must be provided") if self.bam_file_path == ''
    end
  end
    
  def html_meta
    self.meta ? self.meta.to_yaml.gsub!(/\n/,"<br/>").gsub!(/\s/,"&nbsp;").html_safe : ''
  end
  
  def meta_as_data_structure
    self.meta ? JSON::parse(self.meta) : nil
  end
end