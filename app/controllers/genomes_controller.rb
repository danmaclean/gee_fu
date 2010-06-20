class GenomesController < ApplicationController
  
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

  def show
    @genome = Genome.find(params[:id])
    result = {}
     result["institution"] = YAML::load("#{@genome.institution}")
     result["engineer"] = YAML::load("#{@genome.engineer}")
     result["service"] = YAML::load("#{@genome.service}")
     result["genome"] = YAML::load("#{@genome.genome}")
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end

end
