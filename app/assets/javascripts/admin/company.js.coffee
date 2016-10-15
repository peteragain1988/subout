jQuery ->
  $("#admin-companies").on "click", ".become-user", (event) ->
    event.preventDefault()

    authTokeyKey = "auth_token_v2"
    $.cookie(authTokeyKey, $(@).data("auth-token"))
    window.open($(this).attr("href"))

