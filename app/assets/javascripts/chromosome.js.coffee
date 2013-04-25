$(document).ready ->
  $("form#by_range select#experiment").on 'change', ->
    experiment_id = $(@).val()
    $("#reference").autocomplete
      source: "/genomes/reference_list/#{experiment_id}.json" 
      minLength: 0
    .autocomplete('search', '')
    .focus -> $(@).autocomplete('search', '')
