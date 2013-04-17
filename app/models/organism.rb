class Organism < ActiveRecord::Base
  validates_presence_of :genus, :species
  attr_accessible :genus, :species, :strain, :pv, :taxid 

  has_paper_trail
end
