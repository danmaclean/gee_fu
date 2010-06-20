class FeaturesController < ApplicationController
  # GET /features
  # GET /features.xml
  #require "bio/db/sam"
  
  def depth
    nucleotide_hash = {'A' => 0, 'T' => 0, 'G' => 0, 'C' => 0, 'N' => 0, 'total' => 0}
    comp_hash = {'A' => 'T', 'T' => 'A', 'G' => 'C', 'C' => 'G', 'N' => 'N'}
    positions = Hash.new {|h,k| h[k] = nucleotide_hash}
    features = find_in_range(params[:reference],params[:start],params[:end],params[:id])
    features.each do |f|
      if (f.sequence.match(/\w/))
        #positions["#{f.start}"] = 1
      f.sequence.split(//).each_index do |idx|
        positions[idx] = 1
      #  next if f.start.to_i + idx < params[:start].to_i or idx + f.start.to_i > params[:stop].to_i 
      #    f.strand.match(/\+/) ? positions[idx + f.start.to_i][f.sequence[idx,1].upcase] += 1 : positions[idx + f.start.to_i][comp_hash[f.sequence[idx,1].upcase]] += 1 
      #    positions[idx + f.start.to_i]['total'] += 1
        end
      else
        #positions = params
        pos = f.start.to_i
        stop = f.end.to_i
        while pos <= stop do
      #    next if f.start.to_i + idx < params[:start].to_i or idx + f.start.to_i > params[:stop].to_i
          positions[pos] = 1
          pos += 1
       end
      end
    end
    #positions = features
    respond(positions, params[:format])
  end
  
  
  def objects
    objects = []
    params[:format] = 'xml' unless params[:format]
    if !params[:overlap].nil? and params[:overlap] == "true" #if we want to include objects that can fall onto the edge of the range
      objects = find_in_range(params[:reference],params[:start],params[:end],params[:id])
    else #if we want to include only objects entirely within the range
      objects = find_in_range_no_overlap(params[:reference],params[:start],params[:end],params[:id])
      #objects = params#find_in_range('chr1',3000,7000,1)
    end
  
    objects.delete_if {|obj| obj.feature != params[:type] } if !params[:type].nil?
    #objects = params#find_in_range('chr1',3000,7000,1)
    respond(objects, params[:format])
  end
  
  def respond(objects,format)
    respond_to do |format|
      format.json { render :json => objects, :layout => false }
      format.xml  { render :xml => objects, :layout => false }
    end
  end 
  def annoj
    #annoj does this funny, makes posts for just getting information .. meh 
    #we dont want this sooo need to separate out the annoj get from the proper
    #rails resource request, this method handles only annoj requests...
    if request.get?
      ##sort out the params from annoj's get
      annoj_params = CGI.parse(URI.parse(request.url).query)
      annoj_params.each_pair {|k,v| annoj_params[k] = v.to_s}
      case annoj_params['action']
        when "syndicate"
          @response = syndicate(params[:id])
        when "describe"
          @response = describe(annoj_params["id"])
        end
        render :json => @response,  :layout => false
    elsif request.post?
      annoj_params = CGI.parse(request.raw_post)
      annoj_params.each_pair {|k,v| annoj_params[k] = v.to_s}
        #now do the specific stuff based on the annoj action... 
        case annoj_params['action']
          when "range" 
            @response = range(annoj_params['assembly'], annoj_params['left'], annoj_params['right'], params[:id], annoj_params['bases'], annoj_params['pixels'])
          when "lookup"
            @response = lookup(annoj_params["query"], params[:id])
        end
        render :json => @response, :layout => false
      end
  end
  def chromosome
    
    #a method for returning chromosome sequence as if it were a read to trick annoj into showing a reference sequence...
    if request.get?
      ##sort out the params from annoj's get
      annoj_params = CGI.parse(URI.parse(request.url).query)
      annoj_params.each_pair {|k,v| annoj_params[k] = v.to_s}
      case annoj_params['action']
        when "syndicate"
          @response = syndicate(params[:id])
        when "describe"
          @response = [] ##to be done... 
      end
        render :json => @response,  :layout => false
    elsif request.post?
      annoj_params = CGI.parse(request.raw_post)
      annoj_params.each_pair {|k,v| annoj_params[k] = v.to_s}
        #now do the specific stuff based on the annoj action... 
      if annoj_params['action'] == 'range'
          #remember params[:id] is genome id and annoj_params['assembly'] is the chromosome
          sequence = Reference.find(:first, :conditions => {:genome_id => params[:id], :name => annoj_params['assembly']}).sequence.sequence
          subseq = sequence[annoj_params['left'].to_i - 1..annoj_params['right'].to_i - 1]
          f = Feature.new(
            :group => '.',
            :feature => 'chromosome',
            :source => '.',
            :start => annoj_params['left'].to_i,
            :end => annoj_params['right'].to_i, 
            :strand => '+',
            :phase => '.',
            :reference => annoj_params['assembly'],
            :score => '.',
            :experiment_id => nil,
            :gff_id =>  nil,
            :sequence => "#{subseq}",
            :quality => nil,
            :reference_id => nil
          )
          zoom_factor = annoj_params['bases'].to_i / annoj_params['pixels'].to_i
          response = new_response
          features = [f]
          #@response = #range(annoj_params['assembly'], annoj_params['left'], annoj_params['right'], params[:id], annoj_params['bases'], annoj_params['pixels'])
          if zoom_factor >= 10
            hist_data = get_histogram(features)
             response[:data] = {}
             response[:data][:read] = hist_data 

          elsif zoom_factor < 10 and zoom_factor > 0.1
              box_data = get_boxes(features)
              box_data[:watson][0][0] = f.reference
              response[:data] = {}
              response[:data][:read] = box_data
          else
              read_data = get_reads(features)
              read_data[:watson][0][0] = f.reference
              response[:data] = {}
              response[:data][:read] = read_data
          end
          @response = response

      elsif annoj_params["action"] == "lookup"
            @response = [] #to be done also #lookup(annoj_params["query"], params[:id])
      end
      render :json => @response, :layout => false
    end
  end
  def syndicate(id)
    experiment = Experiment.find(id) 
    response = new_response
    response[:data] = {}
    response[:data][:institution] = YAML::load( "#{experiment.institution}")
    response[:data][:engineer] = YAML::load( "#{experiment.engineer}")
    response[:data][:service] = YAML::load( "#{experiment.service}")
    return response
  end
  def range(assembly, left, right, id, bases, pixels)
    zoom_factor = bases.to_i / pixels.to_i
    response = new_response
    features = find_in_range_no_overlap(assembly, left, right, id)
    return response if features.empty?
    #case features.first.feature
    
    #when 
    if Feature.allowed_read_types.include?(features.first.feature) #'polymerase_synthesis_read'
      if zoom_factor >= 10
       hist_data = get_histogram(features)
       response[:data] = {}
       response[:data][:read] = hist_data 
       return response
      elsif zoom_factor < 10 and zoom_factor > 0.1
        box_data = get_boxes(features)
        response[:data] = {}
        response[:data][:read] = box_data
      else
        read_data = get_reads(features)
        response[:data] = {}
        response[:data][:read] = read_data
      end   
       
    else
      response[:data] = []
      response[:data] = features.collect! {|f| f.to_annoj }
    end
    return response
  end
  def get_histogram(features)
     return [] if features.empty?
     results = []
     #lower limit
     left = features.first.start - (features.first.start % 10)
     #upper limit
     right = features.last.end + (features.last.end % 10)
     #number of arrays
     start = left
     while start <= right
       results << [start, 0, 0]
       start += 10
     end
     features.each do |f|
       window = f.start - (f.start % 10)
       start_index = nil
       if window == left 
          start_index = 0
       else
         start_index = (window - left) / 10
       end
       end_index = start_index + (((f.end - f.start) - ((f.end - f.start) % 10)) / 10)
       for index in start_index .. end_index
         break if index > results.length
         if f.strand.match(/\+/)
           results[index][1] += 1 
         else
           results[index][2] += 1
         end
       end
     end
     #temp = [start, 0, 0]
     #features.each do |f|
      # if f.start > start + 10
      #   results << temp
      #   start = start + 10
      #   temp = [start, 0,0]
      # end
      # if f.strand.match(/\+/)
      #   temp[1] += 1
      # else
      #   temp[2] += 1
      # end
     #end
     return results
     #pluses = Array.new(features.last.end - features.first.start + 1, 0)
     #minuses = Array.new(features.last.end - features.first.start + 1, 0)
     #features.each do |f|
     #  for i in f.start .. f.end
     #    case f.strand
     #    when '+'
     #      pluses[i - start] = pluses[i - start] + 1
     #   else
     #      minuses[i - start] = minuses[i - start] + 1
     #    end
     #  end
     #end
     #result = Array.new
     #while start < features.last.end
     #  result << [start, pluses.slice!(0 .. 8).max, minuses.slice!(0 .. 8).max]
     #  start += 10
     #end
     #return result
     #hist = {}
     #for pos in features.first.start .. features.last.end
     #  hist[pos] = {}
     #  hist[pos]['+'] = 0
     #  hist[pos]['-'] = 0
     #end
     #features.each do |f|
     #  for pos in f.start .. f.end
     #    hist[pos][f.strand] = hist[pos][f.strand] + 1 
     #  end
     #end
     #result = hist  
     #result = []
     ####go through the hist and send [start, plus_intens, minus_intens] for each window of bases
       ##send max intensity in steps of ten

     #start = features.first.start.to_i
     #while start < features.last.end
     #  plus_intens = 0
     #  minus_intens = 0
     #  for pos in start .. (start + 9)

     #    break if pos > features.last.end
     #    plus_intens = hist[pos]['+'] if hist[pos]['+'] > plus_intens      
     #    minus_intens = hist[pos]['-'] if hist[pos]['-'] > minus_intens
     #  end

     #  result << [start, plus_intens, minus_intens]
     #  start += 10
     #end
     #return result
  end
  def get_boxes(features)
    result = {}
    result[:watson] = features.select{|f| f.strand == '+' }.collect{|e| e.to_box}
    result[:crick] = features.select{|f| f.strand == '-' }.collect{|e| e.to_box}
    return result
  end
  def get_reads(features)
    result = {}
    result[:watson] = features.select{|f| f.strand == '+' }.collect{|e| e.to_read}
    result[:crick] = features.select{|f| f.strand == '-' }.collect{|e| e.to_read}
    return result
  end
  def describe(id)
    f = Feature.find(:first, :conditions => {:gff_id => id} )
    response = new_response
    response[:data] = {}
    response[:data][:id] = f.gff_id
    response[:data][:assembly] = f.reference
    response[:data][:start] = f.start
    response[:data][:end] = f.end
    response[:data][:description] = f.description
    return response
  end
  def lookup(query, id)
    response = new_response
    rows = Feature.find(:all, :conditions => ["experiment_id = ? and features.group like ?", id, "%" + query + "%"]).collect! {|f| f.to_lookup}
    response[:count] = rows.length
    response[:rows] = rows
    return response
  end
  def find_in_range_no_overlap(reference, start, stop, id)
    experiment = Experiment.find(id)
      if experiment.uses_bam_file?
        Feature.find_by_bam(reference,start,stop,experiment.bam_file_path,id,experiment.genome_id)
      else
       Feature.find_by_sql(
      "select * from features where 
      reference = '#{reference}' and 
      start <= '#{stop}' and 
      start >= '#{start}' and
      end >= '#{start}' and 
      end <= '#{stop}' and 
      experiment_id = '#{id}'  
      order by start asc, end desc")
    end
  end
  def find_in_range(reference, start, stop, id)
    if experiment.uses_bam_file?
      Feature.find_by_bam(reference,start,stop, experiment.bam_file_path,id, experiment.genome_id)
    else
      Feature.find_by_sql(
      "select * from features where 
      reference = '#{reference}' and 
      start <= '#{stop}' and 
      end >= '#{start}' and 
      experiment_id = '#{id}'  
      order by start asc, end desc"
      )
    end
  end
  def new_response
    {:success => true }
  end
  

  
  

end
