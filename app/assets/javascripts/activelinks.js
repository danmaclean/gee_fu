$(document).ready(function () {

	 $(function(){

		 var url = window.location.pathname;
//		 var activePage = url.substring(url.lastIndexOf('/'));
         var activePage = url.substring(url.indexOf('/'), 2);

         alert("DEBUG: "+activePage);

	     $("#nav_menu").children("li").each(function(){
	         if($(this).children("a:first-child").attr("href") == activePage){
	             $(this).addClass("active");
	         }
	     });

	  });
  
});