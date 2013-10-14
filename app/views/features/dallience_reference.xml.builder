<!-- <?xml version="1.0" standalone="no"?>
<DASSEQUENCE>
  <SEQUENCE id="id" start="start" stop="stop" version="X.XX" label="Label">
      atttcttggcgtaaataagagtctcaatgagactctcagaagaaaattgataaatattat
      taatgatataataataatcttgttgatccgttctatctccagacgattttcctagtctcc
      agtcgattttgcgctgaaaatgggatatttaatggaattgtttttgtttttattaataaa
      taggaataaatttacgaaaatcacaaaattttcaataaaaaacaccaaaaaaaagagaaa
      aaatgagaaaaatcgacgaaaatcggtataaaatcaaataaaaatagaaggaaaatattc
      agctcgtaaacccacacgtgcggcacggtttcgtgggcggggcgtctctgccgggaaaat
      tttgcgtttaaaaactcacatataggcatccaatggattttcggattttaaaaattaata
      taaaatcagggaaatttttttaaattttttcacatcgatattcggtatcaggggcaaaat
      tagagtcagaaacatatatttccccacaaactctactccccctttaaacaaagcaaagag
      cgatactcattgcctgtagcctctatattatgccttatgggaatgcatttgattgtttcc
      gcatattgtttacaaccatttatacaacatgtgacgtagacgcactgggcggttgtaaaa
      cctgacagaaagaattggtcccgtcatctactttctgattttttggaaaatatgtacaat
      gtcgtccagtattctattccttctcggcgatttggccaagttattcaaacacgtataaat
      aaaaatcaataaagctaggaaaatattttcagccatcacaaagtttcgtcagccttgtta
      tgtcaaccactttttatacaaattatataaccagaaatactattaaataagtatttgtat
      gaaacaatgaacactattataacattttcagaaaatgtagtatttaagcgaaggtagtgc
      acatcaaggccgtcaaacggaaaaatttttgcaagaatca
  </SEQUENCE>
</DASSEQUENCE> -->

xml.instruct!
  xml.DASSEQUENCE do
        xml.SEQUENCE 'id' => "id", 'start' => "start", 'stop' => "stop", 'version' => "X.XX", 'label' = "Label" do
         sequenceText
  end
end