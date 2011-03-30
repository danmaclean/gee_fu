class Predecessor < ActiveRecord::Base
  has_and_belongs_to_many :feaures
  
  def description
    require 'json'
    attributes = JSON.parse(self.group)
    b = []
    attributes.each {|a| b << a.join(" = ") }
    b.join("\n")
    
  end
  
end

