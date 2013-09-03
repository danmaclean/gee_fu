xml.instruct!

  xml.DASGFF do
    xml.GFF do
      xml.SEGMENT do
        @experiment.each do |feature|
          xml.FEATURE do
            xml.TYPE "TODO"
            xml.METHOD "TODO"
            xml.START feature.start
            xml.END feature.end
            xml.SCORE feature.score
            xml.ORIENTATION "TODO"
            xml.PHASE "TODO"
          end
        end
      end
    end
  end