api_path = "/api/v1"

suboutSvcs = angular.module("suboutServices", ["ngResource", "angular-abortable-requests"])

suboutSvcs.factory "Setting", ($resource) ->
  $resource "#{api_path}/settings/:key",
    { key: '@key' }

suboutSvcs.factory "soValidateEmail", ->
  (email) ->
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    re.test(email)

suboutSvcs.factory "Auction", ($resource, $rootScope) ->
  $resource "#{api_path}/auctions/:opportunityId/:action",
    {opportunityId: '@opportunityId', action:'@action', api_token: '@api_token'},
    {
      select_winner: {method: "PUT"}
      cancel: {method: "PUT"}
      update: {method: "PUT"}
      paginate: {method: "GET"}
      start_negotiation: {method: "PUT", params:{action: "create_negotiation"}}
      decline_negotiation: {method: "PUT", params:{action: "decline_negotiation"}}
    }

suboutSvcs.factory "Rating", ($resource) ->
  r2 = $resource "#{api_path}/ratings/search/:rateeId",
    {rateeId:'@rateeId'}
  r1 = $resource "#{api_path}/ratings/:ratingId",
    {ratingId: '@ratingId'},
    update: { method: "PUT"}
  #r1.search = r2.get.bind(r2)
  r1

suboutSvcs.factory "Opportunity", ($resource) ->
  Opportunity = $resource "#{api_path}/opportunities/:opportunityId",
    {},
    paginate: {method: "GET"}
  Opportunity.defaultBidAmountFor = (opportunity) ->
    if opportunity.forward_auction and opportunity.highest_bid_amount
      amount = parseInt(opportunity.highest_bid_amount)
      return amount
    if !opportunity.forward_auction and opportunity.lowest_bid_amount
      amount = parseInt(opportunity.lowest_bid_amount)
      return amount
    return opportunity.reserve_amount if opportunity.reserve_amount
    null

  Opportunity::isSuboutChoice = (bid) ->
    return false if bid.bidder.recommend == false
    opportunity = this
    if opportunity.forward_auction and opportunity.highest_bid_amount
      amount = parseInt(opportunity.highest_bid_amount)
      bid_amount = parseInt(bid.amount)
      return amount * 0.9 < bid_amount
    if !opportunity.forward_auction and opportunity.lowest_bid_amount
      amount = parseInt(opportunity.lowest_bid_amount)
      bid_amount = parseInt(bid.amount)
      return amount * 1.1 > bid_amount
    return false
    
  Opportunity

suboutSvcs.factory "QuoteRequest", ($resource) ->
  QuoteRequest = $resource "#{api_path}/quote_requests/:quoteRequestId",
    {},
    paginate: {method: "GET"}
  QuoteRequest

suboutSvcs.factory "Vendor", ($resource) ->
  Vendor = $resource "#{api_path}/vendors/:vendorId",
    {
      email: '@email',
    },
    paginate: {method: "GET"}
  Vendor

suboutSvcs.factory "MyBid", ($resource, $rootScope) ->
  $resource "#{api_path}/bids/:bidId/:action",
    {bidId: '@bidId', action: '@action', api_token: $rootScope.token.api_token},
    paginate: {method: "GET"}
    cancel: {method: "PUT", params:{action: "cancel"}}
    accept_negotiation: {method: "PUT", params:{action: "accept_negotiation"}}
    decline_negotiation: {method: "PUT", params:{action: "decline_negotiation"}}
    counter_negotiation: {method: "PUT", params:{action: "counter_negotiation"}}

suboutSvcs.factory "Region", ($resource) ->
  $resource "#{api_path}/regions", {}, {}

suboutSvcs.factory "Product", ($resource) ->
  $resource "#{api_path}/products/:productHandle", {}, {}

suboutSvcs.factory "Bid", ($resource) ->
  $resource "#{api_path}/opportunities/:opportunityId/bids",
    {opportunityId: "@opportunityId"},
    {}

suboutSvcs.factory "Offer", ($resource) ->
  $resource "#{api_path}/opportunities/:opportunityId/offers",
    {opportunityId: "@opportunityId"},
    {}

suboutSvcs.factory "Quote", ($resource) ->
  $resource "#{api_path}/quote_requests/:quoteRequestId/quotes",
    {quoteRequestId: "@quoteRequestId"},
    {}

suboutSvcs.factory "Comment", ($resource) ->
  $resource "#{api_path}/opportunities/:opportunityId/comments",
    {opportunityId: "@opportunityId"},
    {}

suboutSvcs.factory "Event", ($resource, RequestFactory) ->
  Event = $resource "#{api_path}/events/:eventId", {}, { query:{ isArray: false, method: 'GET' } }
  # Event = RequestFactory.createResource url: "#{api_path}/events/:eventId"

  Event::isBidableBy = (company) ->
    this.eventable.bidable and this.eventable.buyer_id isnt company._id
  Event

suboutSvcs.factory "Company", ($resource, $rootScope) ->
  Company = $resource "#{api_path}/companies/:companyId/:action",
    {companyId:'@companyId', action:'@action'},
    update: {method: "PUT"}
    search: {method: "GET", action: "search", isArray: true}
    update_agreement: {method: "PUT", action: "update_agreement"}
    update_regions: {method: "PUT", action: "update_regions"}
    update_notifications: {method: "PUT", action: "update_notifications"}
    update_vehicles: {method: "PUT", action: "update_vehicles"}
    update_product: {method: "PUT", action: "update_product"}

  Company::regionNames = ->
    if this.state_by_state_subscriber
      this.regions.join(', ')
    else
      "Nationwide"

  Company::ratingFromCompany = (company) ->
    for r in this.ratings_taken
      return r if r.rater._id == company._id

  Company::canBeAddedAsFavorite = (company) ->
    return false if this._id == company._id
    return false unless this.favoriting_buyer_ids
    not(company._id in this.favoriting_buyer_ids)

  Company::canSeeEvent = (event) ->
    if this.vehicle_types
      return false unless event.vehicle_type in this.vehicle_types

    return true unless event.eventable.for_favorites_only
    return true if event.eventable.buyer_id is this._id
    event.eventable.buyer_id in this.favoriting_buyer_ids

  Company::canAddFreeBuses = ()->
    this.subscription_plan is "subout-pro-service" && 2 - this.vehicles.length > 0
    

  Company::isBasicUser = ->
    this.subscription_plan is "subout-basic-service"

  Company::isProUser = ->
    this.subscription_plan is "subout-pro-service"

  Company::isFreeUser = ->
    this.subscription_plan is "free"

  Company::canBid = (opportunity) ->
    return false unless opportunity.buyer
    return true if opportunity.buyer_id != this._id && opportunity.status == 'In progress'

  Company::canCancelOrEdit = (opportunity) ->
    unless opportunity.type is 'Emergency'
      return false unless opportunity.status
      return false unless  opportunity.buyer
      return false if this._id isnt opportunity.buyer._id
      return opportunity.status is 'In progress'
    else
      return false unless opportunity.status
      return false unless  opportunity.buyer
      return false if this._id isnt opportunity.buyer._id
      return opportunity.status is 'In progress'

  Company::removeFavoriteBuyerId = (buyerId) ->
    this.favoriting_buyer_ids = _.without(this.favoriting_buyer_ids, buyerId)

  Company::hasNotificationItem = (code) ->
    return _.indexOf(this.notification_items, code) != -1

  Company::addNotificationItem = (code) ->
    this.notification_items.push code
    this.notifcation_items = _.uniq(this.notifiication_items)
    return this.notification_items

  Company::removeNotificationItem = (code) ->
    this.notifcation_items = _.without(this.notifiication_items, code)
    return this.notification_items

  Company::addFavoriteBuyerId = (buyerId) ->
    this.favoriting_buyer_ids.push(buyerId)
    
  Company

suboutSvcs.factory "Token", ($resource) ->
  $resource "#{api_path}/tokens", {}, {}

suboutSvcs.factory "Password", ($resource) ->
  $resource "#{api_path}/passwords", {},
    update:
      method: "PUT"
      params: {}

suboutSvcs.factory "User", ($resource) ->
  $resource "#{api_path}/users/:userId.json",
    {userId:'@userId'},
    {update: {method: "PUT"}}

suboutSvcs.factory "Filter", ($resource) ->
  $resource "#{api_path}/filters.json", {},
    query:
      method: "GET"
      params: {}
      isArray: true

suboutSvcs.factory "Tag", ($resource) ->
  $resource "#{api_path}/tags.json", {},
    query:
      method: "GET"
      params: {}
      isArray: true

suboutSvcs.factory "Favorite", ($resource) ->
  $resource "#{api_path}/favorites/:favoriteId", {}, {}

suboutSvcs.factory "FavoriteInvitation", ($resource) ->
  $resource "#{api_path}/favorite_invitations/:invitationId", {}, {}

suboutSvcs.factory "GatewaySubscription", ($resource) ->
  $resource "#{api_path}/gateway_subscriptions/:subscriptionId", {}, {}

suboutSvcs.factory "FileUploaderSignature", ($resource) ->
  $resource "#{api_path}/file_uploader_signatures/new", {}, {}

suboutSvcs.factory "$numberFormatter", ->
  {
    format: (number, precision) ->
      _.str.numberFormat(parseFloat(number), precision)
  }

suboutSvcs.factory "Authorize", ($rootScope, $location, AuthToken, Region, User, Company, $q) ->
  {
    token: () ->
      this.tokenValue

    authenticate: (token) ->
      defer = $q.defer()

      # Store token on cookie
      $.cookie(AuthToken, token)

      this.tokenValue = token
      $rootScope.token = token
      $rootScope.pusher = new Pusher(token.pusher_key, { encrypted: true })
      $rootScope.channel = $rootScope.pusher.subscribe 'global'

      $rootScope.company = Company.get
        companyId: token.company_id
        api_token: token.api_token
      , (company) ->
        $rootScope.channel.bind 'added_to_favorites', (favorite) ->
          if $rootScope.company._id is favorite.supplier_id
            $rootScope.company.addFavoriteBuyerId(favorite.company_id)
        $rootScope.channel.bind 'removed_from_favorites', (favorite) ->
          if $rootScope.company._id is favorite.supplier_id
            $rootScope.company.removeFavoriteBuyerId(favorite.company_id)
        if company.state_by_state_subscriber
          $rootScope.regions = company.regions
        $rootScope.salesInfoMessages = company.sales_info_messages
        $rootScope.user = User.get
          userId: token.user_id
          api_token: token.api_token
        , (company) ->
          defer.resolve()
          setTimeout( () ->
            $rootScope.$apply()
          , 3000)
      , () ->


      return defer.promise
    check: ->
      if $rootScope.token?.authorized
        return true

      token = $.cookie(AuthToken)
      if !this.token() and token
        return this.authenticate(token)
      else
        return false
  }

suboutSvcs.factory "$appVersioning", ->
  {
    _version : 0,
    _deploy : 0,
    isAppVersionUpToDate : (version) ->
      version = parseFloat(version)
      v = this.getAppVersion()
      if(v > 0 && version != v)
        return false
      this.setAppVersion(version)
      return true

    isDeployTimestampUpToDate : (deploy) ->
      deploy = parseInt(deploy)
      d = this.getDeployTimestamp()
      if(d > 0 && deploy != d)
        return false
      this.setDeployTimestamp(deploy)
      return true

    getAppVersion : ->
      this._version

    setAppVersion : (v) ->
      this._version = v

    getDeployTimestamp : ->
      this._deploy

    setDeployTimestamp : (d) ->
      this._deploy = d

    markForReload : () ->
      this._reload = true

    isMarkedForReload : () ->
      return this._reload == true

  }

suboutSvcs.factory "$appBrowser", ->
  version = parseInt($.browser.version)
  {
    isReallyOld : ->
      ( $.browser.msie and version < 8 ) ||
      ($.browser.mozilla and version < 2)
    isOld : ->
      ($.browser.msie and version < 9) ||
      ($.browser.mozilla and version < 3)
    isMobile : ->
      android = navigator.userAgent.match /Android/i
      iOS = navigator.userAgent.match /iPhone|iPad|iPod/i

      android or iOS
    isPhone : ->
      android = navigator.userAgent.match (/Android/i) and navigator.userAgent.match (/Mobile/i)
      iOS = navigator.userAgent.match /iPhone|iPod/i

      android or iOS
  }

suboutSvcs.factory "myHttpInterceptor", ($q, $appVersioning, $rootScope, $injector, $location, AuthToken) ->
  (promise) ->
    promise.then ((response) ->
      # do something on success
      $rootScope.inPosting = false if response.config.method == "POST"
      mime = "application/json; charset=utf-8"
      if response.headers()["content-type"] is mime
        payloadData = if response.data then response.data.payload else null
        if payloadData
          version = response.data.version
          if(!$appVersioning.isAppVersionUpToDate(version))
            $rootScope.signOut()
            return

          deploy = response.data.deploy
          if(!$appVersioning.isDeployTimestampUpToDate(deploy))
            $appVersioning.markForReload()

          if(!payloadData)
            return $q.reject(response)

          $http = $injector.get('$http')
          if($http.pendingRequests.length == 0)
            $('.loading-animation').removeClass('loading')

            # ghost user time life checking
            if $.cookie("signed_in_time") and $rootScope.company and $rootScope.company.mode == "ghost"
              signed_in_time = $.cookie("signed_in_time")
              current_time = (new Date()).getTime()
              if (current_time - signed_in_time)/1000 > 60 * 60 # checking time differences by seconds
                $.removeCookie("signed_in_time")
                $.removeCookie(AuthToken)
                alert("Your session is expired. You should purchase one of our packages and sign up.")
                window.location.href = "http://subout.com/pricing"

          response.data = payloadData
      response
    ), (response) ->
      $rootScope.inPosting = false if response.config.method == "POST"
      # do something on error
      $('.loading-animation').removeClass('loading')
      response.data = response.data.payload if response.data.payload
      $q.reject response

suboutSvcs.factory "$analytics", ($location) ->
  {
    trackPageview: (url) ->
      if(_gaq)
        url ||= $location.url()
        _gaq.push(['_trackPageview', url])
  }

suboutSvcs.factory "$config", ($location) ->
  {
    suboutBasicSubscriptionUrl: ->
      switch $location.host()
        when "subouttest.herokuapp.com" then "https://subouttest.chargify.com/h/3289099/subscriptions/new"
        when "suboutdev.herokuapp.com" then "https://suboutdev.chargify.com/h/3288752/subscriptions/new"
        when "suboutdemo.herokuapp.com" then "https://suboutdemo.chargify.com/h/3289094/subscriptions/new"
        when "suboutapp.com" then "https://subout.chargify.com/h/3267626/subscriptions/new"
        else "https://suboutvps.chargify.com/h/3307351/subscriptions/new"
    suboutProSubscriptionUrl: ->
      switch $location.host()
        when "subouttest.herokuapp.com" then "https://subouttest.chargify.com/h/3289099/subscriptions/new"
        when "suboutdev.herokuapp.com" then "https://suboutdev.chargify.com/h/3288752/subscriptions/new"
        when "suboutdemo.herokuapp.com" then "https://suboutdemo.chargify.com/h/3289094/subscriptions/new"
        when "suboutapp.com" then "https://subout.chargify.com/h/3267626/subscriptions/new"
        else "https://suboutvps.chargify.com/h/3307356/subscriptions/new"
    nationalSubscriptionUrl: ->
      switch $location.host()
        when "subouttest.herokuapp.com" then "https://subouttest.chargify.com/h/3289099/subscriptions/new"
        when "suboutdev.herokuapp.com" then "https://suboutdev.chargify.com/h/3288752/subscriptions/new"
        when "suboutdemo.herokuapp.com" then "https://suboutdemo.chargify.com/h/3289094/subscriptions/new"
        when "suboutapp.com" then "https://subout.chargify.com/h/3267626/subscriptions/new"
        else "https://suboutvps.chargify.com/h/3289102/subscriptions/new"
    stateByStateSubscriptionUrl: ->
      switch $location.host()
        when "subouttest.herokuapp.com" then "https://subouttest.chargify.com/h/3289101/subscriptions/new"
        when "suboutdev.herokuapp.com" then "https://suboutdev.chargify.com/h/3288754/subscriptions/new"
        when "suboutdemo.herokuapp.com" then "https://suboutdemo.chargify.com/h/3289096/subscriptions/new"
        when "suboutapp.com" then "https://subout.chargify.com/h/3266718/subscriptions/new"
        else "https://suboutvps.chargify.com/h/3289104/subscriptions/new"
  }


suboutSvcs.factory "soPagination", ($rootScope, $location) ->
  {
    paginate: ($scope, model, page, config, callback) ->
      config = config || {}
      config.page = page
      config.api_token = $rootScope.token.api_token
      model.paginate config
      , (data) ->
        info = if callback then callback($scope, data) else {}
        $scope.paginated_results = info.results || data.results
        meta = data.meta
        $scope.page = meta.page
        $scope.maxPage = Math.ceil(meta.count / meta.per_page)
        paginationNumPagesToShow = info.paginationNumPagesToShow || 10
        $scope.startPage = parseInt(($scope.page - 1) / paginationNumPagesToShow) * paginationNumPagesToShow + 1
        $scope.endPage = Math.min($scope.startPage + paginationNumPagesToShow - 1, $scope.maxPage)
        $scope.pages = [$scope.startPage..$scope.endPage]

    setPage: ($scope, page) ->
      if page in [1..$scope.maxPage] and page isnt $scope.page
        $location.search(page: page, sort_by: $scope.sortBy, sort_direction: $scope.sortDirection, query: $scope.query)
  }
