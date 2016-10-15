$.cookie.json = true
$.cookie.defaults.expires = 7

app_prefix = '/mo'

suboutDeployTimestamp = () ->
  ts = $(document.body).attr('data-subout-deploy')
  if ts == '--DEPLOY--'
    ts = (new Date().getTime())
  ts

suboutPartialPath = (file) ->
  path =  app_prefix + '/partials/' + file
  deploy = suboutDeployTimestamp()

  path = '/files/' + deploy + path
  return path

subout = angular.module("subout",
  ["ui.utils", "ui.date", "suboutFilters", "suboutServices","ngCookies", "ngRoute", "mobile-angular-ui", 'angularjs-dropdown-multiselect', 'ui.bootstrap'])

subout.run(['$rootScope','$appVersioning','$location', '$analytics', ($rootScope, $versioning, $location, $analytics) ->
  $rootScope.$on '$routeChangeStart', (scope, next, current) ->
    $('#content').addClass('loading')
    $analytics.trackPageview()

  $rootScope.$on '$routeChangeSuccess', (scope, next, current) ->
    $('#content').removeClass('loading')

  $rootScope.$on '$routeChangeStart', (scope, next, current) ->
    if(current && $versioning.isMarkedForReload())
      window.location = $location.path()
      window.location.reload()

  $rootScope.$on "$routeUpdate", (scope, next, current) ->
    $analytics.trackPageview()
])

subout.config(["$routeProvider", "$httpProvider", ($routeProvider, $httpProvider) ->
  resolveAuth = {
    requiresAuthentication : (Authorize, $location, $rootScope) ->
      response = Authorize.check()
      if response == false
        $rootScope.redirectToPath = $location.path()
        $location.path('/sign_in').replace()
        return false
      else
        return response
  }
  oldTransformReq = $httpProvider.defaults.transformRequest
  $httpProvider.defaults.transformRequest = (d, headers) ->
    $('.loading-animation').addClass('loading')
    return oldTransformReq[0].apply(this, arguments)

  $httpProvider.responseInterceptors.push('myHttpInterceptor')
  $routeProvider.when("/sign_in",
    templateUrl: suboutPartialPath("sign_in.html")
    controller: SignInCtrl
  ).when("/sign_up",
    templateUrl: suboutPartialPath("sign_up.html")
    controller: SignUpCtrl
  ).when("/help",
    templateUrl: suboutPartialPath("help.html")
    controller: HelpCtrl
  ).when("/password/new",
    templateUrl: suboutPartialPath("password-new.html")
    controller: NewPasswordCtrl
  ).when("/password/edit",
    templateUrl: suboutPartialPath("password-edit.html")
    controller: "EditPasswordCtrl"
  ).when("/dashboard",
    templateUrl: suboutPartialPath("dashboard.html")
    controller: DashboardCtrl
    reloadOnSearch: false
    resolve: resolveAuth
  ).when("/bids",
    templateUrl: suboutPartialPath("bids.html")
    controller: MyBidCtrl
    resolve: resolveAuth
  ).when("/opportunities",
    templateUrl: suboutPartialPath("opportunities.html")
    controller: OpportunityCtrl
    resolve: resolveAuth
  ).when("/available-opportunities",
    templateUrl: suboutPartialPath("available-opportunities.html")
    controller: AvailableOpportunityCtrl
    resolve: resolveAuth
  ).when("/opportunities/:opportunity_reference_number",
    templateUrl: suboutPartialPath("opportunity-detail.html")
    controller: OpportunityDetailCtrl
    resolve: resolveAuth
  ).when("/quote_requests/:quote_request_reference_number",
    templateUrl: suboutPartialPath("quote-request-detail.html")
    controller: QuoteRequestDetailCtrl
    resolve: resolveAuth
  ).when("/favorites",
    templateUrl: suboutPartialPath("favorites.html")
    controller: FavoritesCtrl
    resolve: resolveAuth
  ).when("/companies/:company_id",
    templateUrl: suboutPartialPath("company-detail.html")
    controller: CompanyDetailCtrl
    resolve: resolveAuth
  ).when("/welcome-prelaunch",
    templateUrl: suboutPartialPath("welcome-prelaunch.html")
    controller: WelcomePrelaunchCtrl
    resolve: resolveAuth
  ).when("/settings",
    templateUrl: suboutPartialPath("settings.html")
    resolve: resolveAuth
  ).when("/new-opportunity",
    templateUrl: suboutPartialPath("opportunity-form.html")
    resolve: resolveAuth
   ).when("/add-favorite",
    templateUrl: suboutPartialPath("add-new-favorite.html")
    resolve: resolveAuth
  ).otherwise redirectTo: "/available-opportunities"

])

subout.value 'ui.config',
  select2:
    allowClear: true
    # formatSelection: (option) ->
    #   return unless option

    #   $(option.element).data('abbreviated_name')

subout.value 'AuthToken', 'auth_token_v2'

$.timeago.settings.allowFuture = true
$.cloudinary.config({"cloud_name":"subout"})
