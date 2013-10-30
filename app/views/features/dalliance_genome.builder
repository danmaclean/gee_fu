xml.instruct!
  xml.DASGFF do
    @seq.each do |seq|
      xml.SEQUENCE seq, 'id' => '1.0', 'version'=>'null', 'start'=>@start, 'stop'=>@ending, 'moltype'=>'DNA' do
    end
  end
end