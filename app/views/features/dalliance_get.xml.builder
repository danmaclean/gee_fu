xml.instruct!

  xml.DASGFF do
    xml.GFF do
      xml.SEGMENT do
        @experiment.each do |feature|
          xml.FEATURE "id" => feature.id, "label" => "arrow3" do
            xml.TYPE feature
            xml.METHOD feature.source
            xml.START feature.start
            xml.END feature.end
            xml.SCORE feature.score
            xml.ORIENTATION feature.strand
            xml.PHASE feature.phase
          end
        end
      end
    end
  end