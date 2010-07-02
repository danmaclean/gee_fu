namespace :filter do
  desc "filters non annoJ supported feature types from a gene models gff"
  task :gene_model_features => :environment do
    require 'bio'
    require 'json'
    unless ENV['gff']
      puts "Need a gff file gff=some_file "
      exit
    end
    allowed_features = %w{CDS gene mRNA five_prime_UTR three_prime_utr} 
    File.open( "#{ENV['gff']}" ).each do |entry|
      record = Bio::GFF::GFF3::Record.new(entry)
      puts record if allowed_features.include?(record.feature)
    end  
  end
end


namespace :add do
  desc "add fasta sequences for the reference track"
  task :sequences => :environment do
    unless ENV['fasta']
      puts "Need an input fasta file containing the reference sequences"
      exit
    end

    #when sequences are too long to be added to the db a command like this in a mysql window will fix it..
    #
    #  set global max_allowed_packet=1000000000;
    #
    # 
    unless ENV['genome']
      puts "no genome explicitly defined, assuming id is 1 ... "
    end
    genome_id = 1
    genome_id = ENV['genome'] if ENV['genome']
    genome = Genome.find(:first, :conditions => ["id = ?", "#{genome_id}"])
    exit "can't find genome with id #{genome_id} ... " unless genome
 
    require 'bio'
    file = Bio::FastaFormat.open(ENV['fasta'])

    file.each do |entry|
        seq = entry.to_seq
        ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ seq.entry_id }", "#{genome.id}"])
        sequence = Sequence.new(
        :sequence => "#{seq.seq}",
        :reference_id => "#{ref.id}"
        )
        if sequence.save
          puts "sequence #{entry.entry_id} added"
          puts "---------------------------------------------------------------"
        else 
          puts "error saving sequence to database. Aborting without further update"
          exit
        end
        
    end
    
  end
  
  
  desc "add features in an experiment (track) to the database"
  task :features => :environment do
    require 'bio'
    require 'json'
    if not ENV['gff'] and not ENV['bam'] or ENV['gff'] and ENV['bam']
      puts "Need either a gff file gff=some_file OR a bam file bam=some_file, can't use both in a single track"
      exit
    end
    unless ENV['genome']
      puts "no genome explicitly defined, assuming id is 1 ... "
    end
    genome_id = 1
    genome_id = ENV['genome'] if ENV['genome']
    genome = Genome.find(:first, :conditions => ["id = ?", "#{genome_id}"])
    exit "can't find genome with id #{genome_id} ... " unless genome

    
    unless ENV['exp']
      puts "Need an experiment name exp='experiment' "
      exit
    end
    
    skip_parent_finding = true if ENV['no_parents'] == "true"
    
    practice = true if ENV['practice'] == "true"    
    
    puts "\nAttempting to add gff #{ENV['gff']} as experiment #{ENV['exp']}" 
    puts "---------------------------------------------------------------"
    puts "looking for experiment #{ENV['exp']} in database"
    escaped_exp = ENV['exp'].gsub ('%', '\%').gsub ('_', '\_')
    exp = nil
    if (!Experiment.find(:first, :conditions => ['name LIKE ?', "%#{escaped_exp}%"]).nil?)
      puts "We have an experiment with that name already.. Do you want to add these features? (y/n)..."
      answer = $stdin.gets.chomp
      if answer.match('n')
        "Aborting without update"
        exit
      else
        exp = Experiment.find(:first, :conditions => ['name LIKE ?', "%#{escaped_exp}%"])
      end
    else
      puts "not found, creating new experiment"
      unless ENV['desc']
        ENV['desc'] = 'not given'
      end
      exp = Experiment.new(:name => "#{ENV['exp']}", :description => "#{ENV['desc']}" )
      
      if ENV['trackinfo']
        trackinfo = YAML.load_file("#{ENV['trackinfo']}")
        exp.institution = trackinfo["institution"]
        exp.engineer = trackinfo["engineer"]
        exp.service = trackinfo["service"]
      else
        exp.institution = genome.institution
        exp.engineer = genome.engineer
        exp.service = genome.service
      end
      exp.genome_id = genome.id
      
      if exp.institution.nil? or exp.engineer.nil? or exp.service.nil?
        puts "Looks like the track information is missing, and there is no genome default in the db already"
        puts "This may cause problems... "
      end

      if ENV['bam']
        exp.bam_file_path = ENV['bam']
        exp.uses_bam_file = true
      end
      
      unless practice
        if exp.save
          puts "experiment #{ENV['exp']} added"
          puts "---------------------------------------------------------------"
        else 
          puts "error saving experiment to database. Aborting without further update"
          exit
        end
      end
    end
    if ENV['gff']
      allowed_features = YAML.load_file("#{RAILS_ROOT}/lib/song.yml")
 
      puts "loading #{ENV['gff']}..."
      File.open( "#{ENV['gff']}" ).each do |entry|
        record = Bio::GFF::GFF3::Record.new(entry)

        ###check that the GFF record contains an allowed feature term from the feature list
      
        unless allowed_features.include?(record.feature)
          puts "unknown and unallowed feature type in gff file whilst examining record"
          puts YAML.dump(record)
          puts record
          puts "aborting loading"
          exit
        end

     
        gff_id = record.attributes.select { |a| a.first.match('ID') }
        gff_id = gff_id.flatten.last if gff_id #flatten.delete_if{|x| x == "ID"} #get rid of the ID part of the array


        note = record.attributes.select{|a| a.first.match('Note')}
        seq = nil
        qual = nil

        if note
          note = note.flatten.last.to_s #flatten.delete_if{|x| x == "Note"}.to_s
          note.match(/<sequence>(.*)<\/sequence>/)
          seq = $1
          note.match(/<quality>(.*)<\/quality>/)
          qual = $1
        end
     
        attribute = JSON.generate(record.attributes)
      
        ref_id = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{genome_id}"])
      
        feature = Feature.new (
          :group => "#{attribute}",
          :feature => "#{record.feature}",
          :source => "#{record.source}",
          :start => "#{record.start}",
          :end => "#{record.end}", 
          :strand => "#{record.strand}",
          :phase => "#{record.frame}",
          :reference => "#{record.seqname}",
          :score => "#{record.score}",
          :experiment_id => "#{exp.id}",
          :gff_id =>  "#{gff_id}",
          :sequence => "#{seq}",
          :quality => "#{qual}",
          :reference_id => "#{ref_id}"
        )
      
      
      #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
      #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
      ###sort out the Parents if any
        unless skip_parent_finding
          parents = record.attributes.select { |a| a.first.match('Parent') }
          if !parents.empty?
            parents = parents.flatten.delete_if{|x| x == 'Parent'}
            parents.each do |parentFeature_gff_id|
              parentFeat = Feature.find(:first, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
              if (parentFeat)
                parent = nil
                parent = Parent.find(:first, :conditions => {:parent_feature => parentFeat.id})
                if parent
                  parent.save unless practice
                else
                  parent = Parent.new(:parent_feature => parentFeat.id)
                  parent.save unless practice
                end
                feature.parents << parent
              end
            end
          end
        end
        feature.save unless practice
      end
    end
  end
  desc "add assembly information to genome.yml from fasta file"
  task :assembly_to_yml => :environment do
    
    require 'bio'
    assembly = []
    puts "adding assembly information to genome.yml...."
    Bio::FastaFormat.open("#{ENV['fasta']}").each do |entry|
      assembly.push( { "id" => entry.entry_id, "size" => entry.length} )
    end
    config = YAML.load_file("#{RAILS_ROOT}/config/genome.yml")
    config["genome"]["assemblies"] = assembly
    File.open("#{RAILS_ROOT}/config/genome.yml", 'w') { |f| YAML.dump(config, f) }
    puts "added"
  end
  
  desc "load the config information into the database from the yaml file"
  task :config_to_db => :environment do
    ###load in the users config data
    config = YAML.load_file("#{RAILS_ROOT}/config/genome.yml")
  
    ###use the config to populate the genome table

    genome = Genome.new(:genome => config["genome"],
                        :institution => config["institution"],
                        :engineer => config["engineer"],
                        :service => config["service"]
                        )
     genome.save
     ###and to populate the reference table

     config["genome"]["assemblies"].each do |entry|
       ref = Reference.new(
          :name => "#{entry["id"]}",
          :length => "#{entry["size"]}",
          :genome_id => "#{genome.id}"
       
       )
       ref.save
     end
  end


end


namespace :remove do
  desc "remove features in an experiment (track) from the database"
  task :features => :environment do
    unless ENV['exp']
      puts "please provide an experiment name exp="
      exit
    end
    puts "\nAttempting to remove features for experiment : #{ENV['exp']}\n\n"
    
    experiment = Experiment.find_by_name("#{ENV['exp']}")
    if (not experiment.nil?)
      experiment.destroy
    else
      puts "\nCant find experiment with name: #{ENV['exp']}\n\n"
      puts "Experiments in the database..."
      puts "|ID\t|Name"
      exps = Experiment.find(:all)
      exps.each do |e|
        print "|", e.id, "\t|", e.name, "\n"
      end
      print "\n"
      puts "Remove Aborted"
      
    end
  end
end

namespace :list do
  desc "lists the experiments added to the database already"
  task :experiments => :environment do
    exps = Experiment.find :all
    exps.each {|e| puts e.id.to_s + ' - ' + e.name + '- ' + e.description}
    puts "no experiments" if exps.empty?
  end
end

namespace :create do
  desc "creates the AnnoJ config.js file based on the information in config.yml"
  task :config do
    
    config_yml = {}
    config_yml = YAML.load_file("#{RAILS_ROOT}/config/config.yml")
    config_js = File.new("#{RAILS_ROOT}/public/javascripts/config.js", 'w')
    config_js.puts('AnnoJ.config = ')
    config_js.puts config_yml.to_json
    
    
  end
  
  
  desc "turns a DagEdit style file into YAML and puts it in the lib folder as song.yml. The file defines the terms that are allowed in the feature field of the gff file "
  task :song_list => :environment do
    unless ENV['dag']
      raise ArgumentError "please provide a DagEdit file dag="
    end
    
        file = File.open("#{ENV['dag']}").read
    
      
        allowed = Array.new
        file.scan(/\[Term\].*?\n\n/m).each do |term|
          term.split(/\n/).each do |line|
            if line =~ /id:.(SO:\d+)/
              allowed << $1.to_s
            elsif line =~ /name:\s(.*)/
              allowed << $1.to_s 
            end
          end
        end
  
    
    File.open("#{RAILS_ROOT}/lib/song.yml", 'w') { |f| YAML.dump(allowed, f) }
    
    
  end
end