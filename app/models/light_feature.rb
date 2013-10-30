class LightFeature
  attr_accessor :seqid, :start, :end, :strand, :sequence, :quality, :feature, :source, :phase, :score, :experiment_id, :gff_id, :reference_id, :group

  @seqid = nil
  @start = nil
  @end = nil
  @strand = nil
  @sequence = nil
  @quality = nil
  @feature = nil
  @source = nil
  @phase = nil
  @score = nil
  @experiment_id = nil
  @gff_id = nil
  @reference_id = nil
  @group = nil

  def initialize(args)
    args.each do |k, v|
      if self.respond_to?(k)
        self.instance_variable_set("@#{k}", v)
      else
        raise ArgumentError, "unknown instance variable #{k}"
      end
    end

  end

  def to_box
    if self.object_id.nil?
      [self.object_id.to_s, self.start, (self.end - self.start) - 1, '1', '1', ""]
    else
      [self.object_id.to_s, self.start, (self.end - self.start) - 1, '1', '1', ""]
    end
  end

  #Returns an array formatted version of the current object for AnnoJ, not normally used outside this context
  def to_read
    if self.object_id.nil?
      [self.object_id.to_s, self.start, (self.end - self.start) - 1, '1', '1', self.sequence]
    else
      [self.object_id, self.start, (self.end - self.start) - 1, '1', '1', self.sequence]
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

  #returns a 'gff-like' tab delimited string version of the feature, I make no guarantees that this is fully gff3 compatible, its a utility method. GFF3 compliance is *your* responsiblity.
  def to_gff
    ref = Reference.find(self.reference_id)
    attributes = []
    JSON.parse(self.group).each { |x| attributes << x.join('=') }
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