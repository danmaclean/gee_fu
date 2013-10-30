class Organism < ActiveRecord::Base
  include Concerns::Versioning

  has_many :genomes
  validates :genus, presence: true
  validates :species, presence: true
  validates :strain, presence: true
  validates :taxid, presence: true
  validates :local_name, presence: true
  validates_uniqueness_of :local_name, message: "The local name of the organism must be unique."

  attr_accessible :genus, :species, :strain, :pv, :taxid, :local_name

  has_paper_trail

  def to_s
    local_name
  end
end
