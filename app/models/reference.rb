class Reference < ActiveRecord::Base
  has_many :features
  has_one :sequence
end
