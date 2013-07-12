$(document).ready(function () {

	 $(function(){
	     var pageLink = document.URL;
	     $("#nav_menu").children("li").each(function(){
	         if($(this).children("a:first-child").attr("href") == pageLink){
	             $(this).addClass("active");
	         }
	     });
	  });
  
});