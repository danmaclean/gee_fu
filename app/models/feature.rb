#require "#{RAILS_ROOT}/lib/bio/db/sam"
#require 'json'

#Defines the Feature object. 
#Implements methods for finding features in ranges and returning information.
#Also defines some methods for AnnoJ formatting
class Feature < ActiveRecord::Base
  include Concerns::Versioning

  belongs_to :assembly
  belongs_to :experiment
  has_and_belongs_to_many :parents
  #before_destroy :destroy_parents
  has_and_belongs_to_many :predecessors

  attr_accessible :group, :feature, :source, :start, :end, :strand, :phase,
                  :seqid, :score, :gff_id, :sequence, :quality, :reference_id, :experiment

  has_paper_trail

  class << self;
    #  #The read types classed as valid: SO:0001423 dye_terminator_read SO:0001424 pyrosequenced_read SO:0001425 ligation_based_read SO:0001426 polymerase_synthesis_read SO:0000150 read
    attr_accessor :allowed_read_types, :aggregate_features
  end
  @allowed_read_types = %w[SO:0001423 dye_terminator_read SO:0001424 pyrosequenced_read SO:0001425 ligation_based_read SO:0001426 polymerase_synthesis_read SO:0000150 read]
  #@aggregate_features = %w[intron exon CDS five_prime_UTR three_prime_UTR start_codon stop_codon match_part]

  def self.aggregate_features
    %w[intron exon CDS five_prime_UTR three_prime_UTR start_codon stop_codon match_part]
  end

  #Returns an array of feature objects in experiment id on reference between start and stop. 
  # use Feature.find_in_range(reference_id, 1000, 2000, 3). 
  # Returned features may overlap the start and stop at either or both ends
  def self.find_in_range(reference_id, start, stop, experiment_id)
    experiment = Experiment.find(experiment_id)
    if experiment.uses_bam_file?
      Feature.find_by_bam(reference_id, start, stop, experiment_id)
    else
      Feature.find_by_sql(
          "select * from features where
       reference_id = '#{reference_id}' and 
       start <= '#{stop}' and 
       end >= '#{start}' and 
       experiment_id = '#{experiment_id}'  
       order by start asc, end desc"
      )
    end
  end

  #Returns an array of feature objects in experiment id on reference between start and stop. 
  # use Feature.find_in_range(reference_id, 1000, 2000, 3). 
  # Returned features are fully contained within start and stop
  def self.find_in_range_no_overlap(reference_id, start, stop, experiment_id)
    experiment = Experiment.find(experiment_id)
    if experiment.uses_bam_file?
      Feature.find_by_bam(reference_id, start, stop, experiment_id)
    else
      _start = start
      _experiment_id = experiment_id
      _reference_id = reference_id
      Feature.where { |f|
        (f.experiment_id == _experiment_id) & (f.reference_id == _reference_id) &
            (f.start >> (_start..stop)) & (f.end >> (_start..stop))
      }.order { |f| [f.start.asc, f.end.desc] }
    end
  end

  #Returns an array of feature objects from a BAM file on reference between start and stop. 
  # use Feature.find_by_bam_file(reference_id, 1000, 2000, 3). 
  # Not normally called manually, usually called via Feature.find_in_range or Feature.find_in_range_no_overlap Returned features may overlap the start and stop
  def self.find_by_bam(reference_id, start, stop, experiment_id)
    require 'bio-samtools'
    experiment = Experiment.find(experiment_id)
    ref = Reference.find(reference_id); #(:first, :conditions => ["name = ? AND genome_id = ?", "#{ seqid }", "#{experiment.genome_id}"])
    sam = Bio::DB::Sam.new({:bam => experiment.bam_file_path})
    features = []
    sam.open
    fetchAlignment = Proc.new do |a|
      a.query_strand ? strand = '+' : strand = '-'
      features << LightFeature.new(
          :seqid => ref.name,
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
          :reference_id => ref.id
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
    parents.each { |p| p.destroy }
  end


  #Returns the value of the GFF Name attribute for the current object. 
  #If Name is not defined returns the string ‘no name’ 
  # use feature.name => ‘RuBisCo
  def name
    JSON.parse(self.group).each { |a| return a.last if a.include?('Name') }
    'no name'
  end

  #Returns the value of the GFF Description attribute for the current object. 
  #If Description is not defined returns the whole Group attribute as JSON format 
  #EG feature.description => ‘Ribulose-1,5-bisphosphate carboxylase oxygenase, enzyme involved in the Calvin cycle‘
  def description
    require 'json'
    attributes = JSON.parse(self.group)
    b = []
    attributes.each { |a| b << a.join(" = ") }
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

  #returns true if self has one or more children
  def has_child?
    self.children.length > 0 ? true : false
  end

  #returns true if self has one or more children
  def has_children?
    self.has_child?
  end

  #returns a list of all child feature objects for self
  def children
    begin
      Parent.find(:first, :conditions => {:parent_feature => self.id}).features
    rescue
      []
    end
  end

  #returns a list of all descendants of self, sorted by start position
  def descendants
    queue = [self]
    descendants = [self]
    while f = queue.shift
      queue = queue + f.children
      descendants = descendants + f.children
    end
    descendants.uniq.sort { |x, y| x.start <=> y.start }
  end

  #returns true if the current feature has at least one parent in the range provided
  def has_parent_in_range(start, stop)
    self.parents.each do |p|
      if p.parent_obj.start >= start.to_i and p.parent_obj.end <= stop.to_i
        return true
      end
    end
    false
  end

  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this context
  def to_box
    if self.id.nil?
      [self.object_id.to_s, self.start + 1, (self.end - self.start) - 1, '1', '1', ""]
    else
      [self.id, self.start + 1, (self.end - self.start) - 1, '1', '1', ""]
    end
  end

  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this context
  def to_read
    if self.id.nil?
      [self.object_id.to_s, self.start + 1, (self.end - self.start) - 1, '1', '1', self.sequence]
    else
      [self.id, self.start + 1, (self.end - self.start) - 1, '1', '1', self.sequence]
    end
  end

  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this contex
  def to_annoj
    ##this is the list of features that will be grouped for parenting in AnnoJ. Can be extended...
    ## why is there a list? why not all parented features??? - Its an AnnoJ thing, it overlies some valid features
    ## with the same parent, this is a kludge for the most common feature types that will get parented.
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

  #formats the object for view in the features view
  def to_view
    [self.id, self.gff_id, self.strand, self.feature, self.start, self.end]
  end

  #returns a 'gff-like' tab delimited string version of the feature, I make no guarantees that this is fully gff3 compatible, its a utility method. GFF3 compliance is *your* responsiblity.
  def to_gff(kw={})

    ref = Reference.find(self.reference_id)
    attributes = []
    if kw[:add_db_id_to_attrs]
      attributes = ['gfu_id=' + self.id.to_s]
    end
    JSON.parse(self.group).each { |x| attributes << x.join('=') }
    name = ref.name
    self.source = '.' if self.source == ''
    self.feature = '.' if self.feature == ''
    self.start = '.' if self.start == ''
    self.stop = '.' if self.end == ''
    self.score = '.' if self.score == ''
    self.strand = '.' if self.strand == ''
    self.phase = '.' if self.phase == ''

    "#{name}\t#{self.source}\t#{self.feature}\t#{self.start}\t#{self.end}\t#{self.score}\t#{self.strand}\t#{self.phase}\t#{attributes.join(';')}#{version_info_as_gff}"
  end

  private

  def version_info_as_gff
    return if version_info.unknown?
    ";updated_by=#{version_info.user_name_with_email};updated_on=#{version_info.last_updated_on}"
  end

  def version_info
    @version_info ||= VersionInfo.new(self)
  end
end