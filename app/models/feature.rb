class Feature < ActiveRecord::Base
  belongs_to :assembly
  belongs_to :experiment
  has_and_belongs_to_many :parents
  before_destroy :destroy_parents
  
  class << self; attr_accessor :allowed_read_types end
  @allowed_read_types = %w[SO:0001423 dye_terminator_read SO:0001424 pyrosequenced_read SO:0001425 ligation_based_read SO:0001426 polymerase_synthesis_read SO:0000150 read]

  def self.find_by_bam(reference,start,stop,bam_file_path,experiment_id,genome_id)
    require "#{RAILS_ROOT}/lib/bio/db/sam"
    reference = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ reference }", "#{genome_id}"])
    sam = Bio::DB::Sam.new({:bam=>bam_file_path})
    features = []
    sam.open
    sam.fetch(reference, start, stop).each do |a|
      a.query_strand ? strand = '+'  : strand = '-'
      features << Feature.new (
        :reference => reference,
        :start => a.pos,
        :end => a.calend,
        :strand => strand,
        :sequence => a.seq,
        :quality => a.qual,
        :feature => 'read',
        :source => 'bam_file',
        :phase => '.',
        :score => '.',
        :experiment_id => experiment_id,
        :gff_id => nil,
        :reference_id =>  reference.id
        
      )
    end
    sam.close
    features
  end
  
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
    JSON.parse(self.group).each{|a| return a.last if a.first.match('Description') }
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
  def has_parent?
    not self.parents[0].nil?
  end
  def to_box
    [self.id, self.start, (self.end - self.start) - 1, '1', '1', ""]
  end
  def to_read
      [self.id, self.start, (self.end - self.start) - 1, '1', '1', self.sequence]
  end
  def to_annoj
      case self.feature
      when 'intron', 'exon', 'CDS', 'five_prime_UTR', 'three_prime_UTR', 'start_codon', 'stop_codon', 'match_part'
        if self.has_parent?
          [Feature.find(self.parents[0].parent_feature).gff_id, self.id, self.strand, self.feature, self.start, self.end - self.start + 1]
        else
          [nil, self.gff_id, self.strand, self.feature, self.start, self.end - self.start + 1]
        end
      else
       [nil, self.gff_id, self.strand, self.feature, self.start, self.end - self.start + 1]
      end
  end
end