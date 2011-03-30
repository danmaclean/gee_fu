#Implements a controller for custom web tools that act on the database
class ToolsController < ApplicationController
  
  def index
    @genomes = Genome.find(:all)
    @experiments = Experiment.find(:all)
  end
  #Returns a web form view that allows definition of a section of genomic reference sequence
  # use /tools/genome_sequence
  def genomic_sequence
    require 'bio'

    ref = Reference.find(:first, :conditions => {:name => params[:reference] , :genome_id => params[:id] } ) 
    
    @result = Hash.new
    
    if not ref.nil?
      seq = Bio::Sequence::NA.new("#{ref.sequence.sequence.to_s}")
      start = params[:start].to_i ||= 1
      stop = params[:end].to_i ||= seq.length
      @subseq = seq.subseq(start, stop)
      strand = params[:strand] ||= 'plus'
      if strand == 'minus'
        @subseq = @subseq.reverse_complement
      end
    end
    id = ref.name + ' ' + start.to_s + '..' + stop.to_s + ' ' + strand
    render :text => @subseq.to_fasta(id, 60), :content_type => 'text/plain'
    
  end
  
  def export
    @export = Export.new({'export_format' => params['export_format'],
                         'genome_id' => params['genome_id'],
                         'destination' => params['destination']}
                        )
    if params['yaml_file']                    
      @export.yaml_file = params['yaml_file']['yaml_file'].path
    else
      @export.yaml_file = nil
    end
    params.delete_if {|key, value| key !~ /^experiment/ }   #=> {"a"=>100}                   
    @export.experiment_ids = params.values.collect! {|v| v.to_i } 

  
    @features = get_features(@export.genome_id, @export.experiment_ids) #[]
    if @export.export_format == 'gff' #and @export.destination == 'browser'
      @features.collect! {|f| f.to_gff}
      if @export.destination == 'browser'
        render :text => @features.join("\n"), :content_type => 'text/plain'
      else #@export_destination == "server_direct"
        filename = Time.now.strftime("%H%M%S_%d%m%y") + '.txt'
        File.open("#{RAILS_ROOT}/public/exports/#{filename}", 'w') {|f| f.write(@features.join("\n"))}
        @export.filenames << filename
        respond_to do |format|
          format.html 
        end
      end
    elsif @export.export_format == 'embl' or @export.export_format == 'genbank'
       m = MappedFeature.new(:embl)
       @results = []
       if @export.yaml_file
         @export.meta = YAML::load_file(@export.yaml_file)
       else
         @export.meta = {'references'=> [], 'data_class' => nil, 'topology' => nil, 'molecule_type' => nil, 
                          'sequence_version' => nil, 'species' => nil, 'division' => nil, 'definition' => nil, 
                          'keywords' => nil, 'comments' => 'nil', 'locus_tag_prefix' => nil
                        }
        end
       reference_list = []
       locus_number = 10
       parent_features = Hash.new
       @export.meta['references'].each {|r| reference_list << Bio::Reference.new(r) } if @export.meta['references'].instance_of?(Array)
       g = Genome.find(@export.genome_id)
       g.references.each do |r|
         s = Bio::Sequence.new(r.sequence.sequence.to_s) 
         s.references = reference_list
         s.data_class = @export.meta['data_class']
         s.topology = @export.meta['topology']
         s.molecule_type = @export.meta['molecule_type']
         s.sequence_version = @export.meta['sequence_version']
         s.species = @export.meta['species']
         s.division = @export.meta['division']
         s.definition = @export.meta['definition']
         s.keywords = @export.meta['keywords']
         s.comments = @export.meta['comments']
         s.features = []
         r.features.each do |f|
          locus_tag = "%06d" % locus_number 
          next unless @export.experiment_ids.include?(f.experiment_id)
          #only gene features have 'children' in embl/genbank ie CDS,mRNA gets locus_tag of gene it is in, anything else gets locus_tag of its own
          parent_features[f] = locus_number if f.feature == 'gene'
          position = "#{f.start}..#{f.end}"
          position =  "complement(#{f.start}..#{f.end})" if f.strand == '-'
          
          #map presumed SO term to embl term .. if no embl term use misc_feature
          embl_term = m.map_term(f.feature) || 'misc_feature'
          feature = Bio::Feature.new(embl_term,position)
          attributes = []
          begin 
            attributes = JSON.parse(f.group)
          rescue JSON::ParserError #weird characters screw this up sometimes...
            #attributes = []
          end
          attributes.each do |a|
            #map gff attribute to qualifier if possible, if not and not a legal qualifier, skip
            if m.mappable_gff_attribute(a.first)
              feature.append( Bio::Feature::Qualifier.new(m.mappable_gff_attribute(a.first), a.last) )
            elsif m.has_qualifier?(embl_term,a.first.downcase)
              feature.append( Bio::Feature::Qualifier.new(a.first.downcase, a.last) )
            end
          end
          #find or make and add the appropriate locus tag
          if f.has_parent?
            f.parents.each do |p|
              o = Feature.find(p.parent_feature) ##mrna has gene as parent in gff
              if o.feature == 'gene'
                locus_tag = "%06d" % parent_features[o] #feature should only have one gene parent...  
              elsif o.has_parent?
                o.parents.each do |op|
                  j = Feature.find(op.parent_feature) ##but cds has mRNA as parent.. so go 1 deeper...
                  if j.feature == 'gene'
                    locus_tag = "%06d" % parent_features[j]
                  end
                end
              end
            end
          end
          
          locus_tag =  (@export.meta['locus_tag_prefix'] + '_' + locus_tag) if @export.meta['locus_tag_prefix'] 
          feature.append( Bio::Feature::Qualifier.new('locus_tag', locus_tag) )
          s.features << feature
          locus_number = locus_number + 10 unless f.has_parent?
         end
         @results << s.output(@export.export_format)
       end
       if @export.destination == 'browser'
          render :text => @results.join("\n"), :content_type => 'text/plain'
       else
         filename = Time.now.strftime("%H%M%S_%d%m%y") + '.txt'
         File.open("#{RAILS_ROOT}/public/exports/#{filename}", 'w') {|f| f.write(@results.join("\n"))}
         @export.filenames << filename
         respond_to do |format|
           format.html 
         end
       end
    end
    
    
    
  end
  
  private
  def get_features(genome_id, experiment_ids)
    features = []
    g = Genome.find(genome_id)
    g.references.each do |r| 
      r.features.each do |feature|
        features << feature if experiment_ids.include?(feature.experiment_id)
      end
    end
    features
  end
  
end

