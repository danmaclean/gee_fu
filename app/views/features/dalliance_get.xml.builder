xml.instruct!
  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
      # @seqs.take(1).each do |seq|
      # @seqs.each do |x|
        # xml.SEGMENT 'id' => x.parent_obj.id.to_s do
            @features = Feature.where(experiment_id: @eid, seqid: 1, feature: ["five_prime_UTR", "exon", "intron","three_prime_UTR"])
            @features.each do |feature|
              xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
                xml.TYPE feature.feature ,'id' => feature.feature
                xml.METHOD feature.source
                xml.START feature.start
                xml.END feature.end
                xml.SCORE feature.score
                xml.ORIENTATION feature.strand
                xml.PHASE feature.phase #0-6
                # feature.parents.collect {|x|
                  # xml.PARENT x.parent_obj.id.to_s ,'id' => x.parent_obj.id.to_s
                # }
              # end
            # end
            logger.error "------------------------------------ end of features"
        end
      end
    end
  end