$.cookie.json = true
$.cookie.defaults.expires = 7
$.cookie.defaults.path = "/"
jQuery ->
  $("textarea[data-maxlength]").maxlength()
