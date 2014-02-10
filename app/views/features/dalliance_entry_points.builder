# <DASEP>
#   <ENTRY_POINTS href="http://www.ensembl.org/das/Homo_sapiens.GRCh37.reference/entry_points" total="93" start="21" end="29">
#     <SEGMENT type="Chromosome" id="8" start="1" stop="146364022" orientation="+" subparts="yes">8</SEGMENT>
#     <SEGMENT type="Chromosome" id="9" start="1" stop="141213431" orientation="+" subparts="yes">9</SEGMENT>
#     <SEGMENT type="Chromosome" id="MT" start="1" stop="16569" orientation="+" subparts="yes">MT</SEGMENT>
#     <SEGMENT type="Chromosome" id="X" start="1" stop="155270560" orientation="+" subparts="yes">X</SEGMENT>
#     <SEGMENT type="Chromosome" id="Y" start="1" stop="59373566" orientation="+" subparts="yes">Y</SEGMENT>
#     <SEGMENT type="Supercontig" id="GL000191.1" start="1" stop="106433" orientation="+" subparts="yes">GL000191.1</SEGMENT>
#     <SEGMENT type="Supercontig" id="GL000192.1" start="1" stop="547496" orientation="+" subparts="yes">GL000192.1</SEGMENT>
#     <SEGMENT type="Supercontig" id="GL000193.1" start="1" stop="189789" orientation="+" subparts="yes">GL000193.1</SEGMENT>
#     <SEGMENT type="Supercontig" id="GL000194.1" start="1" stop="191469" orientation="+" subparts="yes">GL000194.1</SEGMENT>
#   </ENTRY_POINTS>
# </DASEP>

# xml.instruct!
#   xml.DASGFF do
#      xml.ENTRY_POINTS 'href' => "#{request.protocol}#{request.host_with_port}#{request.fullpath}", 'start' => @lowest, 'end' => @highest do
#         # xml.SEGMENT 'id' => "seg1"
#     end
#   end