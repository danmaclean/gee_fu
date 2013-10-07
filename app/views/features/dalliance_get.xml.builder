xml.instruct!
  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
      @seqs.take(1).each do |seq|
        xml.SEGMENT 'id' => seq do
            # logger.error"-----------------------------#{seq}"
            @features = Feature.where(experiment_id: @eid, seqid: seq, feature: ["five_prime_UTR", "exon", "intron","three_prime_UTR"])
            logger.error "------------------------------------ found #{@features.length} features"
            @features.each do |feature|
              xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
                xml.TYPE feature.feature ,'id' => feature.feature
                xml.METHOD feature.source
                xml.START feature.start
                xml.END feature.end
                xml.SCORE feature.score
                xml.ORIENTATION feature.strand
                xml.PHASE feature.phase #0-6
                feature.parents.collect {|x|
                  xml.PARENT x.parent_obj.id.to_s ,'id' => x.parent_obj.id.to_s
                }
              end
            end
            logger.error "------------------------------------ end of features"
        end
      end
    end
  end