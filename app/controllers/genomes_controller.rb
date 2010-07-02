#Implements the REST requests for the Genomes table/model
#access via url
class GenomesController < ApplicationController
  
  #returns the genome information on an AnnoJ genome request
  # only for use by AnnoJ
  def annoj  #a method for annoj
    @genome = Genome.find(params[:id])
    @response = {}
    @response["success"] = true
    @response["data"] = {}
    @response["data"]["institution"] = YAML::load( "#{@genome.institution}" )
    @genome.institution
    @response["data"]["engineer"] = YAML::load( "#{@genome.engineer}" )
    @response["data"]["service"] = YAML::load( "#{@genome.service}" )
    @response["data"]["genome"] = YAML::load( "#{@genome.genome}" )
    render :json => @response, :layout => false #render :json => @genome doesnt work because annoj wont accept extra keys made by json-ing of ruby object..
  end

  #returns the list of genomes and associated meta-data in the database
  # use /genomes.format
  # where format = xml or js
  def index #regular web request method
    @genomes = Genome.all
    result = Hash.new {|h,k| h[k]={}}
    @genomes.each do |gen|
      result['gen-' + "#{gen.id}"]["institution"] = YAML::load("#{gen.institution}")
      result['gen-' + "#{gen.id}"]["engineer"] = YAML::load("#{gen.engineer}")
      result['gen-' + "#{gen.id}"]["service"] = YAML::load("#{gen.service}")
      result['gen-' + "#{gen.id}"]["genome"] = YAML::load("#{gen.genome}")
    end
    
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end

  #returns metadata for a selected genome 
  # use /genome/id.format
  # where format = xml or json
  def show
    result = {}
    if Genome.exists?(params[:id])
     @genome = Genome.find(params[:id])
     result["institution"] = YAML::load("#{@genome.institution}")
     result["engineer"] = YAML::load("#{@genome.engineer}")
     result["service"] = YAML::load("#{@genome.service}")
     result["genome"] = YAML::load("#{@genome.genome}")
   end
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end

end
