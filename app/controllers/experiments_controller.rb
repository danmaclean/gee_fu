#Implements the REST and AnnoJ requests for the Experiments table/model
# access via url
class ExperimentsController < ApplicationController
  
  #returns the list of experiments and associated meta-data in the database
  # use /experiments.format
  # where format = xml or json
  def index

    @experiments = Experiment.all
    result = Hash.new {|h,k| h[k]={}}
    @experiments.each do |exp|
      result['exp-' + "#{exp.id}"]["institution"] = YAML::load("#{exp.institution}") || "nil"
      result['exp-' + "#{exp.id}"]["engineer"] = YAML::load("#{exp.engineer}") || "nil"
      result['exp-' + "#{exp.id}"]["service"] = YAML::load("#{exp.service}") || "nil"
      result['exp-' + "#{exp.id}"]["description"] = YAML::load("#{exp.description}") || "nil"
      result['exp-' + "#{exp.id}"]["name"] = YAML::load("#{exp.name}") || "nil"
    end
    
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end
  
  #returns metadata for a selected experiment 
  # use /experiments/id.format
  # where format = xml or json
  def show 
    result = {}
    if Experiment.exists?(params[:id])
      @experiment = Experiment.find(params[:id])
      result["institution"] = YAML::load("#{@experiment.institution}") || "nil"
      result["engineer"] = YAML::load("#{@experiment.engineer}") || "nil"
      result["service"] = YAML::load("#{@experiment.service}") || "nil"
      result["description"] = YAML::load("#{@experiment.description}") || "nil"
      result["name"] = YAML::load("#{@experiment.name}") || "nil"
    end
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end
end 