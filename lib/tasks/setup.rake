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
  desc "add a species definition"
  task :species => :environment do
    unless ENV['genus'] and ENV['species']
      puts "dont have a genus and species definition"
      exit
    end
    s = Organism.new (
                :genus => ENV['genus'],
                :species => ENV['species'],
                :strain => ENV['strain'],
                :pv => ENV['pv'],
                :taxid => ENV['taxid']
                )
    if s.save
      puts "saved species #{s.inspect} to the database"
    else 
      puts "Error saving"
    end
  end
  
  desc "add fasta sequences for the references"
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
  
  desc "add reference sequence information (not actual sequences) to the database"
  task :reference_info => :environment do 
    require 'bio'
    unless ENV['genome']
      puts "no genome explicitly defined, assuming id is 1 ... "
    end
    genome_id = 1
    genome_id = ENV['genome'] if ENV['genome']
    genome = Genome.find(:first, :conditions => ["id = ?", "#{genome_id}"])
    exit "can't find genome with id #{genome_id} ... " unless genome
    
    puts "adding reference sequence information to database"
    Bio::FastaFormat.open("#{ENV['fasta']}").each do |entry|
      reference = Reference.new( 
                                  :name => entry.entry_id, 
                                 :length => entry.length,
                                 :genome_id => genome_id 
                                )
      reference.save                          
    end
  end
  
  desc "add a genome version to the database"
  task :genome => :environment do 
    build_version = nil
    unless ENV['build_version']
      puts 'a genome build must be defined'
      exit
    end
    build_version = ENV['build_version']
    if build_version
      meta = nil 
      meta = YAML.load_file("#{ENV['meta']}").to_json if ENV['meta']
      genome = Genome.new(
                          :build_version => build_version,
                          :meta => meta
                          )
      genome.save 
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
    if (!Experiment.find(:first, :conditions => ['name = ?', "#{escaped_exp}"]).nil?)
      puts "We have an experiment with that name already.. Do you want to add these features? (y/n)..."
      answer = $stdin.gets.chomp
      if answer.match('n')
        "Aborting without update"
        exit
      else
        exp = Experiment.find(:first, :conditions => ['name = ?', "%#{escaped_exp}%"])
      end
    else
      puts "not found, creating new experiment"
        ENV['desc'] = nil unless ENV['desc']

      exp = Experiment.new(:name => "#{ENV['exp']}", :description => "#{ENV['desc']}" )
      
      if ENV['trackinfo']
        exp.meta = YAML.load_file("#{ENV['trackinfo']}").to_json
      else
        exp.meta = genome.meta
      end
      exp.genome_id = genome.id
      
      if exp.meta.nil?
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

      puts "loading #{ENV['gff']}..."
      File.open( "#{ENV['gff']}" ).each do |line|
        next if line =~ /^#/
        break if line =~ /^##fasta/ or line =~ /^>/
        record = Bio::GFF::GFF3::Record.new(line)

        #use only the first gff id as the linking one ... 
        gff_ids = record.attributes.select { |a| a.first == 'ID' }
        gff_id = nil
        gff_id = gff_ids[0][1] if ! gff_ids.empty?
        
        #get the sequence and quality if defined
        note = record.attributes.select{|a| a.first == 'Note'}
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
      
        ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{genome_id}"])
      
        feature = Feature.new (
          :group => "#{attribute}",
          :feature => "#{record.feature}",
          :source => "#{record.source}",
          :start => "#{record.start}",
          :end => "#{record.end}", 
          :strand => "#{record.strand}",
          :phase => "#{record.frame}",
          :seqid => "#{record.seqname}",
          :score => "#{record.score}",
          :experiment_id => "#{exp.id}",
          :gff_id =>  "#{gff_id}",
          :sequence => "#{seq}",
          :quality => "#{qual}",
          :reference_id => "#{ref.id}"
        )
      
      
      #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
      #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
      ###sort out the Parents if any, but only connects up the parent via the first gff id
        unless skip_parent_finding
          parents = record.attributes.select { |a| a.first == 'Parent' }
          if !parents.empty?
            parents.each do |label, parentFeature_gff_id|
              parentFeats = Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
              if (parentFeats)
                parentFeats.each do |pf|
                  parent = nil
                  parent = Parent.find(:first, :conditions => {:parent_feature => pf.id})
                  if parent
                    parent.save unless practice
                  else
                    parent = Parent.new(:parent_feature => pf.id)
                    parent.save unless practice
                  end
                 feature.parents << parent
              end
            end
          end
        end
        end
        feature.save unless practice
      end
    end
  end

  desc "fast add features in an experiment (track) to the database .. requires more memory than add"
  task :features_fast => :environment do
    require 'bio'
    require 'json'
    
    child_feature_list = Hash.new {|h,k| h[k] = [] } 
    parent_feature_list = Hash.new
    parent_object_list = Hash.new
    Parent.all.each do |p|
      parent_object_list[p.parent_feature] = p
    end
    
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
    if (!Experiment.find(:first, :conditions => ['name = ?', "#{escaped_exp}"]).nil?)
      puts "We have an experiment with that name already.. Do you want to add these features? (y/n)..."
      answer = $stdin.gets.chomp
      if answer.match('n')
        "Aborting without update"
        exit
      else
        exp = Experiment.find(:first, :conditions => ['name = ?', "#{escaped_exp}"])
        ##get all the existing features for this experiment and add them to the parent_list
        exp.features.each do |feature|
          parent_feature_list[feature.gff_id] = feature if feature.gff_id
          feature.parents.each do |parent|
            child_feature_list[parent.parent_obj.gff_id] << feature
          end
        end
      end
    else
      puts "not found, creating new experiment"
        ENV['desc'] = nil unless ENV['desc']

      exp = Experiment.new(:name => "#{ENV['exp']}", :description => "#{ENV['desc']}" )

      if ENV['trackinfo']
        exp.meta = YAML.load_file("#{ENV['trackinfo']}").to_json
      else
        exp.meta = genome.meta
      end
      exp.genome_id = genome.id

      if exp.meta.nil?
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

    if ENV['gff'] #env gff start 

      puts "loading #{ENV['gff']}..."
      File.open( "#{ENV['gff']}" ).each do |line|
        next if line =~ /^#/
        break if line =~ /^##fasta/ or line =~ /^>/
        record = Bio::GFF::GFF3::Record.new(line)

        #use only the first gff id as the linking one ... 
        gff_ids = record.attributes.select { |a| a.first == 'ID' }
        gff_id = nil
        gff_id = gff_ids[0][1] if ! gff_ids.empty?

        #get the sequence and quality if defined
        note = record.attributes.select{|a| a.first == 'Note'}
        seq = nil
        qual = nil

        #remove gfu_id attributes as they cannot be user specified
        record.attributes.delete_if{|a| a[0] == 'gfu_id'}

        if note
          note = note.flatten.last.to_s #flatten.delete_if{|x| x == "Note"}.to_s
          note.match(/<sequence>(.*)<\/sequence>/)
          seq = $1
          note.match(/<quality>(.*)<\/quality>/)
          qual = $1
        end

        attribute = JSON.generate(record.attributes)

        ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{genome_id}"])

        feature = Feature.new(
          :group => "#{attribute}",
          :feature => "#{record.feature}",
          :source => "#{record.source}",
          :start => "#{record.start}",
          :end => "#{record.end}", 
          :strand => "#{record.strand}",
          :phase => "#{record.frame}",
          :seqid => "#{record.seqname}",
          :score => "#{record.score}",
          :experiment_id => "#{exp.id}",
          :gff_id =>  "#{gff_id}",
          :sequence => "#{seq}",
          :quality => "#{qual}",
          :reference_id => "#{ref.id}"
        )

      #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
      #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
      ###sort out the Parents if any, but only connects up the parent via the first gff id
        unless skip_parent_finding
          parents = record.attributes.select { |a| a.first == 'Parent' }
          if !parents.empty?
            parents.each do |label, parentFeature_gff_id|
              ## here preload all features in the experiment (if any) into a memory structure,
              ## should save database lookups in the line below, add new parent features into the
              ## structure as they are created and the db at the same time...
              parentFeat = parent_feature_list[parentFeature_gff_id]#Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
              if (parentFeat)
                  parent = nil
                  ## same here, preload all the parent features... 
                  parent = parent_object_list[parentFeat.id] #Parent.find(:first, :conditions => {:parent_feature => pf.id})
                  if parent
                    parent.save unless practice
                  else
                    parent = Parent.new(:parent_feature => parentFeat.id)
                    parent.save unless practice
                    parent_object_list[parentFeat.id] = parent
                  end
                 feature.parents << parent

              end
            end
          end
        end
        feature.save unless practice
        parent_feature_list[feature.gff_id] = feature if feature.gff_id
      end #file open end
    end #env gff end

  #end

  end #task end
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

namespace :update do
  desc "update and version the features in an experiment from new versions in a gff file. Features not already in the db are created. uses internal db id to identify features"
  task :features => :environment do

    require 'bio'
    require 'json'
    if not ENV['gff']
      $stderr.puts "Need a gff file gff=some_file"
      exit
    end

    unless ENV['exp']
      $stderr.puts "Need an experiment name exp='experiment' "
      exit
    end
    
    add_no_id_as_new = false
    if ENV['add_new']
      $stderr.puts "will add features with no gfu_id attribute as new features"
      add_no_id_as_new = true
    end

    practice = true if ENV['practice'] == "true"    
    skip_parent_finding = true if ENV['no_parents'] == "true"

    $stderr.puts "\nAttempting to update features in gff #{ENV['gff']} in experiment #{ENV['exp']}" 
    $stderr.puts "---------------------------------------------------------------"
    $stderr.puts "looking for experiment #{ENV['exp']} in database"
    escaped_exp = ENV['exp'].gsub ('%', '\%').gsub ('_', '\_')

    exp = Experiment.find(:first, :conditions => ['name = ?', "#{escaped_exp}"])

    unless (exp)
      $stderr.puts "Can't find an experiment matching that name, exiting"
      exit
    end

    ## get the feature from the db by gfu_id
    ## if this doesn't exist, look in the predecessors, if it is there IE has been re-versioned, report a conflict for manual editing. if it isnt a predecessor, complain to user
    $stderr.puts "loading #{ENV['gff']}..."
    File.open( "#{ENV['gff']}" ).each do |line|
      next if line =~ /^#/
      break if line =~ /^##fasta/ or line =~ /^>/
      record = Bio::GFF::GFF3::Record.new(line)

      gff_ids = record.attributes.select { |a| a.first == 'ID' }
      gff_id = nil
      gff_id = gff_ids[0][1] if ! gff_ids.empty?

      #use only the first gfu_id as the linking one ... 
      gfu_ids = record.attributes.select { |a| a.first == 'gfu_id' }
      gfu_id = nil
      gfu_id = gfu_ids[0][1] if ! gfu_ids.empty?

      #get the sequence and quality if defined
      note = record.attributes.select{|a| a.first == 'Note'}
      seq = nil
      qual = nil

      if note
        note = note.flatten.last.to_s #flatten.delete_if{|x| x == "Note"}.to_s
        note.match(/<sequence>(.*)<\/sequence>/)
        seq = $1
        note.match(/<quality>(.*)<\/quality>/)
        qual = $1
      end

      record.attributes.delete_if{|a| a[0] == 'gfu_id'}

      #puts "record = #{record.attributes.class}"
      attribute = JSON.generate(record.attributes)
      #puts "attribute = #{attribute.class}"
      ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{exp.genome_id}"])

      feature = Feature.new(
        :group => "#{attribute}",
        :feature => "#{record.feature}",
        :source => "#{record.source}",
        :start => "#{record.start}",
        :end => "#{record.end}", 
        :strand => "#{record.strand}",
        :phase => "#{record.frame}",
        :seqid => "#{record.seqname}",
        :score => "#{record.score}",
        :experiment_id => "#{exp.id}",
        :gff_id =>  "#{gff_id}",
        :sequence => "#{seq}",
        :quality => "#{qual}",
        :reference_id => "#{ref.id}"
      )

      if gfu_id.nil?
        if not add_no_id_as_new
          $stderr.puts "no gfu_id at line #{$.}, skipping feature"
        else
          $stderr.puts "no gfu_id at line #{$.}, saving feature as new one"
          #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
          #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
          ###sort out the Parents if any, but only connects up the parent via the first gff id
            unless skip_parent_finding
              parents = record.attributes.select { |a| a.first == 'Parent' }
              if !parents.empty?
                parents.each do |label, parentFeature_gff_id|
                  parentFeats = Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
                  if (parentFeats)
                    parentFeats.each do |pf|
                      parent = nil
                      parent = Parent.find(:first, :conditions => {:parent_feature => pf.id})
                      if parent
                        parent.save unless practice
                      else
                        parent = Parent.new(:parent_feature => pf.id)
                        parent.save unless practice
                      end
                      feature.parents << parent
                    end
                  end
                end
              end
            end
            feature.save unless practice
        end
      end 

      next unless gfu_id #next record unless we have a gfu_id

      old_feature = nil
      begin 
        old_feature = Feature.find(gfu_id)
      rescue
        old_feature = nil
      end
      if old_feature.nil?
        ##no feature to update in feature table, look in predecessors
        old_feature = Predecessor.find(:first, :conditions => {:old_id => gfu_id})
        if old_feature 
          puts "<CONFLICT>\n<COMMENT>gfu_id #{gfu_id} at line #{$.} is in the predecessors table.. conflict needs manual resolution</COMMENT>\n"

          puts "<PREDECESSOR>#{old_feature.to_gff}</PREDECESSOR>\n"
          puts "<COMMENT>features replacing this predecessor</COMMENT>\n"
          old_feature.features.each do |f|
            puts "<FEATURE>#{f.to_gff(:add_db_id_to_attrs=>true)}</FEATURE>\n"
          end
          puts "</CONFLICT>\n"
          old_feature = false
        else
        # not in predecessors either, complain
          puts "<ABSENT>\n<COMMENT>gfu_id #{gfu_id} not found in feature or predecessors table. If you meant this to be a new feature omit the gfu_id attribute</COMMENT>\n"
          puts "<FEATURE>#{feature.to_gff}</FEATURE>\n"
          puts "</ABSENT>\n"
        end
      end
      next unless old_feature

      ##we have an old feature.. do the update .. 
       ##set up the parents of the new feature from the group info
        parents = feature.group.select { |a| a.first == 'Parent' }
        if !parents.empty?
          parents.each do |label, parentFeature_gff_id|
            parentFeats = Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
            if (parentFeats)
              parentFeats.each do |pf|
                parent = nil
                parent = Parent.find(:first, :conditions => {:parent_feature => pf.id})
                if parent
                  parent.save
                else
                  parent = Parent.new(:parent_feature => pf.id)
                  parent.save 
                end
                feature.parents << parent
              end
            end
          end
        end

        #puts feature.group.class
        #puts JSON.generate(feature.group)
        #feature.group = JSON.generate(feature.group)
        feature.save
        new_parent = Parent.new(:parent_feature => feature.id)
        new_parent.save

        ##set up the children of the new feature from the old one..
        old_feature.children.each do |child|
          ##remove the old feature as a parent...
          new_parent_list = [new_parent] 
          child.parents.each do |parent|
              new_parent_list << parent unless parent.parent_feature == old_feature.id   
          end
          ##add the new feature as a parent to that child...
          child.parents = new_parent_list
          child.save unless practice
        end

        original_id = 0
        if old_feature.is_a?(Feature)
          original_id = old_feature.id
        elsif old_feature.is_a?(Predecessor)
          original_id = gfu_id
        end

        ##setup the predecessor record from the old feature... 
        predecessor = Predecessor.new(
        :seqid => old_feature.seqid,
        :source => old_feature.source,
        :feature => old_feature.feature,
        :start => old_feature.start,
        :end => old_feature.end,
        :score => old_feature.score,
        :strand => old_feature.strand,
        :phase => old_feature.phase,
        :gff_id => old_feature.gff_id,
        :reference_id => old_feature.reference_id,
        :experiment_id => old_feature.experiment_id,
        :created_at => old_feature.created_at,
        :group => old_feature.group,
        :old_id => original_id
        )
        predecessor.save unless practice
        feature.predecessors = [predecessor] + old_feature.predecessors
        feature.save unless practice
        old_feature.destroy unless practice

    end#end gff_file
    
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
  task :config => :environment do

    config = YAML.load_file("#{RAILS_ROOT}/config/config.yml")
    config_js = File.new("#{RAILS_ROOT}/public/javascripts/config.js", 'w')
    config_js.puts('AnnoJ.config = ')
    config_js.puts config.to_json
    
  end
  

end