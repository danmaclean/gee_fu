#Implements the REST requests for the Genomes table/model
#access via url
class GenomesController < ApplicationController
  
  #returns the genome information on an AnnoJ genome request
  # only for use by AnnoJ
  def annoj  #a method for annoj
    genome = Genome.find(params[:id])
    @response = {}
    @response["success"] = true
    @response["data"] = JSON::parse( "#{genome.meta}" ) #{}
    @response["data"]["genome"]["assemblies"] = []
    genome.references.each do |r|
      @response["data"]["genome"]["assemblies"] << {:id => r.name, :size => r.length}
    end
    render :json => @response, :layout => false #render :json => @genome doesnt work because annoj wont accept extra keys made by json-ing of ruby object..
  end

  #returns the list of genomes and associated meta-data in the database
  # use /genomes.format
  # where format = xml or js
  def index #regular web request method
    @genomes = Genome.all
    @genomes.each do |gen|
      gen.meta ? gen.meta = JSON::parse("#{gen.meta}") : nil
    end
    respond @genomes
  end

  #returns metadata for a selected genome 
  # use /genome/id.format
  # where format = xml or json
  def show
    if Genome.exists?(params[:id])
     @genome = Genome.find(params[:id])
     @genome.meta = @genome.meta_as_data_structure     
     respond @genome
    else
      respond :false
    end
  end
  
  def edit
    @genome = Genome.find(params[:id])
  end
  
  def new
    @genome = Genome.new
    respond @genome
  end
  
  #returns a list of references for the genome for the ajax autofill box
  def reference_list
    genomes = Genome.find(params[:id])
    respond genomes.references.collect {|x| x.name }.join(" ")
  end



  def create
    require 'bio'
    @genome = Genome.new(params[:genome])
    
    #fastasavename = rand(1000000).to_s
    #FileUtils.mv @genome.fasta_file.path, "#{RAILS_ROOT}/tmp/#{fastasavename}" if @genome.fasta_file
    #fasta = File.new("#{RAILS_ROOT}/tmp/#{savename}", "r")
   
    #fasta = params[:genome][:fasta_file]
    #yaml = params[:genome][:yaml]
    
    #format the meta data string from a provided yaml file
    if @genome.yaml_file
      @genome.meta = YAML::load_file(@genome.yaml_file.path).to_json 
    end
    
    #add the reference objects and sequence objects for this file...
    if @genome.fasta_file

      Bio::FastaFormat.open(@genome.fasta_file.path).each do |entry|
          seq = entry.to_seq
          reference = Reference.new(:name => entry.entry_id, :length => entry.length)
          sequence = Sequence.new(:sequence => "#{seq.seq}")
          reference.sequence = sequence        
          @genome.references << reference
        end
    end
    
    respond_to do |format|
      if @genome.save
        flash[:notice] = "Genome was successfully created."
        format.html { redirect_to(@genome) }
     else
        format.html { render :action => "new" }
    end
    end
  end
  
  def destroy
    @genome = Genome.find(params[:id])
    @genome.destroy
    respond_to do |format|
      format.html { redirect_to(genomes_url) }
    end
  end
  
  def respond(response)
    respond_to do |format|
      format.html
      format.json { render :json => response, :layout => false }
      format.xml  { render :xml => response, :layout => false }
    end
  end

end
