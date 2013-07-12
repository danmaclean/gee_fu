$(document).ready(function () {
	 $(function(){
		 var url = window.location.pathname;  
		 var activePage = url.substring(url.lastIndexOf('/'));
	     $("#nav_menu").children("li").each(function(){
	         if($(this).children("a:first-child").attr("href") == activePage){
	             $(this).addClass("active");
	         }
	     });
	  });
});