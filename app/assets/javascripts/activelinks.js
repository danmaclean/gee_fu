$(document).ready(function () {

    $(function () {

        var url = window.location.pathname;
		 var activePage = url.substring(url.lastIndexOf('/'));
         var activePage = url.substring(url.indexOf("/", url.indexOf("/") + 1));
//        var activePage = url;

//        alert("DEBUG: " + activePage);

        $("#nav_menu").children("li").each(function () {
	         if($(this).children("a:first-child").attr("href") == activePage){
//            if ($(this).children("a:first-child").attr("href").indexOf(activePage) > -1) {
                $(this).addClass("active");
            }
        });

    });

});