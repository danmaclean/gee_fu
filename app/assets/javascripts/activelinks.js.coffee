$(document).ready ->
  $ ->
    url = window.location.pathname
    activePage = url.substring(url.lastIndexOf("/"))
    console.log(activePage)
    $("#nav_menu").children("li").each ->
      console.log(this);
      $(this).addClass "active"  if $(this).children("a:first-child").attr("href") is activePage