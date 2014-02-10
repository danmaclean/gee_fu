xml.instruct!
  xml.DASGFF do
     xml.ENTRY_POINTS 'href' => "#{request.protocol}#{request.host_with_port}#{request.fullpath}", 'start' => @lowest, 'end' => @highest do
     	xml.SEGMENT 'id' => "id1", 'start' => @lowest, 'stop' => @highest, 'version' => "null"
    end
  end