#!/usr/bin/env ruby
#
#  dans_sam_test
#
#  Created by macleand on 2010-05-07.
#  Copyright (c)  . All rights reserved.
###################################################
require "bio/db/sam"
require 'pp'
@testTAMFile                 = "../test/samples/small/test.tam"
@testBAMFile                 = "../public/bam/aln.sort.bam"


sam = Bio::DB::Sam.new({:bam=>@testBAMFile})


sam.open
puts "loaded"
#result = sam.fetch("Chr1", 0, 10000)
#sam.close
fetchAlignment = Proc.new do |a|
  
  
    puts a.qual
    puts a.seq
         
end

sam.fetch_with_function("Chr1", 0, 10000, fetchAlignment)

#puts result.length

#result.each do |a|
#  puts a.qual
#  puts a.seq
#  exit
  #puts "#{a.pos}\t#{a.calend}"
  #puts "#{a.pos}\t#{a.pos.to_i + a.qlen.to_i}"
  #puts "___________"
#end
