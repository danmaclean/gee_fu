class Experiment < ActiveRecord::Base
  has_many :features, :dependent => :destroy
  belongs_to :genome
end