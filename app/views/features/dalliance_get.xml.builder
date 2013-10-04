xml.instruct!
  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
      @seqs.limit(20).each do |seq|
        xml.SEGMENT 'id' => seq do
            # logger.error"-----------------------------#{seq}"
            Feature.where(experiment_id: @eid, seqid: seq, feature: ["five_prime_UTR", "exon", "intron","three_prime_UTR"]).each do |feature|
              xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
                xml.TYPE feature.feature ,'id' => feature.feature
                xml.METHOD feature.source
                xml.START feature.start
                xml.END feature.end
                xml.SCORE feature.score
                xml.ORIENTATION feature.strand
                xml.PHASE feature.phase #0-6
              end
            end
        end
      end
    end
  end