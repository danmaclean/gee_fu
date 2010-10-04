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
                          'keywords' => nil, 'comments' => 'nil'
                        }
        end
       reference_list = []
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
          next unless @export.experiment_ids.include?(f.experiment_id)
          position = "#{f.start}..#{f.end}"
          position =  "complement(#{f.start}..#{f.end})" if f.strand == '-'
          
          #map presumed SO term to embl term .. if no embl term use misc_feature
          embl_term = m.map_term(f.feature) || 'misc_feature'
          feature = Bio::Feature.new(embl_term,position)
          attributes = JSON.parse(f.group)
          attributes.each do |a|
            #map gff attribute to qualifier if possible, if not and not a legal qualifier, skip
            if m.mappable_gff_attribute(a.first) 
              feature.append( Bio::Feature::Qualifier.new(m.mappable_gff_attribute(a.first), a.last) )
            elsif m.has_qualifier?(embl_term,a.first.downcase)
              feature.append( Bio::Feature::Qualifier.new(a.first.downcase, a.last) )
            #else #optionally turn unmappable tags to note
              #feature.append( Bio::Feature::Qualifier.new('note', a.join('-') ) )
            end

             
          end
          s.features << feature
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

