$(document).ready ->
  $("form#by_range select#experiment").on 'change', ->
    experiment_id = $(@).val()
    $("#reference").autocomplete
      source: "/experiments/reference_list/#{experiment_id}.json" 
      minLength: 0
    .autocomplete('search', '')
    .focus -> $(@).autocomplete('search', '')

  $("form#genomic_sequence select#genome_id").on 'change', ->
    genome_id = $(@).val()
    $("#reference").autocomplete
      source: "/genomes/reference_list/#{genome_id}.json" 
      minLength: 0
    .autocomplete('search', '')
    .focus -> $(@).autocomplete('search', '')
