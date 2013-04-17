class Genome < ActiveRecord::Base
  has_many :references, :dependent => :destroy

  validates_presence_of :build_version
  validates_presence_of :fasta_file
  
  attr_accessor   :fasta_file, :yaml_file
  attr_accessible :build_version, :fasta_file, :yaml_file, :meta

  has_paper_trail
  
  def html_meta
    self.meta ? self.meta.to_yaml.gsub!(/\n/,"<br/>").gsub!(/\s/,"&nbsp;").html_safe : ''
  end
  
  def meta_as_data_structure
    self.meta ? JSON::parse(self.meta) : nil
  end
end
