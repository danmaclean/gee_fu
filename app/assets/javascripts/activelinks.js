$(document).ready(function () {

	 $(function(){

		 var url = window.location.pathname;  
		 var activePage = url.substring(url.lastIndexOf('/'));

	     var pageLink = document.URL;
	     console.log(activePage);
	     $("#nav_menu").children("li").each(function(){
	    	 console.log($(this).children("a:first-child").attr("href"));

	         if($(this).children("a:first-child").attr("href") == activePage){
	             $(this).addClass("active");
	         }
	     });
	  });
  
});