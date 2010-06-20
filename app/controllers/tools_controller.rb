class ToolsController < ApplicationController
  
  def index
    @genomes = Genome.find(:all)
  end
  
  def genomic_sequence
    require 'bio'

    ref = Reference.find(:first, :conditions => {:name => params[:reference] , :genome_id => params[:id] } ) 
    
    @result = Hash.new
    
    if not ref.nil?
      seq = Bio::Sequence::NA.new("#{ref.sequence.sequence.to_s}")
      start = params[:start].to_i ||= 1
      stop = params[:end].to_i ||= seq.length
      subseq = seq.subseq(start, stop)
      strand = params[:strand] ||= 'plus'
      if strand == 'minus'
        subseq = subseq.complement
      end
      @result[:sequence] = subseq.to_s
      @result[:name] = params[:reference]
      @result[:start] = start
      @result[:end] = stop
      @result[:strand] = strand
    end
    
    respond_to do |format|
      format.html { render :html => @result }
      format.json { render :json => @result, :layout => false }
      format.xml  { render :xml => @result, :layout => false } 
    end
    
  end
  
end

