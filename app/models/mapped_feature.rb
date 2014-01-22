#implements an object that knows how to map between Sequence Ontology terms and IDs and other feature lists.
#Currently works with EMBL Feature Table, 

class MappedFeature
  require 'pp'
  attr_accessor :embl_mapping, :mapping, :feature_qualifiers, :format

  GFF_ATTRIBUTE_TO_EMBL_QUALIFIER = {
      'ID' => 'label',
      'Name' => 'standard_name',
      'Dbxref' => 'db_xref',
      'Note' => 'note', ## other gff attributes [Alias, Parent, Target, Gap, Derives_from, Ontology_term, Is_circular] dont map
      'stable_id' => 'locus_tag' ##SL convention
  }

  def initialize(format)
    @format = format
    @mapping = Hash.new { |h, k| h[k] = Hash.new }
    @feature_qualifiers = Hash.new { |h, k| h[k] = Array.new }
    case self.format
      when :embl, :genbank
        File.open("#{RAILS_ROOT}/lib/mappings/embl_FT_SO.txt").each do |l|
          next if l.nil?
          e = l.split(/\t/)
          next if e.nil?
          #pp e[3]
          @mapping[e[1]][:term] = e[0]
          @mapping[e[1]][:def] = e[3]
          @mapping[e[2]][:term] = e[0]
          @mapping[e[2]][:def] = e[3]
        end
        File.open("#{RAILS_ROOT}/lib/mappings/embl_feature_qualifiers.txt").each do |l|
          next if l.nil?
          l.chomp!
          e = l.split(/\s+/)
          e.first.gsub!(/\//, '')
          @feature_qualifiers[e.last] << e.first
        end
    end
  end

  #checks whether a qualifier is allowed for a feature term
  def has_qualifier?(term, qualifier)
    @feature_qualifiers[term].include?(qualifier.downcase) ? true : false
  end

  #provide a term or ID from SO and returns the term from format selected at instantiation
  def map_term(term)
    @mapping[term][:term]
  end

  #provide a term or ID from SO and returns the definition in the format selected at instantiation
  def map_definition(term)
    @mapping[term][:def]
  end

  #provide a GFF attribute, will map to its selected feature table equivalent
  def mappable_gff_attribute(gff_attribute)
    case self.format
      when :embl, :genbank
        GFF_ATTRIBUTE_TO_EMBL_QUALIFIER[gff_attribute]
    end
  end

end

