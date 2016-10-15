do ->
  applyScopeHelpers = ($scope, $rootScope, $location,
    $routeParams, $timeout, Password, AuthToken) ->
    $scope.hideAlert = ->
      $scope.notice = null
      $scope.errors = null

    $scope.resetPassword = ->
      $scope.hideAlert()

      $scope.user.reset_password_token = $routeParams.reset_password_token
      Password.update {user: $scope.user}
      , ->
        $scope.notice = "Your password is reset successfully"
        $scope.password = null
        $scope.password_confirmation = null
        $timeout ->
          $scope.notice = null
          $location.path("sign_in").search({})
        , 2000
      , (content) ->
        $scope.errors = $rootScope.errorMessages(content.data.errors)

  subout.controller('EditPasswordCtrl', ($scope, $rootScope, $routeParams,
    $location, $timeout, Password, AuthToken) ->
    $.removeCookie(AuthToken)
    applyScopeHelpers($scope, $rootScope, $location,
      $routeParams, $timeout, Password, AuthToken)
  )
