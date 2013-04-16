class Predecessor < ActiveRecord::Base
  has_and_belongs_to_many :features
  attr_accessible :seqid, :source, :feature, :start, :end, :score, :strand, :phase,
                  :gff_id, :reference_id, :experiment_id, :created_at, :group, :old_id
  
  def description
    require 'json'
    attributes = JSON.parse(self.group)
    b = []
    attributes.each {|a| b << a.join(" = ") }
    b.join("\n")
  end
  
  def to_gff(kw={})
    ref = Reference.find(self.reference_id)
    attributes = []

    old_id = self.old_id
    old_id = 'nil' if self.old_id.nil?
    attributes << 'old_id=' + old_id.to_s
    self.group = '[]' if self.group.nil?
    JSON.parse(self.group).each {|x| attributes << x.join('=') }
    name = ref.name
    self.source = '.' if self.source == '' 
    self.feature = '.' if self.feature == ''
    self.start = '.' if self.start == ''
    self.stop = '.' if self.end == ''
    self.score = '.' if self.score == ''
    self.strand = '.' if self.strand == ''
    self.phase = '.' if self.phase == ''
    
    "#{name}\t#{self.source}\t#{self.feature}\t#{self.start}\t#{self.end}\t#{self.score}\t#{self.strand}\t#{self.phase}\t#{attributes.join(';')}"
  end
end

