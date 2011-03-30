#Implements a controller for exporting data to flat files, eg for conversion to EMBL format
class ExportsController < ApplicationController
  
  def index
    @genomes = Genome.find(:all)
    @experiments = Experiment.find(:all)
  end
  
  #manages the export according to the params hash, when values not provided assumes first genome, all non-bam file experiments and embl format
  def export
    @export = Export.new({'yaml_file' => params['yaml_file'],
                         'export_format' => params['export_format'],
                         'genome_id' => params['genome_id'],
                         'destination' => params['destination']}
                        )
    
    params.delete_if {|key, value| key !~ /^experiment/ }   #=> {"a"=>100}                   
    @export.experiment_ids = params.values 
  
    @features = get_features(@export.genome_id, @export.experiment_ids)
    if @export.export_format == 'gff'
      dump_tab(@export.genome_id, @export.destination)
    end
    
    #respond_to do |format|
    #  format.html { render :html => @export }
    #end  
    
    
  end
  
  private
  def get_features(genome_id, experiments)
    features = []
    g = Genome.find(genome_id)
    g.references.each do |r| 
      r.features.each do |feature|
        features << feature if experiments.include?(feature.experiment_id)
      end
    end
    features
  end
  #dumps a whole genome version and its annotations as a gff file... 
  def dump_tab(genome_id, destination)
    if destination == 'browser'
      @features.collect! {|f| f.to_gff}.join("\n") 
      respond_to do |format|
        format.html { render @features, :layout => false }
      end
    else
      
    end
    #exports a generic 'gff-style' tab delimited file of features and sequences for a given genome 
  end
  
  #
  def embl
  end
  #exports a json format file of complex annotations for reformatting eg to EMBL format, DOES NOT group parented features into their parent, since these are all flattened out in EMBL anyway 
  #def dump
  #  @genome.references.each do |ref|
  #    annotated_reference = {:sequence => reference.sequence.sequence, :id => nil, :features => [] }
  #    ref.features.each do |feat|
  #      feat.group = JSON.parse(feat.group)
  #      annotated_reference
  #end
end