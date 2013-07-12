$(document).ready(function () {

	 $(function(){
	     var pageLink = document.URL;
	     $("#yourNavDiv").children("li").each(function(){
	         if($(this).children("a:first-child").attr("href") == pageLink){
	             $(this).addClass("active");
	         }
	     });
	  });
  
});