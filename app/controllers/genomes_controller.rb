#Implements the REST requests for the Genomes table/model
#access via url
class GenomesController < ApplicationController

  before_filter :require_organism

  #returns the genome information on an AnnoJ genome request
  # only for use by AnnoJ
  def annoj #a method for annoj
    genome = Genome.find(params[:id])
    @response = {}
    @response["success"] = true
    @response["data"] = JSON::parse("#{genome.meta}") #{}
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
    #@genomes.each do |gen|
    #  gen.meta
    #end
    respond @genomes
  end

  def update
    @genome = Genome.find(params[:id])

    respond_to do |format|

      logger.error("logging #{params[:genome]}")

      @genome.update_attribute(:organism_id, params[:genome][:organism_id])
      @genome.update_attribute(:build_version, params[:genome][:build_version])
      @genome.update_attribute(:meta, params[:genome][:meta])

      #if @genome.update_attributes(params[:genome])
      flash[:notice] = 'Genome was successfully updated.'
      format.html { redirect_to(@genome) }
      #else
      #  format.html { render :action => "edit" }
      #end
    end
  end

  #returns metadata for a selected genome
  # use /genome/id.format
  # where format = xml or json
  def show
    if Genome.exists?(params[:id])
      @genome = Genome.find(params[:id])
      #@genome.meta = @genome.meta_as_data_structure
      @experiments = @genome.experiments
      respond @genome
    else
      respond :false
    end
  end

  def edit
    @genome = Genome.find(params[:id])
  end

  def new
    @organisms = Organism.all
    @genome = Genome.new
    respond @genome
  end

  #returns a list of references for the genome for the ajax autofill box
  def reference_list
    genome = Genome.find(params[:id])
    respond genome.references.collect { |x| x.name }
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

      cmdOne = system('#{WebApolloPath}/tools/user/extract_seqids_from_fasta.pl -p Annotations- -i #{@genome.fasta_file.path} -o /data/webapollo/scratch/seqids.txt')
      cmdTwo = system('#{WebApolloPath}/tools/user/add_tracks.pl -D web_apollo_users -U web_apollo_users_admin -P web_apollo_users_admin -t /data/webapollo/scratch/seqids.txt')
      cmdThree = system('#{WebApolloPath}/tools/user/set_track_permissions.pl -D web_apollo_users -U web_apollo_users_admin -P web_apollo_users_admin -u web_apollo_admin -t /data/webapollo/scratch/seqids.txt -r -w -m')
      cmdFour = system('#{WebApolloAppPath}/jbrowse/bin/prepare-refseqs.pl --fasta #{@genome.fasta_file.path}')

      logger.debug "cmdOne #{cmdOne}"
      logger.debug "cmdTwo #{cmdTwo}"
      logger.debug "cmdThree #{cmdThree}"
      logger.debug "cmdFour #{cmdFour}"

      cmdComplete = "SUCCESSFUL"
      if (!cmdOne || !cmdTwo || !cmdThree || !cmdFour)
        cmdComplete = "FAILED, Please add manually"
      end

      genomefile = Bio::FastaFormat.open(@genome.fasta_file.path)

      logger.error "count #{genomefile}"
      logger.error "count #{genomefile}"
      logger.error "count #{genomefile}"

      genomefile.each do |entry|

        # logger.error "adding genome entry - #{entry.entry_id} of #{genomefile.count}"
        logger.error "#{genomefile.count}"

        seq = entry.to_seq
        reference = Reference.new(:name => entry.entry_id, :length => entry.length)
        sequence = Sequence.new(:sequence => "#{seq.seq}")
        reference.sequence = sequence
        @genome.references << reference
      end
    end

    respond_to do |format|
      if @genome.save
        flash[:notice] = "Genome was successfully created. WebApollo import: #{cmdComplete}"
        format.html { redirect_to(@genome) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    if (current_user.admin)
      if (false)
        @genome = Genome.find(params[:id])
        @genome.destroy
        respond_to do |format|
          format.html { redirect_to(genomes_url) }
        end
      end
    end
  end

  def respond(response)
    respond_to do |format|
      format.html
      format.json { render :json => response, :layout => false }
      format.xml { render :xml => response, :layout => false }
    end
  end

  def require_organism
    redirect_to root_path unless has_organisms?
  end

end
