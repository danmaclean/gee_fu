module FastaGffSetup
  # NOTE: culled directly from the GenomeController. Needs factoring out.
  def import_fasta
    Bio::FastaFormat.open("#{Rails.root}/spec/example_files/fasta/short.fna").each do |entry|
      seq                = entry.to_seq
      reference          = Reference.new(:name => entry.entry_id, :length => entry.length)
      sequence           = Sequence.new(:sequence => "#{seq.seq}")
      reference.sequence = sequence        
      genome.references << reference
    end
    genome.save!
  end

  # NOTE: culled directly from the ExperimentController. Needs factoring out.
  def import_gff
    File.open( "#{Rails.root}/spec/example_files/gff/sample.gff" ).each do |line|
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
        note = note.flatten.last.to_s 
        note.match(/<sequence>(.*)<\/sequence>/)
        seq = $1
        note.match(/<quality>(.*)<\/quality>/)
        qual = $1
      end

     attribute = JSON.generate(record.attributes)

      ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{experiment.genome_id}"])

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
        #:experiment_id => "#{exp.id}",
        :gff_id =>  "#{gff_id}",
        :sequence => "#{seq}",
        :quality => "#{qual}",
        :reference_id => "#{ref.id}"
      )


      #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
      #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
      ###sort out the Parents if any, but only connects up the parent via the first gff id
      if experiment.find_parents
        parents = record.attributes.select { |a| a.first == 'Parent' }
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
      end
      experiment.features << feature
    end
    experiment.save!
  end
end
