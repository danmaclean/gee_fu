$(document).ready ->
  $ ->
    url = window.location.pathname
    activePage = url.substring(url.lastIndexOf("/"))
    $("#nav_menu").children("li").each ->
      $(this).addClass "active"  if $(this).children("a:first-child").attr("href") is activePage