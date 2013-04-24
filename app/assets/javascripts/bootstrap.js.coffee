jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()

$(document).ready ->
  $(":file").filestyle
    icon: true
    classIcon: "icon-file"
    buttonText: "Choose file..."