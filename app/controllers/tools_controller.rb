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
    @export = Export.new({'yaml_file' => params['yaml_file']['yaml_file'].path,
                         'export_format' => params['export_format'],
                         'genome_id' => params['genome_id'],
                         'destination' => params['destination']}
                        )
    
    params.delete_if {|key, value| key !~ /^experiment/ }   #=> {"a"=>100}                   
    @export.experiment_ids = params.values.collect! {|v| v.to_i } 
    #@export.filename = 'filename'
  
    @features = get_features(@export.genome_id, @export.experiment_ids) #[]
    if @export.export_format == 'gff' #and @export.destination == 'browser'
      #g = Genome.find(@export.genome_id)
      #g.references.each do |r| 
      #  r.features.each do |feature|
      #    @features << feature if @export.experiment_ids.include?(feature.experiment_id)
      #  end
      #end
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
    elsif @export.export_format == 'embl'
       @results = []
       @export.meta = YAML::load_file(@export.yaml_file)
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
         #s.features = []
         #r.features.each do |f|
        #  feature = Bio::Feature.new(f.feature,"#{f.start}..#{f.end}")
        #  attributes = JSON.parse(f.group)
        #  attributes.each{|a| feature.append( Bio::Feature::Qualifier.new(a.first, a.last) )}
        #  s.features << f
        # end
         @results << s.output(:embl)
       end
       if @export.destination == 'browser'
          render :text => @results.join("\n"), :content_type => 'text/plain'
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

