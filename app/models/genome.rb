require 'bio'
require 'reference'

class Genome < ActiveRecord::Base
  include Concerns::Versioning

  belongs_to :organism
  has_many :references, :dependent => :destroy
  has_many :experiments

  validates :build_version, presence: true, uniqueness: { scope: :organism_id, message: "Build version must be unique to a genome" }
  validates_presence_of :fasta_file
  
  attr_accessor   :fasta_file, :yaml_file
  attr_accessible :build_version, :fasta_file, :yaml_file, :meta, :organism_id

  has_paper_trail

  def to_s
    "#{organism.local_name} / #{build_version}"
  end

  def to_fasta
    #references.map { |reference|
    #  Bio::Sequence::NA.new(reference.sequence.sequence).to_fasta(reference.name, 60)
    #}.join("\n")
    
    #to_fasta is deprecated
    references.map { |reference|
      Bio::Sequence::NA.new(reference.sequence.sequence).output_fasta(reference.name, 60)
    }.join("\n")
  end
  
  def html_meta
    self.meta ? self.meta.to_yaml.gsub!(/\n/,"<br/>").gsub!(/\s/,"&nbsp;").html_safe : ''
  end
  
  def meta_as_data_structure
    self.meta ? JSON::parse(self.meta) : nil
  end
end
