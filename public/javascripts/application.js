// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//gets the list of chromosomes from the server for JQuery autofill forms
	function get_chromosomes(genome_id){
		var http = new XMLHttpRequest();
		var url = '/genomes/reference_list/' + genome_id + '.json'; 
		http.onreadystatechange = function(){ 
			if (http.readyState == 4) {
				if (http.status == 200){
				$("#chromosome_list").autocomplete(http.responseText.split(" "));
				}
				else{
					alert("Failed to retrieve reference list");
				}
			}
		}
		http.open('GET',url,true);
		http.send(null);
	}
	
