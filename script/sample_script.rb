#!/usr/bin/env ruby
#
#  sample_script
#
#  Created by macleand on 2010-07-26.
#  Copyright (c)  . All rights reserved.
###################################################

##loads in the rails environment

  models = Feature.find(:all)
  puts "I found #{models.length} features"