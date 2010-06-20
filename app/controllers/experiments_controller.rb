class ExperimentsController < ApplicationController
  
  def index #a method for the regular web service

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
  
  def show 
    @experiment = Experiment.find(params[:id])
    result = {}
    result["institution"] = YAML::load("#{@experiment.institution}") || "nil"
    result["engineer"] = YAML::load("#{@experiment.engineer}") || "nil"
    result["service"] = YAML::load("#{@experiment.service}") || "nil"
    result["description"] = YAML::load("#{@experiment.description}") || "nil"
    result["name"] = YAML::load("#{@experiment.name}") || "nil"
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end
end 