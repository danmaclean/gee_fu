class Parent < ActiveRecord::Base
  has_and_belongs_to_many :features


def parent_obj
  Feature.find(:first, :conditions => {:id => self.parent_feature} )
end


end