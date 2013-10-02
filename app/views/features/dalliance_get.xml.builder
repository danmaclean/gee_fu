xml.instruct!

  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
      xml.SEGMENT do
        @experiment.each do |feature|
          xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
            xml.TYPE feature.feature ,'id' => feature.feature
            xml.METHOD feature.source
            xml.START feature.start
            xml.END feature.end
            xml.SCORE feature.score
            xml.ORIENTATION feature.strand
            xml.PHASE feature.phase #0-6
            xml.GROUP_ID feature.group.id
            xmk.SEQUENCE feature.seqid
            # <PARENT id="parent id1" />
          end
        end
      end
    end
  end