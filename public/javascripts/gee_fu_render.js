/* a simple namespace for the gee fu feature render methods used in the feature layouts */


GFR = {
extent : function (family){ //returns max and min of the feature family
	var max = -Infinity;
	var min = Infinity;
	for (var i=0; i<family.length; i++){
		var feature = family[i];
		if(max < feature.feature.end){
			max = feature.feature.end;
		}
		if(min > feature.feature.start){
			min = feature.feature.start;
		}
	}
	return {'max' : max, 'min' : min};
},

units : function (length){ //returns nt that can be plotted per pixel window space
	var canvas_width = 900.0;
	return length / canvas_width;
},

draw_box : function (context, options){
	//options = literal hash 
	//x : x start, y : y start, w : width, h : height, fill_col : web_colour, stroke_col
 	context.shadowBlur = 10;
	context.shadowColor = "black";
	context.strokeStyle = options.stroke_col;
	context.fillStyle = options.fill_col;
	context.fillRect(options.x, options.y, options.w, options.h);
	context.strokeRect(options.x, options.y, options.w, options.h);
	context.shadowColor = "transparent";
	
	
},
draw_stroke : function (context, options){
	//x_start : x start, y_start : y start, x_end : x end, y_end : y end, stroke_style : stroke style  
	context.beginPath();
	context.strokeStyle = options.stroke_style;
	context.moveTo(options.x_start, options.y_start);
	context.lineTo(options.x_end, options.y_end);
	context.stroke();
},

mark_start_and_end : function (context, options){
	/* options = {
		stroke_style : stroke style, 
		fill_style : fill style, 
		font : css style font string, 
		baseline : baseline for text, 
		start_x : start number x co-ord, 
		start_y : start number y co-ord, 
		end_x : end number x co-ord, 
		end_y : end number y co-ord, 
		start_pos : start position number, 
		end_pos : end position number
    } */
	
	context.strokeStyle = options.stroke_style;
	context.fillStyle = options.fill_style;
	context.font         = options.font;
	context.textBaseline = options.baseline;
	context.fillText  (options.start_pos, options.start_x, options.start_y);
	context.fillText (options.end_pos, options.end_x, options.end_y);
	
},
feature_colour : function (feature_type){
	var colours = {'exon' : '#ff0000', 'CDS' : '#00ff00', 'five_prime_UTR' : '#ffc821', 'three_prime_UTR' : '#ffc821', 'gene' : '#000000', 'mRNA' : '#666666' };
	return colours[feature_type];
},

translate_coords : function (coord, units){
	return (coord / units) + 50;
},

draw_family : function (family, context) {
	var e = GFR.extent(family);
	 for (i in family){
		feature = family[i];
		var feature_type = feature.feature.feature; 

		var units = GFR.units(e.max - e.min);
		var x_start = GFR.translate_coords(feature.feature.start - e.min, units);
		var x_end = GFR.translate_coords(feature.feature.end - e.min, units);
		var width = x_end - x_start;
		var colour = GFR.feature_colour(feature_type); 
		if (feature_type == 'gene' || feature_type == 'mRNA'){
			GFR.draw_stroke(context, {"x_start" : x_start, "y_start" : 75, "x_end": x_end, "y_end" : 75, "stroke_style" : colour});
		}
		else{
					GFR.draw_box(context, {'x' : x_start, 'y' : 45, 'h': 45, 'w': width, 'stroke_col': "#000000", 'fill_col': colour } );
		}

		
	} 
	GFR.mark_start_and_end(context, {'start_x' : 0, 'start_y' : 130, 
								 'end_x': 950, 'end_y' : 130, 
								 'start_pos' : e.min, 'end_pos' : e.max, 
								 'stroke_style' : "#000", 'fill_style': "#000",
								 'font':'italic 10pt sans-serif', 
								 'baseline' : 'bottom' }
					  );
					
},
draw : function(family){
	var canvas_id = family[0].feature.id;
	var drawingCanvas = document.getElementById(canvas_id);
 	//Check the element is in the DOM and the browser supports canvas
	if(drawingCanvas.getContext) {
		// Initaliase a 2-dimensional drawing context
		var context = drawingCanvas.getContext('2d');	
		GFR.draw_family(family, context);
	}
}

};