jQuery ->
  $("body").on "click", ".alert .close", (event) ->
    event.preventDefault()
    $(@).closest(".alert").remove()

  toggleSubscriptionRegions = ->
    if $("#gateway_subscription_product_handle").val() is "state-by-state-service"
      $(".subscription-regions").show()
    else
      $(".subscription-regions").hide()

  $("#gateway_subscription_product_handle").on "change", ->
    toggleSubscriptionRegions()
  toggleSubscriptionRegions()

  $("#toggle_check_all").on "change", ->
    if $(@).prop("checked")
      $(".subscription-regions input[type='checkbox']").prop("checked", true)
      $(".check-all label").text("Uncheck All")
    else
      $(".subscription-regions input[type='checkbox']").prop("checked", false)
      $(".check-all label").text("Check All")
