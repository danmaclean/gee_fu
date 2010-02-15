class Feature < ActiveRecord::Base
  belongs_to :assembly
  belongs_to :experiment
  has_and_belongs_to_many :parents
  before_destroy :destroy_parents
  
  class << self; attr_accessor :allowed_read_types end
  @allowed_read_types = %w[SO:0001423 dye_terminator_read SO:0001424 pyrosequenced_read SO:0001425 ligation_based_read SO:0001426 polymerase_synthesis_read SO:0000150 read]
  
  def destroy_parents
    parents = Parent.find(:all, :conditions => {:parent_feature => self.id})
    parents.each {|p| p.destroy}
  end


  
  def name
  require 'json'
    JSON.parse(self.group).each{|a| return a.last if a.include?('Name')}
    'no name'
  end
  
  def description
    require 'json'
    JSON.parse(self.group).each{|a| return a.last + 'Name = ' + self.name.to_s + ' GFF3 = ' + self.group if a.include?('Note')}
    'Name = ' + self.name + ' GFF3 = ' + self.group
  end
  def to_lookup
    row = {}
    row[:id] = self.gff_id
    row[:assembly] = self.reference
    row[:start] = self.start
    row[:description] = self.description
    return row
  end
  def has_parents?
    if Parent.find :first, :conditions => {:feature_id => self.id}
      true
    else
      false
    end
  end
  def to_box
    [self.id, self.start, (self.end - self.start) - 1, '1', '1', ""]
  end
  def to_read
      [self.id, self.start, (self.end - self.start) - 1, '1', '1', self.sequence]
  end
  def to_annoj
    case self.feature
    when 'intron', 'exon', 'CDS', 'five_prime_UTR', 'three_prime_UTR'
      [Feature.find(self.parents[0].parent_feature).gff_id, self.id, self.strand, self.feature, self.start, self.end - self.start + 1]
    else
      [nil, self.gff_id, self.strand, self.feature, self.start, self.end - self.start + 1]
    end
  end

 # def to_annoj
 #      if self.feature.match("mRNA") or self.feature.match("gene") or self.feature.match("protein") ###shouldnt this be simply "is parent?"
 #       ['null', self.name, self.strand, self.feature, self.start, self.end - self.start + 1]
 #      else
 #       [Feature.find(self.parents[0].feature_id).name, self.id, self.strand, self.feature, self.start, self.end - self.start + 1]
#    end
  #end
  
  
  
  
end