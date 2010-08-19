#require "#{RAILS_ROOT}/lib/bio/db/sam"
#require 'json'

#Defines the Feature object. 
#Implements methods for finding features in ranges and returning information.
#Also defines some methods for AnnoJ formatting
class Feature < ActiveRecord::Base
  belongs_to :assembly
  belongs_to :experiment
  has_and_belongs_to_many :parents
  before_destroy :destroy_parents

  class << self;
  #  #The read types classed as valid: SO:0001423 dye_terminator_read SO:0001424 pyrosequenced_read SO:0001425 ligation_based_read SO:0001426 polymerase_synthesis_read SO:0000150 read 
    attr_accessor :allowed_read_types 
  end
  @allowed_read_types = %w[SO:0001423 dye_terminator_read SO:0001424 pyrosequenced_read SO:0001425 ligation_based_read SO:0001426 polymerase_synthesis_read SO:0000150 read]
  
  #Returns an array of feature objects in experiment id on reference between start and stop. 
  # use Feature.find_in_range(Chr1, 1000, 2000, 3). 
  # Returned features may overlap the start and stop
  def self.find_in_range(seqid, start, stop, id) 
     experiment = Experiment.find(id)
     if experiment.uses_bam_file?
       Feature.find_by_bam(seqid,start,stop,id)
     else
       Feature.find_by_sql(
       "select * from features where 
       seqid = '#{seqid}' and 
       start <= '#{stop}' and 
       end >= '#{start}' and 
       experiment_id = '#{id}'  
       order by start asc, end desc"
       )
     end
  end
   
  #Returns an array of feature objects in experiment id on reference between start and stop. 
  # use Feature.find_in_range(Chr1, 1000, 2000, 3). 
  # Returned features are fully contained within start and stop
  def self.find_in_range_no_overlap(seqid, start, stop, id)
        experiment = Experiment.find(id)
        if experiment.uses_bam_file?
          Feature.find_by_bam(seqid,start,stop,id)
        else
          Feature.find_by_sql(
          "select * from features where 
          seqid = '#{seqid}' and 
          start <= '#{stop}' and 
          start >= '#{start}' and
          end >= '#{start}' and 
          end <= '#{stop}' and 
          experiment_id = '#{id}'  
          order by start asc, end desc")
        end
  end

  #Returns an array of feature objects from a BAM file on reference between start and stop. 
  # use Feature.find_by_bam_file(Chr1, 1000, 2000, 3). 
  # Not normally called manually, usually called via Feature.find_in_range or Feature.find_in_range_no_overlap Returned features may overlap the start and stop
  def self.find_by_bam(seqid,start,stop,id)
      require "#{RAILS_ROOT}/lib/bio/db/sam"
       experiment = Experiment.find(id)
       ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ seqid }", "#{experiment.genome_id}"])
       sam = Bio::DB::Sam.new({:bam=>experiment.bam_file_path})
       features = []
       sam.open       
       fetchAlignment = Proc.new do |a|
         a.query_strand ? strand = '+'  : strand = '-'       
         features << Feature.new(
           :seqid => ref.name,
           :start => a.pos - 1,
           :end => a.calend,
           :strand => strand,
           :sequence => a.seq,
           :quality => a.qual,
           :feature => 'read',
           :source => 'bam_file',
           :phase => '.',
           :score => '.',
           :experiment_id => id,
           :gff_id => nil,
           :reference_id =>  ref.id 
         )   
         0  
       end
      
       
       sam.fetch_with_function(ref.name, start, stop, fetchAlignment)
       
       sam.close
       features
  end
  
  #Removes the current objects parent features from the database. 
  # use feature.destroy_parents
  def destroy_parents
    parents = Parent.find(:all, :conditions => {:parent_feature => self.id})
    parents.each {|p| p.destroy}
  end


  #Returns the value of the GFF Name attribute for the current object. 
  #If Name is not defined returns the string ‘no name’ 
  # use feature.name => ‘RuBisCo
  def name
    JSON.parse(self.group).each{|a| return a.last if a.include?('Name')}
    'no name'
  end
  
  #Returns the value of the GFF Description attribute for the current object. 
  #If Description is not defined returns the whole Group attribute as JSON format 
  #EG feature.description => ‘Ribulose-1,5-bisphosphate carboxylase oxygenase, enzyme involved in the Calvin cycle‘
  def description
    require 'json'
    attributes = JSON.parse(self.group)
    b = []
    attributes.each {|a| b << a.join(" = ") }
    b.join("\n")
    
  end
  #Returns a hash formatted version of the current object for AnnoJ, not normally used outside this context
  def to_lookup
    row = {}
    row[:id] = self.gff_id
    row[:assembly] = self.seqid
    row[:start] = self.start
    row[:description] = self.description
    row
  end
  #Deprecated, use has_parent? instead
  def has_parents?
    if Parent.find :first, :conditions => {:feature_id => self.id}
      true
    else
      false
    end
  end
  #Checks to see whether the current object has a parent feature in the database. Returns true if it does, false otherwise
  def has_parent?
    not self.parents[0].nil?
  end
  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this context
  def to_box
    if self.id.nil?
      [self.object_id.to_s, self.start, (self.end - self.start) - 1, '1', '1', ""]
    else
      [self.id, self.start, (self.end - self.start) - 1, '1', '1', ""]
    end
  end
  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this context
  def to_read
    if self.id.nil? 
      [self.object_id.to_s, self.start, (self.end - self.start) - 1, '1', '1', self.sequence]
    else
      [self.id, self.start, (self.end - self.start) - 1, '1', '1', self.sequence]
    end
  end
  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this contex
  def to_annoj
     ##this is the list of features that will be grouped for parenting in AnnoJ. Can be extended...
     ## why is there a list? why not all parented features??? 
      #case self.feature
      #when 'intron', 'exon', 'CDS', 'five_prime_UTR', 'three_prime_UTR', 'start_codon', 'stop_codon', 'match_part'
        if self.has_parent?
          [Feature.find(self.parents[0].parent_feature).gff_id, self.id, self.strand, self.feature, self.start, self.end - self.start + 1]
        else
          [nil, self.gff_id, self.strand, self.feature, self.start, self.end - self.start + 1]
        end
      #else
      # [nil, self.gff_id, self.strand, self.feature, self.start, self.end - self.start + 1]
      #end
  end
end