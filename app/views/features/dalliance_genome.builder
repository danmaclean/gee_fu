xml.instruct!
  xml.DASGFF do
    xml.SEQUENCE 'id' => '1.0', 'version'=>'null', 'start'=>@start, 'stop'=>@ending, 'moltype'=>'DNA' do
     @seq
    end
end