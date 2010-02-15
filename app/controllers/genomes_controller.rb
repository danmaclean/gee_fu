class GenomesController < ApplicationController
  
  def show
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


end
