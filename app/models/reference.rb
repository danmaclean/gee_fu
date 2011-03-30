class Reference < ActiveRecord::Base
  has_many :features
  has_one :sequence, :dependent => :destroy
  
  #a holder method for the REST interface, allows use of reference.ref_seq attribute when GET parameter sequence=true and thereby returns the sequence as part of the same object..
  attr_accessor :ref_seq

end
