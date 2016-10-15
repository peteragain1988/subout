var app_prefix, subout, suboutDeployTimestamp, suboutPartialPath;

$.cookie.json = true;

$.cookie.defaults.expires = 7;

app_prefix = '/mo';

suboutDeployTimestamp = function() {
  var ts;
  ts = $(document.body).attr('data-subout-deploy');
  if (ts === '--DEPLOY--') {
    ts = new Date().getTime();
  }
  return ts;
};

suboutPartialPath = function(file) {
  var deploy, path;
  path = app_prefix + '/partials/' + file;
  deploy = suboutDeployTimestamp();
  path = '/files/' + deploy + path;
  return path;
};

subout = angular.module("subout", ["ui.utils", "ui.date", "suboutFilters", "suboutServices", "ngCookies", "ngRoute", "mobile-angular-ui", 'angularjs-dropdown-multiselect', 'ui.bootstrap']);

subout.run([
  '$rootScope', '$appVersioning', '$location', '$analytics', function($rootScope, $versioning, $location, $analytics) {
    $rootScope.$on('$routeChangeStart', function(scope, next, current) {
      $('#content').addClass('loading');
      return $analytics.trackPageview();
    });
    $rootScope.$on('$routeChangeSuccess', function(scope, next, current) {
      return $('#content').removeClass('loading');
    });
    $rootScope.$on('$routeChangeStart', function(scope, next, current) {
      if (current && $versioning.isMarkedForReload()) {
        window.location = $location.path();
        return window.location.reload();
      }
    });
    return $rootScope.$on("$routeUpdate", function(scope, next, current) {
      return $analytics.trackPageview();
    });
  }
]);

subout.config([
  "$routeProvider", "$httpProvider", function($routeProvider, $httpProvider) {
    var oldTransformReq, resolveAuth;
    resolveAuth = {
      requiresAuthentication: function(Authorize, $location, $rootScope) {
        var response;
        response = Authorize.check();
        if (response === false) {
          $rootScope.redirectToPath = $location.path();
          $location.path('/sign_in').replace();
          return false;
        } else {
          return response;
        }
      }
    };
    oldTransformReq = $httpProvider.defaults.transformRequest;
    $httpProvider.defaults.transformRequest = function(d, headers) {
      $('.loading-animation').addClass('loading');
      return oldTransformReq[0].apply(this, arguments);
    };
    $httpProvider.responseInterceptors.push('myHttpInterceptor');
    return $routeProvider.when("/sign_in", {
      templateUrl: suboutPartialPath("sign_in.html"),
      controller: SignInCtrl
    }).when("/sign_up", {
      templateUrl: suboutPartialPath("sign_up.html"),
      controller: SignUpCtrl
    }).when("/help", {
      templateUrl: suboutPartialPath("help.html"),
      controller: HelpCtrl
    }).when("/password/new", {
      templateUrl: suboutPartialPath("password-new.html"),
      controller: NewPasswordCtrl
    }).when("/password/edit", {
      templateUrl: suboutPartialPath("password-edit.html"),
      controller: "EditPasswordCtrl"
    }).when("/dashboard", {
      templateUrl: suboutPartialPath("dashboard.html"),
      controller: DashboardCtrl,
      reloadOnSearch: false,
      resolve: resolveAuth
    }).when("/bids", {
      templateUrl: suboutPartialPath("bids.html"),
      controller: MyBidCtrl,
      resolve: resolveAuth
    }).when("/opportunities", {
      templateUrl: suboutPartialPath("opportunities.html"),
      controller: OpportunityCtrl,
      resolve: resolveAuth
    }).when("/available-opportunities", {
      templateUrl: suboutPartialPath("available-opportunities.html"),
      controller: AvailableOpportunityCtrl,
      resolve: resolveAuth
    }).when("/opportunities/:opportunity_reference_number", {
      templateUrl: suboutPartialPath("opportunity-detail.html"),
      controller: OpportunityDetailCtrl,
      resolve: resolveAuth
    }).when("/quote_requests/:quote_request_reference_number", {
      templateUrl: suboutPartialPath("quote-request-detail.html"),
      controller: QuoteRequestDetailCtrl,
      resolve: resolveAuth
    }).when("/favorites", {
      templateUrl: suboutPartialPath("favorites.html"),
      controller: FavoritesCtrl,
      resolve: resolveAuth
    }).when("/companies/:company_id", {
      templateUrl: suboutPartialPath("company-detail.html"),
      controller: CompanyDetailCtrl,
      resolve: resolveAuth
    }).when("/welcome-prelaunch", {
      templateUrl: suboutPartialPath("welcome-prelaunch.html"),
      controller: WelcomePrelaunchCtrl,
      resolve: resolveAuth
    }).when("/settings", {
      templateUrl: suboutPartialPath("settings.html"),
      resolve: resolveAuth
    }).when("/new-opportunity", {
      templateUrl: suboutPartialPath("opportunity-form.html"),
      resolve: resolveAuth
    }).when("/add-favorite", {
      templateUrl: suboutPartialPath("add-new-favorite.html"),
      resolve: resolveAuth
    }).otherwise({
      redirectTo: "/available-opportunities"
    });
  }
]);

subout.value('ui.config', {
  select2: {
    allowClear: true
  }
});

subout.value('AuthToken', 'auth_token_v2');

$.timeago.settings.allowFuture = true;

$.cloudinary.config({
  "cloud_name": "subout"
});


var AvailableOpportunityCtrl, BidNewCtrl, CompanyDetailCtrl, CompanyProfileCtrl, DashboardCtrl, FavoritesCtrl, HelpCtrl, MyBidCtrl, NegotiationCounterOfferCtrl, NegotiationNewCtrl, NewFavoriteCtrl, NewPasswordCtrl, OfferFormCtrl, OpportunityCtrl, OpportunityDetailCtrl, OpportunityFormCtrl, QuoteNewCtrl, QuoteRequestDetailCtrl, SettingCtrl, SignInCtrl, SignUpCtrl, TermsAndConditionsCtrl, WelcomePrelaunchCtrl,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

subout.run(function($rootScope, $location, $appBrowser, $numberFormatter, $timeout, Opportunity, Company, Favorite, User, FileUploaderSignature, AuthToken, Region, Bid, Setting, SharedState, $sce) {
  var REGION_NAMES, d, p, salt, _i, _ref, _results;
  $rootScope._ = _;
  $rootScope.stars = [1, 2, 3, 4, 5];
  d = new Date();
  $rootScope.years = (function() {
    _results = [];
    for (var _i = _ref = d.getFullYear(); _ref <= 1970 ? _i <= 1970 : _i >= 1970; _ref <= 1970 ? _i++ : _i--){ _results.push(_i); }
    return _results;
  }).apply(this);
  $rootScope.reload = null;
  $rootScope.sign_in_time = null;
  salt = function(key) {
    return $rootScope.api_token + "_" + key;
  };
  $rootScope.filterRegionsOnHome = null;
  $rootScope.filterRegionsOnBuybid = null;
  $rootScope.filterRegionsOnHome = $.cookie(salt("filterRegionsOnHome"));
  if ($rootScope.filterRegionsOnHome === null) {
    $rootScope.filterRegionsOnHome = [];
  }
  Setting.get({
    key: "application_message"
  }, function(message) {
    if (message.value) {
      message.value = $sce.trustAsHtml(message.value);
    }
    return $rootScope.application_message = message;
  });
  $rootScope.$watch("filterRegionsOnHome", function(v1, v2) {
    if (v1 !== null) {
      return $.cookie(salt("filterRegionsOnHome"), $rootScope.filterRegionsOnHome);
    }
  });
  if ($appBrowser.isReallyOld()) {
    window.location = "/upgrade_browser.html";
    return;
  }
  $rootScope.isOldBrowser = $appBrowser.isOld();
  $rootScope.validateNumber = function(value) {
    return /^-?\d+\.?\d*$/.test(value);
  };
  $rootScope.validateOptionalNumber = function(value) {
    if (!value) {
      return true;
    }
    return /^\d*$/.test(value);
  };
  $rootScope.userSignedIn = function() {
    var _ref1;
    if ($location.path() === '/new-retail-opportunity') {
      return false;
    }
    if ($location.path() === '/sign_in') {
      return false;
    }
    if (((_ref1 = $rootScope.token) != null ? _ref1.authorized : void 0) || $.cookie(AuthToken)) {
      return true;
    }
  };
  $rootScope.isMobile = $appBrowser.isMobile();
  $rootScope.isPhone = $appBrowser.isPhone();
  $rootScope.currentPath = function() {
    return $location.path();
  };
  $rootScope.currentMenuName = function() {
    if ($location.path() === '/dashboard') {
      return "Home";
    }
    if ($location.path() === '/available-opportunities') {
      return "Buy/Bid Now";
    }
    if ($location.path() === '/bids') {
      return "My Bids";
    }
    if ($location.path() === '/opportunities') {
      return "My Opportunities";
    }
    if ($location.path() === '/favorites') {
      return "Favorites";
    }
  };
  $rootScope.setModal = function(url) {
    return $rootScope.modal = url;
  };
  $rootScope.closeModal = function() {
    SharedState.turnOff('modal1');
    $rootScope.modal = '';
    return $rootScope.opportunity = null;
  };
  $rootScope.signOut = function() {
    $.removeCookie(AuthToken);
    window.location = "#/sign_in";
    return window.location.reload(true);
  };
  $rootScope.TRIP_TYPES = ["One way", "Round trip", "Over the road"];
  $rootScope.PAYMENT_METHODS = ["Visa", "MasterCard", "Discover", "American Express", "Check/Money Order", "Company Check", "Bank/Wire Transfer", "Invoice", "Paypal"];
  $rootScope.VEHICLE_TYPES = ["Sedan", "Limo", "Party Bus", "Limo Bus", "Mini Bus", "Motorcoach", "Double Decker Motorcoach", "Executive Coach", "Sleeper Bus", "School Bus"];
  $rootScope.NOTIFICATION_TYPES = [
    {
      name: "Opportunity Post",
      type: "email",
      code: "opportunity-new"
    }, {
      name: "Opportunity Expired",
      type: "email",
      code: "opportunity-expire"
    }, {
      name: "Opportunity Completed",
      type: "email",
      code: "opportunity-complete"
    }, {
      name: "Opportunity Win",
      type: "email",
      code: "opportunity-win"
    }, {
      name: "New Bid",
      type: "email",
      code: "bid-new"
    }, {
      name: "Update Product",
      type: "email",
      code: "account-update-product"
    }, {
      name: "Account Locked",
      type: "email",
      code: "account-locked"
    }, {
      name: "Expired Card",
      type: "email",
      code: "account-expired-card"
    }, {
      name: "Opportunity Post",
      type: "mobile",
      code: "mobile-opportunity-new"
    }
  ];
  $rootScope.ALL_REGIONS = {
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "District of Columbia": "DC",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Missouri": "MO",
    "Mississippi": "MS",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY"
  };
  $rootScope.ALL_REGION_OBJECTS = [
    {
      id: "AL",
      label: "Alabama"
    }, {
      id: "AK",
      label: "Alaska"
    }, {
      id: "AZ",
      label: "Arizona"
    }, {
      id: "AR",
      label: "Arkansas"
    }, {
      id: "CA",
      label: "California"
    }, {
      id: "CO",
      label: "Colorado"
    }, {
      id: "CT",
      label: "Connecticut"
    }, {
      id: "DE",
      label: "Delaware"
    }, {
      id: "DC",
      label: "District of Columbia"
    }, {
      id: "FL",
      label: "Florida"
    }, {
      id: "GA",
      label: "Georgia"
    }, {
      id: "HI",
      label: "Hawaii"
    }, {
      id: "ID",
      label: "Idaho"
    }, {
      id: "IL",
      label: "Illinois"
    }, {
      id: "IN",
      label: "Indiana"
    }, {
      id: "IA",
      label: "Iowa"
    }, {
      id: "KS",
      label: "Kansas"
    }, {
      id: "KY",
      label: "Kentucky"
    }, {
      id: "LA",
      label: "Louisiana"
    }, {
      id: "ME",
      label: "Maine"
    }, {
      id: "MD",
      label: "Maryland"
    }, {
      id: "MA",
      label: "Massachusetts"
    }, {
      id: "MI",
      label: "Michigan"
    }, {
      id: "MN",
      label: "Minnesota"
    }, {
      id: "MO",
      label: "Missouri"
    }, {
      id: "MS",
      label: "Mississippi"
    }, {
      id: "MT",
      label: "Montana"
    }, {
      id: "NE",
      label: "Nebraska"
    }, {
      id: "NV",
      label: "Nevada"
    }, {
      id: "NH",
      label: "New Hampshire"
    }, {
      id: "NJ",
      label: "New Jersey"
    }, {
      id: "NM",
      label: "New Mexico"
    }, {
      id: "NY",
      label: "New York"
    }, {
      id: "NC",
      label: "North Carolina"
    }, {
      id: "ND",
      label: "North Dakota"
    }, {
      id: "OH",
      label: "Ohio"
    }, {
      id: "OK",
      label: "Oklahoma"
    }, {
      id: "OR",
      label: "Oregon"
    }, {
      id: "PA",
      label: "Pennsylvania"
    }, {
      id: "RI",
      label: "Rhode Island"
    }, {
      id: "SC",
      label: "South Carolina"
    }, {
      id: "SD",
      label: "South Dakota"
    }, {
      id: "TN",
      label: "Tennessee"
    }, {
      id: "TX",
      label: "Texas"
    }, {
      id: "UT",
      label: "Utah"
    }, {
      id: "VT",
      label: "Vermont"
    }, {
      id: "VA",
      label: "Virginia"
    }, {
      id: "WA",
      label: "Washington"
    }, {
      id: "WV",
      label: "West Virginia"
    }, {
      id: "WI",
      label: "Wisconsin"
    }, {
      id: "WY",
      label: "Wyoming"
    }
  ];
  REGION_NAMES = (function() {
    var _results1;
    _results1 = [];
    for (p in $rootScope.ALL_REGIONS) {
      _results1.push(p);
    }
    return _results1;
  })();
  $rootScope.allRegions = REGION_NAMES.slice(0);
  $rootScope.setupFileUploader = function() {
    var $fileUploader;
    $fileUploader = $("input.cloudinary-fileupload[type=file]");
    if (!($fileUploader.length > 0)) {
      return;
    }
    $fileUploader.hide();
    return FileUploaderSignature.get({}, function(data) {
      var $fileProgressBar, previewUrl, progressImageUpload, setImageUpload;
      $fileProgressBar = $('#progress .bar');
      $fileUploader.attr('data-form-data', JSON.stringify(data));
      $fileUploader.show();
      $fileUploader.cloudinary_fileupload({
        progress: function(e, data) {
          var progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          return $fileProgressBar.css('width', progress + '%');
        }
      });
      previewUrl = function(data) {
        return $.cloudinary.url(data.result.public_id, {
          format: data.result.format
        });
      };
      setImageUpload = function(data) {
        $("form .image-preview").attr('src', previewUrl(data)).show();
        return $("form .file-upload-public-id").val(data.result.public_id);
      };
      progressImageUpload = function(element, progressing) {
        $('form btn-primary').prop('disabled', !progressing);
        $fileProgressBar.toggle(progressing);
        return $(element).toggle(!progressing);
      };
      $fileUploader.off('fileuploadstart');
      $fileUploader.on('fileuploadstart', function(e, data) {
        return progressImageUpload(this, true);
      });
      $fileUploader.off('cloudinarydone');
      return $fileUploader.on('cloudinarydone', function(e, data) {
        progressImageUpload(this, false);
        if (data.result.resource_type !== "image") {
          return alert("Sorry, only images are supported.");
        } else {
          return setImageUpload(data);
        }
      });
    });
  };
  $rootScope.displaySettings = function(selectedTab) {
    if (selectedTab == null) {
      selectedTab = "user-login";
    }
    $rootScope.selectedTab = selectedTab;
    $rootScope.setModal(suboutPartialPath('settings.html'));
    return $rootScope.setupFileUploader();
  };
  $rootScope.displayNegotiationForm = function(opportunity, bid) {
    $rootScope.bid = bid;
    $rootScope.opportunity = opportunity;
    $rootScope.setModal(suboutPartialPath('negotiation-new.html'));
    return $rootScope.$broadcast('modalOpened');
  };
  $rootScope.displayNegotiationCounterForm = function(opportunity, bid) {
    $rootScope.bid = bid;
    $rootScope.opportunity = opportunity;
    $rootScope.setModal(suboutPartialPath('negotiation-counter-form.html'));
    return $rootScope.$broadcast('modalOpened');
  };
  $rootScope.displayTermsAndConditionsForm = function() {
    if (!$rootScope.company.tac_agreement) {
      $rootScope.setModal(suboutPartialPath('terms-and-conditions.html'));
      SharedState.turnOn('modal1');
      return $rootScope.$broadcast('modalOpened');
    }
  };
  $rootScope.displayNewBidForm = function(opportunity) {
    if (!$rootScope.company.dot_number) {
      $rootScope.setModal(suboutPartialPath('dot-required.html'));
      return;
    }
    if ($rootScope.company.subscription_plan !== 'free' && $rootScope.subscription) {
      if (!$rootScope.subscription.has_valid_credit_card) {
        $rootScope.setModal(suboutPartialPath('update-credit-card.html'));
        return;
      }
    }
    if (opportunity.ada_required && !$rootScope.company.has_ada_vehicles) {
      $rootScope.setModal(suboutPartialPath('ada-required.html'));
      return;
    }
    $rootScope.setOpportunity(opportunity);
    $rootScope.setModal(suboutPartialPath('bid-new.html'));
    return $rootScope.$broadcast('modalOpened');
  };
  $rootScope.displayNewQuoteForm = function(quote_request) {
    if (!$rootScope.company.dot_number) {
      $rootScope.setModal(suboutPartialPath('dot-required.html'));
      return;
    }
    if ($rootScope.company.subscription_plan !== 'free' && $rootScope.subscription) {
      if (!$rootScope.subscription.has_valid_credit_card) {
        $rootScope.setModal(suboutPartialPath('update-credit-card.html'));
        return;
      }
    }
    $rootScope.setQuoteRequest(quote_request);
    $rootScope.setModal(suboutPartialPath('quote-new.html'));
    return $rootScope.$broadcast('modalOpened');
  };
  $rootScope.displayNewOfferForm = function(opportunity) {
    $rootScope.setOpportunity(opportunity);
    $rootScope.setModal(suboutPartialPath('offer-form.html'));
    return $rootScope.$broadcast('modalOpened');
  };
  $rootScope.displayNewOpportunityForm = function() {
    $rootScope.setModal(suboutPartialPath('opportunity-form.html'));
    console.log(suboutPartialPath('opportunity-form.html'));
    return $rootScope.setupFileUploader();
  };
  $rootScope.displayNewFavoriteForm = function() {
    $rootScope.$broadcast('clearNewFavoriteForm');
    return $rootScope.setModal(suboutPartialPath('add-new-favorite.html'));
  };
  $rootScope.setQuoteRequest = function(quote_request) {
    if (quote_request.id) {
      return $rootScope.quote_request = QuoteRequest.get({
        api_token: $rootScope.token.api_token,
        quoteRequestId: quote_request._id
      });
    } else {
      return $rootScope.quote_request = quote_request;
    }
  };
  $rootScope.setOpportunity = function(opportunity) {
    if (opportunity.id) {
      return $rootScope.opportunity = Opportunity.get({
        api_token: $rootScope.token.api_token,
        opportunityId: opportunity._id
      });
    } else {
      return $rootScope.opportunity = opportunity;
    }
  };
  $rootScope.cloneOpportunity = function(opportunity) {
    var property, _j, _len, _ref1;
    $rootScope.opportunity = angular.copy(opportunity);
    _ref1 = ["_id", "start_date", "start_time", "end_date", "end_time", "tracking_id"];
    for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
      property = _ref1[_j];
      delete $rootScope.opportunity[property];
    }
    return $rootScope.opportunity.clone = true;
  };
  $rootScope.displayRating = function(rating) {
    return alert("Not implemented yet, I think that it should display popup with rating details.");
  };
  $rootScope.addToFavorites = function(company) {
    $rootScope.notice = null;
    return Favorite.save({
      supplier_id: company._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      company.favoriting_buyer_ids || (company.favoriting_buyer_ids = []);
      company.favoriting_buyer_ids.push($rootScope.company._id);
      $rootScope.notice = "Successfully added to favorites.";
      return $timeout(function() {
        $rootScope.notice = null;
        return $("#modal").modal("hide");
      }, 2000);
    });
  };
  $rootScope.displayCompanyProfile = function(company_id) {
    return Company.get({
      api_token: $rootScope.token.api_token,
      companyId: company_id
    }, function(company) {
      $rootScope.other_company = company;
      return $rootScope.setModal(suboutPartialPath('company-profile.html'));
    });
  };
  $rootScope.dateOptions = {
    dateFormat: 'mm/dd/yy'
  };
  $rootScope.errorMessages = function(errors) {
    var result;
    result = [];
    $.each(errors, function(key, errors) {
      var field;
      field = _.str.humanize(key);
      return $.each(errors, function(i, error) {
        if (key === "base") {
          return result.push(_.str.humanize(error));
        } else {
          return result.push("" + field + " " + error);
        }
      });
    });
    return result;
  };
  $rootScope.alertError = function(errors) {
    var $alertError, close, errorMessage, errorMessages, _j, _len;
    errorMessages = $rootScope.errorMessages(errors);
    $alertError = $("<div class='alert alert-error alert-danger'></div>");
    close = '<a class="close" data-dismiss="alert" href="#">&times;</a>';
    $alertError.append(close);
    for (_j = 0, _len = errorMessages.length; _j < _len; _j++) {
      errorMessage = errorMessages[_j];
      $alertError.append("<p>" + errorMessage + "</p>");
    }
    return $alertError;
  };
  $rootScope.showErrors = function(errors) {
    return alert($rootScope.errorMessages(errors).join('\n'));
  };
  $rootScope.alertInfo = function(messages) {
    var $alertInfo, close, info, _j, _len;
    $alertInfo = $("<div class='alert alert-info'></div>");
    close = '<a class="close" data-dismiss="alert" href="#">&times;</a>';
    $alertInfo.append(close);
    for (_j = 0, _len = messages.length; _j < _len; _j++) {
      info = messages[_j];
      $alertInfo.append("<p>" + info + "</p>");
    }
    return $alertInfo;
  };
  return $rootScope.winOpportunityNow = function(opportunity) {
    var bid;
    if (!$rootScope.company.dot_number) {
      $rootScope.setModal(suboutPartialPath('dot-required.html'));
      $("#modal").modal("show");
      return;
    }
    if (!confirm("Win it now price is $" + ($numberFormatter.format(opportunity.win_it_now_price, 2)) + ". Do you want to proceed?")) {
      return;
    }
    bid = {
      amount: opportunity.win_it_now_price,
      vehicle_count: opportunity.vehicle_count
    };
    return Bid.save({
      bid: bid,
      api_token: $rootScope.token.api_token,
      opportunityId: opportunity._id
    }, function() {
      return $rootScope.closeModal();
    }, function(content) {
      return alert("An error occured on your bid!\n" + $rootScope.errorMessages(content.data.errors).join("\n"));
    });
  };
});

WelcomePrelaunchCtrl = function(AuthToken) {
  return $.removeCookie(AuthToken);
};

OpportunityFormCtrl = function($scope, $rootScope, $location, Auction) {
  var successUpdate;
  $rootScope.inPosting = false;
  if (!$scope.opportunity) {
    $scope.opportunity = {};
    $scope.opportunity.vehicle_count = 1;
  }
  $scope.types = ["Vehicle Needed", "Vehicle for Hire", "Special", "Emergency", "Buy or Sell Parts and Vehicles"];
  successUpdate = function() {
    $rootScope.closeModal();
    return $rootScope.inPosting = false;
  };
  $scope.save = function() {
    var opportunity;
    $rootScope.inPosting = true;
    opportunity = $scope.opportunity;
    opportunity.bidding_ends = $('#opportunity_ends').val();
    opportunity.start_date = $('#opportunity_start_date').val();
    opportunity.end_date = $('#opportunity_end_date').val();
    opportunity.image_id = $('#opportunity_image_id').val();
    opportunity.start_time = $("#opportunity_start_time").val();
    opportunity.end_time = $("#opportunity_end_time").val();
    if (opportunity.quick_winnable === false) {
      opportunity.win_it_now_price = null;
    }
    if (opportunity._id) {
      return Auction.update({
        opportunityId: opportunity._id,
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        $rootScope.$emit('refreshOpportunity', opportunity);
        return successUpdate();
      }, function(content) {
        return showErrors(content.data.errors);
      });
    } else {
      return Auction.save({
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        return successUpdate();
      }, function(content) {
        return showErrors(content.data.errors);
      });
    }
  };
  $scope.isForSpecialRegion = function() {
    var type;
    type = $scope.opportunity.type;
    if ((type === "Special") || (type === "Buy or Sell Parts and Vehicles")) {
      return true;
    } else {
      return false;
    }
  };
  return $scope.setOpportunityForwardAuction = function() {
    var type;
    type = $scope.opportunity.type;
    if (type === "Vehicle Needed") {
      return $scope.opportunity.forward_auction = false;
    } else if (type === "Vehicle for Hire") {
      return $scope.opportunity.forward_auction = true;
    }
  };
};

NegotiationCounterOfferCtrl = function($scope, $rootScope, Bid, Opportunity, MyBid, Auction) {
  var bid;
  bid = angular.copy($rootScope.bid);
  $scope.bid = {
    id: bid._id,
    amount: bid.amount
  };
  return $scope.save = function() {
    return MyBid.counter_negotiation({
      bidId: $scope.bid.id,
      bid: $scope.bid
    }, function(opportunity) {
      _.extend($rootScope.opportunity, opportunity);
      return $rootScope.closeModal();
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

NegotiationNewCtrl = function($scope, $rootScope, Bid, Opportunity, MyBid, Auction) {
  var bid;
  bid = angular.copy($rootScope.bid);
  $scope.bid = {
    id: bid._id,
    amount: bid.amount
  };
  return $scope.save = function() {
    return Auction.start_negotiation({
      bid: $scope.bid,
      opportunityId: $rootScope.opportunity._id
    }, function(opportunity) {
      _.extend($rootScope.opportunity, opportunity);
      return $rootScope.closeModal();
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

QuoteNewCtrl = function($scope, $rootScope, Bid, QuoteRequest, Quote) {
  var _base;
  if (!$scope.quote) {
    $scope.quote = {};
  }
  $scope.quote.vehicle_count = $scope.quote_request.vehicle_count;
  (_base = $scope.quote).vehicle_count || (_base.vehicle_count = 1);
  $scope.quote.vehicles = [];
  $scope.$watch("quote.vehicle_count", function() {
    $scope.quote.vehicles = [];
    return _($scope.quote.vehicle_count).times(function() {
      return $scope.quote.vehicles.push({});
    });
  });
  $scope.hideAlert = function() {
    return $scope.errors = null;
  };
  $scope.$on('modalOpened', function() {
    return $scope.hideAlert();
  });
  $scope.validateVehicleCountLimit = function(value) {
    if (isNaN(value) || value === "") {
      return true;
    }
    value = parseFloat(value);
    return value <= $scope.quote_request.vehicle_count;
  };
  return $scope.save = function() {
    console.log(123123);
    return Quote.save({
      quote: $scope.quote,
      api_token: $rootScope.token.api_token,
      quoteRequestId: $rootScope.quote_request._id
    }, function(data) {
      $rootScope.company.today_bids_count += 1;
      $rootScope.company.month_bids_count += 1;
      return $rootScope.closeModal();
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

BidNewCtrl = function($scope, $rootScope, Bid, Opportunity) {
  var _base;
  if (!$scope.bid) {
    $scope.bid = {};
  }
  $scope.bid.vehicle_count = $scope.opportunity.vehicle_count;
  (_base = $scope.bid).vehicle_count || (_base.vehicle_count = 1);
  $scope.bid.amount = Opportunity.defaultBidAmountFor($scope.opportunity);
  $scope.bid.vehicles = [];
  $scope.$watch("bid.vehicle_count", function() {
    $scope.bid.vehicles = [];
    return _($scope.bid.vehicle_count).times(function() {
      return $scope.bid.vehicles.push({});
    });
  });
  $scope.hideAlert = function() {
    return $scope.errors = null;
  };
  $scope.$on('modalOpened', function() {
    return $scope.hideAlert();
  });
  $scope.validateReserveAmount = function(value) {
    if (isNaN(value)) {
      return true;
    }
    value = parseFloat(value);
    if ($scope.opportunity.reserve_amount) {
      if ($scope.opportunity.forward_auction) {
        return $scope.opportunity.reserve_amount <= value;
      } else {
        return $scope.opportunity.reserve_amount >= value;
      }
    } else {
      return true;
    }
  };
  $scope.validateAutoBiddingLimit = function(value) {
    if (isNaN(value) || value === "") {
      return true;
    }
    value = parseFloat(value);
    if ($scope.bid.amount) {
      if ($scope.opportunity.forward_auction) {
        return $scope.bid.amount <= value;
      } else {
        return $scope.bid.amount >= value;
      }
    } else {
      return true;
    }
  };
  $scope.validateWinItNowPrice = function(value) {
    if (isNaN(value) || value === "") {
      return true;
    }
    value = parseFloat(value);
    if ($scope.opportunity.quick_winnable && $scope.opportunity.win_it_now_price) {
      if ($scope.opportunity.forward_auction) {
        return $scope.opportunity.win_it_now_price > value;
      } else {
        return $scope.opportunity.win_it_now_price < value;
      }
    } else {
      return true;
    }
  };
  $scope.validateVehicleCount = function(value) {
    if (isNaN(value) || value === "") {
      return true;
    }
    value = parseFloat(value);
    return value <= $scope.opportunity.vehicle_count;
  };
  $scope.validateVehicleCountLimit = function(value) {
    if (isNaN(value) || value === "") {
      return true;
    }
    value = parseFloat(value);
    return value <= $scope.bid.vehicle_count;
  };
  return $scope.save = function() {
    return Bid.save({
      bid: $scope.bid,
      api_token: $rootScope.token.api_token,
      opportunityId: $rootScope.opportunity._id
    }, function(data) {
      $rootScope.company.today_bids_count += 1;
      $rootScope.company.month_bids_count += 1;
      return $rootScope.closeModal();
    }, function(content) {
      return $scope.errors = $scope.showErrors(content.data.errors);
    });
  };
};

MyBidCtrl = function($scope, $rootScope, MyBid, $location, soPagination) {
  $scope.my_bids = [];
  $scope.pages = [];
  $scope.startPage = 1;
  $scope.page = $location.search().page || 1;
  $scope.endPage = 1;
  $scope.maxPage = 1;
  $scope.setPage = function(page) {
    return soPagination.setPage($scope, page);
  };
  $scope.loadMoreBids = function(page) {
    if (page == null) {
      page = 1;
    }
    return soPagination.paginate($scope, MyBid, page, {}, function(scope, data) {
      return {
        results: data.bids
      };
    });
  };
  return $scope.loadMoreBids($scope.page);
};

FavoritesCtrl = function($scope, $rootScope, Favorite) {
  $scope.favoriteCompanies = Favorite.query({
    api_token: $rootScope.token.api_token
  });
  return $scope.removeFavorite = function(company) {
    return Favorite["delete"]({
      api_token: $rootScope.token.api_token,
      favoriteId: company._id
    }, function() {
      var index;
      index = _.indexOf($scope.favoriteCompanies, company);
      return $scope.favoriteCompanies.splice(index, 1);
    });
  };
};

NewFavoriteCtrl = function($scope, $rootScope, $route, $location, Favorite, Company, FavoriteInvitation, soValidateEmail) {
  var successUpdate;
  $scope.companyNotFound = false;
  $scope.showInvitation = false;
  $scope.foundCompanies = [];
  $scope.invitation = {};
  successUpdate = function() {
    if ($rootScope.isMobile) {
      return $location.path('/favorites');
    } else {
      return $rootScope.closeModal();
    }
  };
  $scope.addToFavorites = function(company) {
    return Favorite.save({
      supplier_id: company._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      $route.reload();
      return successUpdate();
    });
  };
  return $scope.findSupplier = function() {
    if ($scope.supplierQuery === $rootScope.company.email) {
      return true;
    }
    $scope.foundCompanies = Company.search({
      query: $scope.supplierQuery,
      api_token: $rootScope.token.api_token,
      action: "search"
    }, function(companies) {
      companies = _.reject(companies, function(c) {
        return c._id === $rootScope.company._id;
      });
      $scope.companyNotFound = companies.length === 0;
      if ($scope.companyNotFound) {
        $scope.showInvitation = true;
        $scope.invitation.supplier_email = $scope.supplierQuery;
        return $scope.invitation.message = "" + $rootScope.company.name + " would like to add you as a favorite supplier on SubOut.";
      } else {
        return $scope.showInvitation = false;
      }
    });
    return $scope.sendInvitation = function() {
      return FavoriteInvitation.save({
        favorite_invitation: $scope.invitation,
        api_token: $rootScope.token.api_token
      }, function() {
        return successUpdate();
      });
    };
  };
};

AvailableOpportunityCtrl = function($scope, $rootScope, $location, Opportunity, $filter, soPagination) {
  var availableToCurrentCompany;
  $rootScope.displayTermsAndConditionsForm();
  $scope.filterDepatureDate = null;
  $scope.opportunities = [];
  $scope.pages = [];
  $scope.page = $location.search().page || 1;
  $scope.endPage = 1;
  $scope.maxPage = 1;
  $scope.filterVehicleTypes = $rootScope.company.vehicle_types;
  $scope.filterTripType = null;
  $scope.filterRegions = $rootScope.filterRegionsOnBuybid;
  $scope.sortItems = [
    {
      value: "created_at,asc",
      label: "Created (ascending)"
    }, {
      value: "created_at,desc",
      label: "Created (descending)"
    }, {
      value: "bidding_ends_at,asc",
      label: "Ends (ascending)"
    }, {
      value: "bidding_ends_at,desc",
      label: "Ends (descending)"
    }
  ];
  $rootScope.$watch("company.vehicle_types.length", function() {
    return $scope.filterVehicleTypes = angular.copy($rootScope.company.vehicle_types);
  });
  $rootScope.$watch("company.regions.length", function() {
    return $scope.filterRegions = angular.copy($rootScope.company.regions);
  });
  availableToCurrentCompany = function(opportunity) {
    return opportunity.buyer_id !== $rootScope.company._id;
  };
  $rootScope.channel.bind('event_created', function(event) {
    var affectedOpp;
    affectedOpp = _.find($scope.paginated_results, function(opportunity) {
      return opportunity._id === event.eventable._id;
    });
    if (availableToCurrentCompany(event.eventable)) {
      if (affectedOpp && event.eventable.status === 'In progress') {
        return Opportunity.get({
          api_token: $rootScope.token.api_token,
          opportunityId: event.eventable._id
        }, function(opportunity) {
          return $scope.paginated_results[$scope.paginated_results.indexOf(affectedOpp)] = opportunity;
        });
      } else {
        return $scope.reloadOpportunities();
      }
    } else if (affectedOpp) {
      return $scope.reloadOpportunities();
    }
  });
  $scope.loadMoreOpportunities = function(page) {
    var regions, vehicle_types;
    if (page == null) {
      page = 1;
    }
    regions = null;
    vehicle_types = null;
    if ($scope.filterRegions) {
      regions = $scope.filterRegions.join(',');
    }
    if ($scope.filterVehicleTypes) {
      vehicle_types = $scope.filterVehicleTypes.join(',');
    }
    return soPagination.paginate($scope, Opportunity, page, {
      sort_by: $scope.sortBy,
      sort_direction: $scope.sortDirection,
      start_date: $filter('date')($scope.filterDepatureDate, "yyyy-MM-dd"),
      vehicle_types: vehicle_types,
      trip_type: $scope.filterTripType,
      regions: regions
    }, function(scope, data) {
      return {
        results: data.opportunities
      };
    });
  };
  $scope.setPage = function(page) {
    return soPagination.setPage($scope, page);
  };
  $scope.reloadOpportunities = function() {
    return $scope.loadMoreOpportunities($scope.page);
  };
  $scope.sortOpportunities = function(sortBy) {
    if ($scope.sortBy === sortBy) {
      if ($scope.sortDirection === "asc") {
        $scope.sortDirection = "desc";
      } else {
        $scope.sortDirection = "asc";
      }
    } else {
      $scope.sortDirection = "asc";
      $scope.sortBy = sortBy;
    }
    return $scope.reloadOpportunities();
  };
  $scope.sortMobileOpportunity = function() {
    var sortOptions;
    sortOptions = $scope.sortOption.split(",");
    $scope.sortBy = sortOptions[0];
    $scope.sortDirection = sortOptions[1];
    return $scope.reloadOpportunities();
  };
  $scope.dateOptions = {
    dateFormat: 'mm/dd/yy'
  };
  $scope.sortOpportunities('bidding_ends_at');
  $scope.$watch("filterDepatureDate", function(oldValue, newValue) {
    if (oldValue !== newValue) {
      return $scope.loadMoreOpportunities(1);
    }
  });
  $scope.$watch("filterVehicleTypes", function(oldValue, newValue) {
    if (oldValue !== newValue) {
      return $scope.loadMoreOpportunities(1);
    }
  });
  $scope.$watch("filterTripType", function(oldValue, newValue) {
    if (oldValue !== newValue) {
      return $scope.loadMoreOpportunities(1);
    }
  });
  return $scope.$watch("filterRegions", function(oldValue, newValue) {
    if (oldValue !== newValue) {
      $rootScope.filterRegionsOnBuybid = $scope.filterRegions;
      return $scope.loadMoreOpportunities(1);
    }
  });
};

OpportunityCtrl = function($scope, $rootScope, $location, Auction, soPagination) {
  $scope.opportunities = [];
  $scope.pages = [];
  $scope.startPage = 1;
  $scope.page = $location.search().page || 1;
  $scope.sortBy = $location.search().sort_by || "created_at";
  $scope.sortDirection = $location.search().sort_direction || "desc";
  $scope.query = $location.search().query;
  $scope.endPage = 1;
  $scope.maxPage = 1;
  $scope.fullTextSearch = function(event) {
    var query;
    if ($scope.query && $scope.query !== "") {
      query = $scope.query;
    } else {
      query = null;
    }
    return $location.search({
      page: 1,
      sort_by: $scope.sortBy,
      sort_direction: $scope.sortDirection,
      query: query
    });
  };
  $scope.loadMoreOpportunities = function(page) {
    if (page == null) {
      page = 1;
    }
    return soPagination.paginate($scope, Auction, page, {
      sort_by: $scope.sortBy,
      sort_direction: $scope.sortDirection,
      query: $scope.query
    }, function(scope, data) {
      return {
        results: data.opportunities
      };
    });
  };
  $scope.setPage = function(page) {
    return soPagination.setPage($scope, page);
  };
  $scope.sortOpportunities = function(sortBy) {
    if ($scope.sortBy === sortBy) {
      if ($scope.sortDirection === "asc") {
        $scope.sortDirection = "desc";
      } else {
        $scope.sortDirection = "asc";
      }
    } else {
      $scope.sortDirection = "desc";
      $scope.sortBy = sortBy;
    }
    return $location.search({
      page: 1,
      sort_by: $scope.sortBy,
      sort_direction: $scope.sortDirection,
      query: $scope.query
    });
  };
  return $scope.loadMoreOpportunities($scope.page);
};

QuoteRequestDetailCtrl = function($rootScope, $scope, $routeParams, $location, $timeout, Bid, Auction, Opportunity, Comment, MyBid, QuoteRequest) {
  var fiveMinutes, quote_request_id, refreshQuoteRequest, reloadQuoteRequest, updateFiveMinutesAgo;
  fiveMinutes = 5 * 60 * 1000;
  quote_request_id = $routeParams.quote_request_reference_number;
  updateFiveMinutesAgo = function() {
    $scope.fiveMinutesAgo = new Date().getTime() - fiveMinutes;
    return $timeout(updateFiveMinutesAgo, 5000);
  };
  updateFiveMinutesAgo();
  reloadQuoteRequest = function() {
    return $scope.quote_request = QuoteRequest.get({
      api_token: $rootScope.token.api_token,
      quoteRequestId: quote_request_id
    }, function(content) {
      return true;
    }, function(content) {
      alert("Record not found");
      return $location.path("/dashboard");
    });
  };
  refreshQuoteRequest = function() {
    return setTimeout(function() {
      reloadQuoteRequest();
      return refreshQuoteRequest();
    }, fiveMinutes);
  };
  refreshQuoteRequest();
  reloadQuoteRequest();
  $rootScope.channel.bind('event_created', function(event) {
    if (event.eventable._id === $scope.quote_request._id) {
      return reloadQuoteRequest();
    }
  });
  return $rootScope.$on('reloadQuoteRequest', function(e, _quote_request) {
    return $scope.quote_request = _quote_request;
  });
};

OpportunityDetailCtrl = function($rootScope, $scope, $routeParams, $location, $timeout, Bid, Auction, Opportunity, Comment, MyBid) {
  var fiveMinutes, halfDay, opportunity_id, refreshOpportunity, reloadOpportunity, updateFiveMinutesAgo;
  fiveMinutes = 5 * 60 * 1000;
  halfDay = 12 * 60 * 60 * 1000;
  opportunity_id = $routeParams.opportunity_reference_number;
  $scope.comment = {};
  updateFiveMinutesAgo = function() {
    $scope.fiveMinutesAgo = new Date().getTime() - fiveMinutes;
    $scope.halfDayAgo = new Date().getTime() - halfDay;
    return $timeout(updateFiveMinutesAgo, 5000);
  };
  updateFiveMinutesAgo();
  reloadOpportunity = function() {
    return $scope.opportunity = Opportunity.get({
      api_token: $rootScope.token.api_token,
      opportunityId: opportunity_id
    }, function(content) {
      return true;
    }, function(content) {
      alert("Record not found");
      return $location.path("/dashboard");
    });
  };
  refreshOpportunity = function() {
    return setTimeout(function() {
      reloadOpportunity();
      return refreshOpportunity();
    }, fiveMinutes);
  };
  refreshOpportunity();
  reloadOpportunity();
  $rootScope.channel.bind('event_created', function(event) {
    if (event.eventable._id === $scope.opportunity._id) {
      return reloadOpportunity();
    }
  });
  $rootScope.$on('refreshOpportunity', function(e, _opportunity) {
    return $scope.opportunity = _opportunity;
  });
  $scope.hideAlert = function() {
    return $scope.errors = null;
  };
  $scope.acceptNegotiation = function(bid) {
    if (!confirm("Are you sure to accept this offer?")) {
      return;
    }
    return MyBid.accept_negotiation({
      bidId: bid._id
    }, {}, function(opportunity) {
      _.extend($rootScope.opportunity, opportunity);
      return $rootScope.closeModal();
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  $scope.declineOffer = function(bid) {
    if (!confirm("Are you sure to decline this offer?")) {
      return;
    }
    return MyBid.decline_negotiation({
      bidId: bid._id
    }, {}, function(opportunity) {
      return _.extend($rootScope.opportunity, opportunity);
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  $scope.declineCounterOffer = function(opportunity, bid) {
    if (!confirm("Are you sure to decline this offer?")) {
      return;
    }
    return Auction.decline_negotiation({
      bid_id: bid._id,
      opportunityId: opportunity._id
    }, function(opportunity) {
      return _.extend($rootScope.opportunity, opportunity);
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  $scope.cancelOpportunity = function() {
    if (!confirm("Are you sure to cancel your opportunity?")) {
      return;
    }
    return Auction.cancel({
      opportunityId: $scope.opportunity._id,
      action: 'cancel',
      api_token: $rootScope.token.api_token
    }, {}, function(content) {
      return $location.path("dashboard");
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  $scope.endOpportunity = function() {
    if (!confirm("Are you sure to end your opportunity?")) {
      return;
    }
    return Auction.cancel({
      opportunityId: $scope.opportunity._id,
      action: 'award',
      api_token: $rootScope.token.api_token
    }, {}, function(content) {
      return $location.path("dashboard");
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  $scope.selectWinner = function(bid) {
    if (!confirm("Are you sure to accept this bid?")) {
      return;
    }
    return Auction.select_winner({
      opportunityId: $scope.opportunity._id,
      action: 'select_winner',
      bid_id: bid._id,
      api_token: $rootScope.token.api_token
    }, {}, function(content) {
      return reloadOpportunity();
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  $scope.hideAlert = function() {
    return $scope.errors = null;
  };
  $scope.addComment = function() {
    $scope.hideAlert();
    return Comment.save({
      api_token: $rootScope.token.api_token,
      opportunityId: $scope.opportunity._id,
      comment: $scope.comment
    }, function(content) {
      $scope.hideAlert();
      $scope.opportunity.comments.push(content);
      return $scope.comment.body = "";
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  return $scope.cancelBid = function(bid) {
    if (!confirm("Are you sure to cancel your bid?")) {
      return;
    }
    return MyBid.cancel({
      bidId: bid._id,
      action: 'cancel',
      api_token: $rootScope.token.api_token
    }, function(content) {
      return reloadOpportunity();
    }, function(content) {
      return alert($rootScope.errorMessages(content.data.errors).join("\n"));
    });
  };
};

DashboardCtrl = function($scope, $rootScope, $location, Company, Event, Filter, Tag, Bid, Favorite, Opportunity, $filter, $q) {
  var getRegionFilterOptions, setRegionFilter, updatePreviousEvents;
  $rootScope.displayTermsAndConditionsForm();
  $scope.$location = $location;
  $scope.filters = Filter.query({
    api_token: $rootScope.token.api_token
  });
  $scope.query = $location.search().q;
  $scope.filter = null;
  $scope.opportunity = null;
  $scope.events = [];
  $scope.regionFilterOptions = $rootScope.allRegions;
  $scope.filterRegions = $rootScope.filterRegionsOnHome;
  $scope.loadMoreEvents = function() {
    var queryOptions;
    if ($scope.noMoreEvents || $scope.loading) {
      return;
    }
    $scope.loading = true;
    queryOptions = angular.copy($location.search());
    queryOptions.api_token = $rootScope.token.api_token;
    queryOptions.regions = $scope.filterRegions;
    queryOptions.page = $scope.currentPage;
    return Event.query(queryOptions, function(data) {
      if (data.length === 0) {
        $scope.noMoreEvents = true;
      } else {
        angular.forEach(data.events, function(event) {
          return $scope.events.push(event);
        });
        $scope.currentPage += 1;
        $scope.available_quote_request_count = data.meta.available_quote_request_count;
      }
      return $scope.loading = false;
    }, function() {
      return $scope.loading = false;
    });
  };
  $scope.refreshEvents = function(callback) {
    $scope.events = [];
    $scope.currentPage = 1;
    $scope.noMoreEvents = false;
    $scope.loadMoreEvents();
    if (callback) {
      return callback();
    }
  };
  updatePreviousEvents = function(event) {
    var opportunity;
    opportunity = event.eventable;
    return _.each($scope.events, function(prevEvent) {
      var prevOpportunity;
      prevOpportunity = prevEvent.eventable;
      if (prevOpportunity._id === opportunity._id) {
        prevOpportunity.canceled = opportunity.canceled;
        prevOpportunity.bidable = opportunity.bidable;
        return prevOpportunity.status = opportunity.status;
      }
    });
  };
  $scope.refreshEvents(function() {
    if ($rootScope.channel) {
      return $rootScope.channel.bind('event_created', function(event) {
        if ($rootScope.company.canSeeEvent(event) && $scope.matchFilters(event)) {
          $scope.events.unshift(event);
          updatePreviousEvents(event);
          return $scope.$apply();
        }
      });
    }
  });
  $scope.isPublicEvent = function(event) {
    return event.action.type !== 'bid_negotiation';
  };
  $scope.matchFilters = function(event) {
    return $scope.filterEventType(event) && $scope.filterRegion(event) && $scope.filterOpportunityType(event) && $scope.filterFullText(event) && $scope.filterCompany(event);
  };
  $scope.filterEventType = function(event) {
    var event_type;
    event_type = $location.search().event_type;
    if (!event_type) {
      return true;
    }
    return event.action.type === event_type;
  };
  $scope.filterRegion = function(event) {
    var region;
    region = $location.search().region;
    if (!region) {
      return true;
    }
    return __indexOf.call(event.regions, region) >= 0;
  };
  $scope.filterOpportunityType = function(event) {
    var opportunity_type;
    opportunity_type = $location.search().opportunity_type;
    if (!opportunity_type) {
      return true;
    }
    return event.eventable.type === opportunity_type;
  };
  $scope.filterFullText = function(event) {
    var eventable, query, reg, text;
    query = $location.search().q;
    if (!query) {
      return true;
    }
    eventable = event.eventable;
    if (query.indexOf("#") === 0) {
      return ("#" + eventable.reference_number) === query;
    } else {
      reg = new RegExp(query);
      text = (eventable.name + ' ' + eventable.description).toLowerCase();
      return reg.test(text);
    }
  };
  $scope.filterCompany = function(event) {
    var actor_id;
    actor_id = $location.search().company_id;
    if (!actor_id) {
      return true;
    }
    return event.actor._id === actor_id;
  };
  setRegionFilter = function() {
    var regions;
    regions = angular.copy($scope.filterRegions);
    if ($scope.regionFilter) {
      regions.push($scope.regionFilter);
      return $scope.filterRegions = regions;
    }
  };
  getRegionFilterOptions = function() {
    return _.difference($rootScope.allRegions, $scope.filterRegions);
  };
  $scope.$watch("filterRegions", function() {
    $rootScope.filterRegionsOnHome = angular.copy($scope.filterRegions);
    $scope.regionFilterOptions = getRegionFilterOptions();
    return $scope.refreshEvents();
  });
  $scope.$watch("company.vehicle_types", function() {
    return $scope.refreshEvents();
  });
  $scope.regionFilter = $location.search().region;
  $scope.$watch("regionFilter", setRegionFilter);
  $scope.setOpportunityTypeFilter = function(opportunity_type) {
    if ($location.search().opportunity_type === opportunity_type) {
      $location.search('opportunity_type', null);
    } else {
      $location.search('opportunity_type', opportunity_type);
    }
    return $scope.refreshEvents();
  };
  $scope.setEventType = function(eventType) {
    if ($location.search().event_type === eventType) {
      $location.search('event_type', null);
    } else {
      $location.search('event_type', eventType);
    }
    return $scope.refreshEvents();
  };
  $scope.eventTypeLabel = function(eventType) {
    if (eventType === "opportunity_created") {
      return "Created";
    } else if (eventType === "bid_created") {
      return "New Bid";
    } else if (eventType === "opportunity_bidding_won") {
      return "Bidding Won";
    } else if (eventType === "opportunity_canceled") {
      return "Canceled";
    } else {
      return "Unknown";
    }
  };
  $scope.actionDescription = function(action) {
    switch (action.type) {
      case "opportunity_canceled":
        return "awarded";
      case "bid_created":
        return "received bid " + ($filter('soCurrency')(action.details.amount));
      case "bid_canceled":
        return "received bid cancelation " + ($filter('soCurrency')(action.details.amount));
      default:
        return "" + (action.type.split('_').pop());
    }
  };
  $scope.toggleEvent = function(event) {
    event.selected = !event.selected;
    if (event.selected && event.eventable._id) {
      return Event.get({
        api_token: $rootScope.token.api_token,
        eventId: event._id
      }, function(data) {
        event.eventable = data.eventable;
        return setTimeout((function() {
          return $(".relative_time").timeago();
        }), 1);
      });
    }
  };
  $scope.fullTextSearch = function(event) {
    var query;
    if ($scope.query && $scope.query !== "") {
      query = $scope.query;
    } else {
      query = null;
    }
    $location.search('q', query);
    return $scope.refreshEvents();
  };
  $scope.refNumSearch = function(ref_num) {
    $scope.query = '#' + ref_num;
    return $scope.fullTextSearch();
  };
  $scope.hasAnyFilter = function() {
    if ($scope.filterRegions.length > 0) {
      return true;
    }
    return !_.isEmpty($location.search());
  };
  $scope.filterValue = $rootScope.isMobile ? '' : null;
  $scope.clearFilters = function() {
    $scope.query = "";
    $scope.regionFilter = $scope.filterValue;
    $scope.filterRegions = [];
    $location.search({});
    return $scope.refreshEvents();
  };
  $scope.clearRegionFilter = function() {
    return $rootScope.company.regions = [];
  };
  $scope.removeRegionFilter = function(region) {
    return $scope.filterRegions = _.reject($scope.filterRegions, function(item) {
      return region === item;
    });
  };
  return $rootScope.$watch(function() {
    return $location.absUrl();
  }, function(newPath, oldPath) {
    return $scope.query = $location.search().q;
  });
};

SettingCtrl = function($scope, $rootScope, $location, Token, Company, User, Product, GatewaySubscription, $config) {
  var loadProductInfo, paymentMethodOptions, successUpdate, token, updateAdditionalPrice, updateCompanyAndCompanyProfile, updateSelectedNotifications, updateSelectedRegions, vehicleTypeOptions;
  token = $rootScope.token;
  $scope.userProfile = angular.copy($rootScope.user);
  $scope.companyProfile = angular.copy($rootScope.company);
  $scope.suboutBasicSubscriptionUrl = $config.suboutBasicSubscriptionUrl();
  $scope.suboutProSubscriptionUrl = $config.suboutProSubscriptionUrl();
  $scope.subscription = null;
  $scope.additional_price = 0;
  if (!$rootScope.selectedTab) {
    $rootScope.selectedTab = "user-login";
  }
  updateAdditionalPrice = function() {
    if ($scope.companyProfile.vehicles.length > 2) {
      return $scope.additional_price = ($scope.companyProfile.vehicles.length - 2) * $scope.subout_bus_price * 100;
    } else {
      return $scope.additional_price = 0;
    }
  };
  updateSelectedRegions = function() {
    var region, _base, _i, _len, _ref, _results;
    (_base = $scope.companyProfile).regions || (_base.regions = []);
    $scope.companyProfile.allRegions = {};
    _ref = $rootScope.allRegions;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      region = _ref[_i];
      _results.push($scope.companyProfile.allRegions[region] = __indexOf.call($scope.companyProfile.regions, region) >= 0);
    }
    return _results;
  };
  updateSelectedRegions();
  updateSelectedNotifications = function() {
    var t, _i, _len, _ref, _results;
    $scope.daily_reminder = $rootScope.company.hasNotificationItem("daily-reminder");
    _ref = $rootScope.NOTIFICATION_TYPES;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      if ($rootScope.company.hasNotificationItem(t.code)) {
        _results.push(t.enabled = true);
      } else {
        _results.push(t.enabled = null);
      }
    }
    return _results;
  };
  updateSelectedNotifications();
  $scope.setReminderNotification = function() {
    var t, _i, _len, _ref, _results;
    $scope.daily_reminder = !$scope.daily_reminder;
    _ref = $rootScope.NOTIFICATION_TYPES;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      _results.push(t.enabled = null);
    }
    return _results;
  };
  $scope.setNotification = function(n) {
    var t, _i, _len, _ref, _results;
    n.enabled = !n.enabled;
    $scope.daily_reminder = null;
    _ref = $rootScope.NOTIFICATION_TYPES;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      if (t.code === n.code) {
        _results.push(t.enabled = n.enabled);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };
  updateCompanyAndCompanyProfile = function(company) {
    $rootScope.company = company;
    $scope.companyProfile = angular.copy(company);
    return updateSelectedRegions();
  };
  loadProductInfo = function() {
    Product.get({
      productHandle: 'subout-basic-service',
      api_token: $rootScope.token.api_token
    }, function(data) {
      return $scope.subout_basic_product = data;
    });
    Product.get({
      productHandle: 'subout-pro-service',
      api_token: $rootScope.token.api_token
    }, function(data) {
      $scope.subout_pro_product = data;
      $scope.subout_bus_price = data.components[0].unit_price;
      console.log($scope.subout_bus_price);
      return updateAdditionalPrice();
    });
    if ($rootScope.company.subscription_id) {
      return GatewaySubscription.get({
        subscriptionId: $rootScope.company.subscription_id,
        api_token: $rootScope.token.api_token
      }, function(subscription) {
        $rootScope.subscription = subscription;
        return $scope.subscription = subscription;
      }, function(error) {
        return $rootScope.subscription = null;
      });
    } else {
      return $rootScope.subscription = null;
    }
  };
  loadProductInfo();
  $rootScope.setupFileUploader();
  successUpdate = function() {
    return $rootScope.closeModal();
  };
  $scope.saveUserProfile = function() {
    $scope.userProfileError = "";
    if ($scope.userProfile.password === $scope.userProfile.password_confirmation) {
      return User.update({
        userId: $rootScope.user._id,
        user: $scope.userProfile,
        api_token: $rootScope.token.api_token
      }, function(user) {
        $scope.userProfile.password = '';
        $scope.userProfile.current_password = '';
        $rootScope.user = $scope.userProfile;
        return successUpdate();
      }, function(error) {
        return $scope.userProfileError = "Invalid password or email!";
      });
    } else {
      return $scope.userProfileError = "The new password and password confirmation are not identical.";
    }
  };
  $scope.saveFavoritedRegions = function() {
    var finalRegions, isEnabled, region, _ref;
    finalRegions = [];
    _ref = $scope.companyProfile.allRegions;
    for (region in _ref) {
      isEnabled = _ref[region];
      if (!!isEnabled) {
        finalRegions.push(region);
      }
    }
    $scope.companyProfile.regions = finalRegions;
    return Company.update_regions({
      companyId: $rootScope.company._id,
      company: $scope.companyProfile,
      api_token: $rootScope.token.api_token,
      action: "update_regions"
    }, function(company) {
      updateCompanyAndCompanyProfile(company);
      return successUpdate();
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
  $scope.saveCompanyProfile = function() {
    var finalNotifications, t, _i, _len, _ref;
    $scope.companyProfileError = "";
    $scope.companyProfile.logo_id = $("#company_logo_id").val();
    finalNotifications = [];
    if ($scope.daily_reminder) {
      finalNotifications.push("daily-reminder");
    }
    _ref = $rootScope.NOTIFICATION_TYPES;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      if (t.enabled) {
        finalNotifications.push(t.code);
      }
    }
    $scope.companyProfile.notification_items = finalNotifications;
    return Company.update({
      companyId: $rootScope.company._id,
      company: $scope.companyProfile,
      api_token: $rootScope.token.api_token
    }, function(company) {
      updateCompanyAndCompanyProfile(company);
      return successUpdate();
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
  $scope.updateProduct = function(product) {
    if (!confirm("Are you sure?")) {
      return;
    }
    return Company.update_product({
      companyId: $rootScope.company._id,
      product: product,
      api_token: $rootScope.token.api_token,
      action: "update_product"
    }, function(company) {
      updateCompanyAndCompanyProfile(company);
      return successUpdate();
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
  vehicleTypeOptions = function() {
    return _.difference($scope.VEHICLE_TYPES, $scope.companyProfile.vehicle_types);
  };
  $scope.vehicleTypeOptions = vehicleTypeOptions();
  $scope.addVehicleType = function() {
    var _base;
    (_base = $scope.companyProfile).vehicle_types || (_base.vehicle_types = []);
    $scope.companyProfile.vehicle_types.push($scope.newVehicleType);
    $scope.newVehicleType = "";
    return $scope.vehicleTypeOptions = vehicleTypeOptions();
  };
  $scope.saveVehicles = function() {
    if (!confirm("Are you sure?")) {
      return false;
    }
    return Company.update_vehicles({
      companyId: $rootScope.company._id,
      company: $scope.companyProfile,
      api_token: $rootScope.token.api_token,
      action: "update_vehicles"
    }, function(company) {
      updateCompanyAndCompanyProfile(company);
      return successUpdate();
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
  $scope.addVehicle = function(vehicle) {
    $scope.companyProfile.vehicles.push(vehicle);
    return updateAdditionalPrice();
  };
  $scope.removeVehicle = function(vehicle) {
    $scope.companyProfile.vehicles = _.reject($scope.companyProfile.vehicles, function(item) {
      return vehicle === item;
    });
    return updateAdditionalPrice();
  };
  $scope.removeVehicleType = function(vehicle_type) {
    $scope.companyProfile.vehicle_types = _.reject($scope.companyProfile.vehicle_types, function(item) {
      return vehicle_type === item;
    });
    return $scope.vehicleTypeOptions = vehicleTypeOptions();
  };
  paymentMethodOptions = function() {
    return _.difference($scope.PAYMENT_METHODS, $scope.companyProfile.payment_methods);
  };
  $scope.paymentMethodOptions = paymentMethodOptions();
  $scope.addPaymentMethod = function() {
    var _base;
    (_base = $scope.companyProfile).payment_methods || (_base.payment_methods = []);
    $scope.companyProfile.payment_methods.push($scope.newPaymentMethod);
    $scope.newPaymentMethod = "";
    return $scope.paymentMethodOptions = paymentMethodOptions();
  };
  return $scope.removePaymentMethod = function(payment_method) {
    $scope.companyProfile.payment_methods = _.reject($scope.companyProfile.payment_methods, function(item) {
      return payment_method === item;
    });
    return $scope.paymentMethodOptions = paymentMethodOptions();
  };
};

SignInCtrl = function($scope, $rootScope, $location, Token, Company, User, AuthToken, Authorize, Setting, $sce) {
  $.removeCookie(AuthToken);
  Setting.get({
    key: "marketing_message"
  }, function(message) {
    message.value = $sce.trustAsHtml(message.value);
    return $scope.marketing_message = message;
  });
  return $scope.signIn = function() {
    return Token.save({
      email: $scope.email,
      password: $scope.password
    }, function(token) {
      var promise;
      if (token.authorized) {
        $.cookie("signed_in_time", (new Date()).getTime());
        promise = Authorize.authenticate(token);
        return promise.then(function() {
          if ($rootScope.redirectToPath) {
            return $location.path($rootScope.redirectToPath);
          } else {
            return $location.path("");
          }
        });
      } else {
        return $scope.message = token.message;
      }
    });
  };
};

NewPasswordCtrl = function($scope, $rootScope, $location, $timeout, Password, AuthToken) {
  $.removeCookie(AuthToken);
  $scope.hideAlert = function() {
    $scope.notice = null;
    return $scope.errors = null;
  };
  return $scope.requestResetPassword = function() {
    $scope.hideAlert();
    return Password.save({
      user: $scope.user
    }, function() {
      $scope.user.email = null;
      $scope.notice = "You will receive an email with instructions" + " about how to reset your password in a few minutes.";
      return $timeout(function() {
        return $scope.notice = null;
      }, 2000);
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

SignUpCtrl = function($scope, $rootScope, $routeParams, $location, Token, Company, FavoriteInvitation, GatewaySubscription, AuthToken, Authorize) {
  $.removeCookie(AuthToken);
  $scope.company = {};
  $scope.user = {};
  $rootScope.setupFileUploader();
  if ($routeParams.invitation_id) {
    FavoriteInvitation.get({
      invitationId: $routeParams.invitation_id
    }, function(invitation) {
      $scope.user.email = invitation.supplier_email;
      $scope.company.email = invitation.supplier_email;
      $scope.company.name = invitation.supplier_name;
      return $scope.company.created_from_invitation_id = invitation._id;
    }, function() {
      return $location.path("/sign_in").search({});
    });
  } else if ($routeParams.subscription_id) {
    GatewaySubscription.get({
      subscriptionId: $routeParams.subscription_id
    }, function(subscription) {
      $scope.user.email = subscription.email;
      $scope.company.email = subscription.email;
      $scope.company.name = subscription.organization;
      return $scope.company.chargify_id = subscription.subscription_id;
    }, function() {
      return $location.path("/sign_in").search({});
    });
  } else if ($routeParams.chargify_id) {
    $scope.company.chargify_id = $routeParams.chargify_id;
  } else {
    $location.path("/sign_in");
  }
  $scope.hideAlert = function() {
    return $scope.errors = null;
  };
  return $scope.signUp = function() {
    $scope.company.users_attributes = {
      "0": $scope.user
    };
    $scope.company.logo_id = $("#company_logo_id").val();
    return Company.save({
      company: $scope.company
    }, function() {
      $scope.errors = null;
      return Token.save({
        email: $scope.user.email,
        password: $scope.user.password
      }, function(token) {
        return Authorize.authenticate(token).then(function() {
          return $location.path("/dashboard").search({});
        });
      });
    }, function(content) {
      return showErrors(content.data.errors);
    });
  };
};

TermsAndConditionsCtrl = function($rootScope, $location, $routeParams, $scope, $timeout, Company) {
  return $scope.accept = function() {
    return Company.update_agreement({
      companyId: $rootScope.company._id,
      api_token: $rootScope.token.api_token,
      action: "update_agreement"
    }, function(company) {
      $rootScope.company.tac_agreement = true;
      return $rootScope.closeModal();
    }, function(error) {
      return $rootScope.closeModal();
    });
  };
};

CompanyDetailCtrl = function($rootScope, $location, $routeParams, $scope, $timeout, Favorite, Company, Rating) {
  var company_id;
  $scope.validateRate = function(value) {
    return value !== 0;
  };
  $scope.rating = {
    communication: "",
    ease_of_payment: "",
    editable: false,
    like_again: "",
    over_all_experience: "",
    punctuality: ""
  };
  company_id = $routeParams.company_id;
  if (!company_id) {
    $location.path("/dashboard");
  }
  $scope.detailed_company = Company.get({
    api_token: $rootScope.token.api_token,
    companyId: company_id
  }, function(company) {
    return $scope.rating = company.ratingFromCompany($rootScope.company);
  }, function(error) {
    return $location.path("/dashboard");
  });
  return $scope.updateRating = function() {
    return Rating.update({
      ratingId: $scope.rating._id,
      rating: $scope.rating,
      api_token: $rootScope.token.api_token
    }, function(data) {
      return $location.search({
        reload: new Date().getTime()
      });
    }, function(content) {
      return console.log("rating update failed");
    });
  };
};

CompanyProfileCtrl = function($rootScope, $location, $routeParams, $scope, $timeout, Favorite, Company, Rating) {
  return true;
};

HelpCtrl = function() {
  return true;
};

OfferFormCtrl = function($scope, $rootScope, Offer, Opportunity) {
  $scope.vendor = {};
  $scope.offer = {
    amount: $scope.opportunity.reserve_amount,
    vehicle_type: $scope.opportunity.vehicle_type
  };
  $scope.hideAlert = function() {
    return $scope.errors = null;
  };
  $scope.$on('modalOpened', function() {
    return $scope.hideAlert();
  });
  return $scope.save = function() {
    return Offer.save({
      offer: $scope.offer,
      vendor: $scope.vendor,
      api_token: $rootScope.token.api_token,
      opportunityId: $rootScope.opportunity._id
    }, function(data) {
      return jQuery("#modal").modal("hide");
    }, function(content) {
      return $scope.errors = $scope.showErrors(content.data.errors);
    });
  };
};

(function() {
  var applyScopeHelpers;
  applyScopeHelpers = function($scope, $rootScope, $location, $routeParams, $timeout, Password, AuthToken) {
    $scope.hideAlert = function() {
      $scope.notice = null;
      return $scope.errors = null;
    };
    return $scope.resetPassword = function() {
      $scope.hideAlert();
      $scope.user.reset_password_token = $routeParams.reset_password_token;
      return Password.update({
        user: $scope.user
      }, function() {
        $scope.notice = "Your password is reset successfully";
        $scope.password = null;
        $scope.password_confirmation = null;
        return $timeout(function() {
          $scope.notice = null;
          return $location.path("sign_in").search({});
        }, 2000);
      }, function(content) {
        return $scope.errors = $rootScope.errorMessages(content.data.errors);
      });
    };
  };
  return subout.controller('EditPasswordCtrl', function($scope, $rootScope, $routeParams, $location, $timeout, Password, AuthToken) {
    $.removeCookie(AuthToken);
    return applyScopeHelpers($scope, $rootScope, $location, $routeParams, $timeout, Password, AuthToken);
  });
})();

subout.directive('multiple', function() {
  return {
    scope: false,
    link: function(scope, element, attrs) {
      element.multiselect({
        enableFiltering: true,
        selectAllText: "All",
        buttonText: function(options, select) {
          var selected;
          if (options.length === 0) {
            return "" + attrs.placeholder + " <b class='caret'></b>";
          } else if (options.length > 3) {
            return options.length + ' selected <b class="caret"></b>';
          } else {
            selected = "";
            options.each(function() {
              return selected += $(this).text() + ", ";
            });
            return selected.substr(0, selected.length - 2) + ' <b class="caret"></b>';
          }
        }
      });
      scope.$watch(function() {
        return element[0].length;
      }, function() {
        return element.multiselect('rebuild');
      });
      scope.$watch(attrs.ngModel, function() {
        return element.multiselect('refresh');
      });
      if (scope.$last) {
        return element.multiselect('refresh');
      }
    }
  };
});

subout.directive("relativeTime", function() {
  return {
    link: function(scope, element, iAttrs) {
      var variable;
      variable = iAttrs["relativeTime"];
      return scope.$watch(variable, function() {
        if ($(element).attr('title') !== "") {
          return $(element).timeago();
        }
      });
    }
  };
});

subout.directive("whenScrolled", function() {
  return function(scope, element, attr) {
    var fn;
    fn = function() {
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 50) {
        return scope.$apply(attr.whenScrolled);
      }
    };
    scope.$on('$routeChangeStart', function() {
      fn = function() {};
      return null;
    });
    return $(window).scroll(function() {
      return fn();
    });
  };
});

subout.directive("salesInfoMessages", function($rootScope) {
  return {
    link: function(scope, iElement, iAttrs) {
      var variable;
      variable = iAttrs["salesInfoMessages"];
      return scope.$watch(variable, function() {
        var messages;
        messages = scope[variable];
        if (messages && messages.length > 0) {
          $rootScope.salesInfoMessageIdx = ($rootScope.salesInfoMessageIdx || 0) % messages.length;
          iElement.text(messages[$rootScope.salesInfoMessageIdx]);
          return $rootScope.salesInfoMessageIdx += 1;
        }
      });
    }
  };
});
var Evaluators, evaluation, module;

module = angular.module("suboutFilters", []);

module.filter("timestamp", function() {});

module.filter("timestamp", function() {
  return function(input) {
    return new Date(input).getTime();
  };
});

module.filter("stringToDate", function() {
  return function(input) {
    if (!input) {
      return "";
    }
    return Date.parse(input);
  };
});

module.filter("soShortDate", function($filter) {
  return function(input) {
    if (!input) {
      return "";
    }
    return $filter('date')(input, 'MM/dd/yyyy');
  };
});

module.filter("soCurrency", function($filter) {
  return function(input) {
    return $filter('currency')(input).replace(/\.\d\d/, "");
  };
});

module.filter("websiteUrl", function() {
  return function(url) {
    if (/^https?/i.test(url)) {
      return url;
    } else {
      return "http://" + url;
    }
  };
});

module.filter("excerpt", function() {
  return function(input, limit) {
    if (!input) {
      return "";
    }
    if (input.length > limit) {
      return input.substring(0, limit) + "...";
    } else {
      return input;
    }
  };
});

evaluation = function(input, evaluation) {
  var evaluator;
  evaluator = Evaluators[evaluation.type];
  if ($.isFunction(evaluator)) {
    return evaluator(input, evaluation);
  } else {
    alert("Evaluator doesn't exist.");
    return true;
  }
};

Evaluators = {};

Evaluators.range = function(input, evaluation) {
  var property;
  property = input[evaluation.property];
  if (property) {
    return (property >= evaluation.params.min) && (property <= evaluation.params.max);
  } else {
    return true;
  }
};

Evaluators.today = function(input, evaluation) {
  var current_day, current_time, property, property_day;
  property = input[evaluation.property];
  if (property) {
    current_time = new Date().getTime();
    current_day = parseInt(current_time / (3600 * 24 * 1000));
    property_day = parseInt(property / (3600 * 24 * 1000));
    return current_day === property_day;
  } else {
    return true;
  }
};

Evaluators.compare = function(input, evaluation) {
  var compare, property;
  property = input[evaluation.property];
  if (property) {
    compare = "'" + property + "'      " + evaluation.params.operator + "      '" + evaluation.params.value + "'";
    return eval_(compare);
  } else {
    return true;
  }
};

Evaluators.like = function(input, evaluation) {
  var property, reg;
  property = input[evaluation.property];
  if (property) {
    reg = new RegExp(evaluation.params.value.toLowerCase());
    return reg.test(property.toLowerCase());
  } else {
    return true;
  }
};
var api_path, suboutSvcs,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

api_path = "/api/v1";

suboutSvcs = angular.module("suboutServices", ["ngResource", "angular-abortable-requests"]);

suboutSvcs.factory("Setting", function($resource) {
  return $resource("" + api_path + "/settings/:key", {
    key: '@key'
  });
});

suboutSvcs.factory("soValidateEmail", function() {
  return function(email) {
    var re;
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  };
});

suboutSvcs.factory("Auction", function($resource, $rootScope) {
  return $resource("" + api_path + "/auctions/:opportunityId/:action", {
    opportunityId: '@opportunityId',
    action: '@action',
    api_token: '@api_token'
  }, {
    select_winner: {
      method: "PUT"
    },
    cancel: {
      method: "PUT"
    },
    update: {
      method: "PUT"
    },
    paginate: {
      method: "GET"
    },
    start_negotiation: {
      method: "PUT",
      params: {
        action: "create_negotiation"
      }
    },
    decline_negotiation: {
      method: "PUT",
      params: {
        action: "decline_negotiation"
      }
    }
  });
});

suboutSvcs.factory("Rating", function($resource) {
  var r1, r2;
  r2 = $resource("" + api_path + "/ratings/search/:rateeId", {
    rateeId: '@rateeId'
  });
  r1 = $resource("" + api_path + "/ratings/:ratingId", {
    ratingId: '@ratingId'
  }, {
    update: {
      method: "PUT"
    }
  });
  return r1;
});

suboutSvcs.factory("Opportunity", function($resource) {
  var Opportunity;
  Opportunity = $resource("" + api_path + "/opportunities/:opportunityId", {}, {
    paginate: {
      method: "GET"
    }
  });
  Opportunity.defaultBidAmountFor = function(opportunity) {
    var amount;
    if (opportunity.forward_auction && opportunity.highest_bid_amount) {
      amount = parseInt(opportunity.highest_bid_amount);
      return amount;
    }
    if (!opportunity.forward_auction && opportunity.lowest_bid_amount) {
      amount = parseInt(opportunity.lowest_bid_amount);
      return amount;
    }
    if (opportunity.reserve_amount) {
      return opportunity.reserve_amount;
    }
    null;
    if (this.state_by_state_subscriber) {
      return this.regions.join(', ');
    } else {
      return "Nationwide";
    }
  };
  Opportunity.prototype.isSuboutChoice = function(bid) {
    var amount, bid_amount, opportunity;
    if (bid.bidder.recommend === false) {
      return false;
    }
    opportunity = this;
    if (opportunity.forward_auction && opportunity.highest_bid_amount) {
      amount = parseInt(opportunity.highest_bid_amount);
      bid_amount = parseInt(bid.amount);
      return amount * 0.9 < bid_amount;
    }
    if (!opportunity.forward_auction && opportunity.lowest_bid_amount) {
      amount = parseInt(opportunity.lowest_bid_amount);
      bid_amount = parseInt(bid.amount);
      return amount * 1.1 > bid_amount;
    }
    return false;
  };
  return Opportunity;
});

suboutSvcs.factory("QuoteRequest", function($resource) {
  var QuoteRequest;
  QuoteRequest = $resource("" + api_path + "/quote_requests/:quoteRequestId", {}, {
    paginate: {
      method: "GET"
    }
  });
  return QuoteRequest;
});

suboutSvcs.factory("MyBid", function($resource, $rootScope) {
  return $resource("" + api_path + "/bids/:bidId/:action", {
    bidId: '@bidId',
    action: '@action',
    api_token: $rootScope.token.api_token
  }, {
    paginate: {
      method: "GET"
    },
    cancel: {
      method: "PUT",
      params: {
        action: "cancel"
      }
    },
    accept_negotiation: {
      method: "PUT",
      params: {
        action: "accept_negotiation"
      }
    },
    decline_negotiation: {
      method: "PUT",
      params: {
        action: "decline_negotiation"
      }
    },
    counter_negotiation: {
      method: "PUT",
      params: {
        action: "counter_negotiation"
      }
    }
  });
});

suboutSvcs.factory("Region", function($resource) {
  return $resource("" + api_path + "/regions", {}, {});
});

suboutSvcs.factory("Product", function($resource) {
  return $resource("" + api_path + "/products/:productHandle", {}, {});
});

suboutSvcs.factory("Bid", function($resource) {
  var Bid;
  return Bid = $resource("" + api_path + "/opportunities/:opportunityId/bids", {
    opportunityId: "@opportunityId"
  }, {});
});

suboutSvcs.factory("Quote", function($resource) {
  return $resource("" + api_path + "/quote_requests/:quoteRequestId/quotes", {
    quoteRequestId: "@quoteRequestId"
  }, {});
});

suboutSvcs.factory("Offer", function($resource) {
  return $resource("" + api_path + "/opportunities/:opportunityId/offers", {
    opportunityId: "@opportunityId"
  }, {});
});

suboutSvcs.factory("Comment", function($resource) {
  var Comment;
  Comment = $resource("" + api_path + "/opportunities/:opportunityId/comments", {
    opportunityId: "@opportunityId"
  }, {});
  return Comment;
});

suboutSvcs.factory("Event", function($resource, RequestFactory) {
  var Event;
  Event = $resource("" + api_path + "/events/:eventId", {}, {
    query: {
      isArray: false,
      method: 'GET'
    }
  });
  Event.prototype.isBidableBy = function(company) {
    return this.eventable.bidable && this.eventable.buyer_id !== company._id;
  };
  return Event;
});

suboutSvcs.factory("Company", function($resource, $rootScope) {
  var Company;
  Company = $resource("" + api_path + "/companies/:companyId/:action", {
    companyId: '@companyId',
    action: '@action'
  }, {
    update: {
      method: "PUT"
    },
    search: {
      method: "GET",
      action: "search",
      isArray: true
    },
    update_agreement: {
      method: "PUT",
      action: "update_agreement"
    },
    update_regions: {
      method: "PUT",
      action: "update_regions"
    },
    update_notifications: {
      method: "PUT",
      action: "update_notifications"
    },
    update_vehicles: {
      method: "PUT",
      action: "update_vehicles"
    },
    update_product: {
      method: "PUT",
      action: "update_product"
    }
  });
  Company.prototype.regionNames = function() {
    if (this.state_by_state_subscriber) {
      return this.regions.join(', ');
    } else {
      return "Nationwide";
    }
  };
  Company.prototype.ratingFromCompany = function(company) {
    var r, _i, _len, _ref;
    _ref = this.ratings_taken;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      r = _ref[_i];
      if (r.rater._id === company._id) {
        return r;
      }
    }
  };
  Company.prototype.canBeAddedAsFavorite = function(company) {
    var _ref;
    if (this._id === company._id) {
      return false;
    }
    if (!this.favoriting_buyer_ids) {
      return false;
    }
    return !(_ref = company._id, __indexOf.call(this.favoriting_buyer_ids, _ref) >= 0);
  };
  Company.prototype.canSeeEvent = function(event) {
    var _ref, _ref1;
    if (this.vehicle_types) {
      if (_ref = event.vehicle_type, __indexOf.call(this.vehicle_types, _ref) < 0) {
        return false;
      }
    }
    if (!event.eventable.for_favorites_only) {
      return true;
    }
    if (event.eventable.buyer_id === this._id) {
      return true;
    }
    return _ref1 = event.eventable.buyer_id, __indexOf.call(this.favoriting_buyer_ids, _ref1) >= 0;
  };
  Company.prototype.canAddFreeBuses = function() {
    return this.subscription_plan === "subout-pro-service" && 2 - this.vehicles.length > 0;
  };
  Company.prototype.isBasicUser = function() {
    return this.subscription_plan === "subout-basic-service";
  };
  Company.prototype.isProUser = function() {
    return this.subscription_plan === "subout-pro-service";
  };
  Company.prototype.isFreeUser = function() {
    return this.subscription_plan === "free";
  };
  Company.prototype.canBid = function(opportunity) {
    if (!opportunity.buyer) {
      return false;
    }
    if (opportunity.buyer_id !== this._id && opportunity.status === 'In progress') {
      return true;
    }
  };
  Company.prototype.isMyOpportunity = function(opportunity) {
    if (!opportunity.buyer) {
      return false;
    }
    return opportunity.buyer_id === this._id;
  };
  Company.prototype.isMyBid = function(bid) {
    if (!bid.bidder) {
      return false;
    }
    return bid.bidder_id === this._id;
  };
  Company.prototype.isRelated = function(opportunity, bid) {
    return this.isMyOpportunity(opportunity) || this.isMyBid(bid);
  };
  Company.prototype.canCancelOrEdit = function(opportunity) {
    if (opportunity.type !== 'Emergency') {
      if (!opportunity.status) {
        return false;
      }
      if (!opportunity.buyer) {
        return false;
      }
      if (this._id !== opportunity.buyer._id) {
        return false;
      }
      return opportunity.status === 'In progress';
    } else {
      if (!opportunity.status) {
        return false;
      }
      if (!opportunity.buyer) {
        return false;
      }
      if (this._id !== opportunity.buyer._id) {
        return false;
      }
      return opportunity.status === 'In progress';
    }
  };
  Company.prototype.removeFavoriteBuyerId = function(buyerId) {
    return this.favoriting_buyer_ids = _.without(this.favoriting_buyer_ids, buyerId);
  };
  Company.prototype.hasNotificationItem = function(code) {
    return _.indexOf(this.notification_items, code) !== -1;
  };
  Company.prototype.addNotificationItem = function(code) {
    this.notification_items.push(code);
    this.notifcation_items = _.uniq(this.notifiication_items);
    return this.notification_items;
  };
  Company.prototype.removeNotificationItem = function(code) {
    this.notifcation_items = _.without(this.notifiication_items, code);
    return this.notification_items;
  };
  Company.prototype.addFavoriteBuyerId = function(buyerId) {
    return this.favoriting_buyer_ids.push(buyerId);
  };
  return Company;
});

suboutSvcs.factory("Token", function($resource) {
  return $resource("" + api_path + "/tokens", {}, {});
});

suboutSvcs.factory("Password", function($resource) {
  return $resource("" + api_path + "/passwords", {}, {
    update: {
      method: "PUT",
      params: {}
    }
  });
});

suboutSvcs.factory("User", function($resource) {
  return $resource("" + api_path + "/users/:userId.json", {
    userId: '@userId'
  }, {
    update: {
      method: "PUT"
    }
  });
});

suboutSvcs.factory("Filter", function($resource) {
  return $resource("" + api_path + "/filters.json", {}, {
    query: {
      method: "GET",
      params: {},
      isArray: true
    }
  });
});

suboutSvcs.factory("Tag", function($resource) {
  return $resource("" + api_path + "/tags.json", {}, {
    query: {
      method: "GET",
      params: {},
      isArray: true
    }
  });
});

suboutSvcs.factory("Favorite", function($resource) {
  return $resource("" + api_path + "/favorites/:favoriteId", {}, {});
});

suboutSvcs.factory("FavoriteInvitation", function($resource) {
  return $resource("" + api_path + "/favorite_invitations/:invitationId", {}, {});
});

suboutSvcs.factory("GatewaySubscription", function($resource) {
  return $resource("" + api_path + "/gateway_subscriptions/:subscriptionId", {}, {});
});

suboutSvcs.factory("FileUploaderSignature", function($resource) {
  return $resource("" + api_path + "/file_uploader_signatures/new", {}, {});
});

suboutSvcs.factory("$numberFormatter", function() {
  return {
    format: function(number, precision) {
      return _.str.numberFormat(parseFloat(number), precision);
    }
  };
});

suboutSvcs.factory("Authorize", function($rootScope, $location, AuthToken, Region, User, Company, $q) {
  return {
    token: function() {
      return this.tokenValue;
    },
    authenticate: function(token) {
      var defer;
      defer = $q.defer();
      $.cookie(AuthToken, token);
      this.tokenValue = token;
      $rootScope.token = token;
      $rootScope.pusher = new Pusher(token.pusher_key, {
        encrypted: true
      });
      $rootScope.channel = $rootScope.pusher.subscribe('global');
      $rootScope.company = Company.get({
        companyId: token.company_id,
        api_token: token.api_token
      }, function(company) {
        $rootScope.channel.bind('added_to_favorites', function(favorite) {
          if ($rootScope.company._id === favorite.supplier_id) {
            return $rootScope.company.addFavoriteBuyerId(favorite.company_id);
          }
        });
        $rootScope.channel.bind('removed_from_favorites', function(favorite) {
          if ($rootScope.company._id === favorite.supplier_id) {
            return $rootScope.company.removeFavoriteBuyerId(favorite.company_id);
          }
        });
        if (company.state_by_state_subscriber) {
          $rootScope.regions = company.regions;
        }
        $rootScope.salesInfoMessages = company.sales_info_messages;
        return $rootScope.user = User.get({
          userId: token.user_id,
          api_token: token.api_token
        }, function(company) {
          defer.resolve();
          return setTimeout(function() {
            return $rootScope.$apply();
          }, 3000);
        });
      }, function() {});
      return defer.promise;
    },
    check: function() {
      var token, _ref;
      if ((_ref = $rootScope.token) != null ? _ref.authorized : void 0) {
        return true;
      }
      token = $.cookie(AuthToken);
      if (!this.token() && token) {
        return this.authenticate(token);
      } else {
        return false;
      }
    }
  };
});

suboutSvcs.factory("$appVersioning", function() {
  return {
    _version: 0,
    _deploy: 0,
    isAppVersionUpToDate: function(version) {
      var v;
      version = parseFloat(version);
      v = this.getAppVersion();
      if (v > 0 && version !== v) {
        return false;
      }
      this.setAppVersion(version);
      return true;
    },
    isDeployTimestampUpToDate: function(deploy) {
      var d;
      deploy = parseInt(deploy);
      d = this.getDeployTimestamp();
      if (d > 0 && deploy !== d) {
        return false;
      }
      this.setDeployTimestamp(deploy);
      return true;
    },
    getAppVersion: function() {
      return this._version;
    },
    setAppVersion: function(v) {
      return this._version = v;
    },
    getDeployTimestamp: function() {
      return this._deploy;
    },
    setDeployTimestamp: function(d) {
      return this._deploy = d;
    },
    markForReload: function() {
      return this._reload = true;
    },
    isMarkedForReload: function() {
      return this._reload === true;
    }
  };
});

suboutSvcs.factory("$appBrowser", function() {
  var version;
  version = parseInt($.browser.version);
  return {
    isReallyOld: function() {
      return ($.browser.msie && version < 8) || ($.browser.mozilla && version < 2);
    },
    isOld: function() {
      return ($.browser.msie && version < 9) || ($.browser.mozilla && version < 3);
    },
    isMobile: function() {
      var android, iOS;
      android = navigator.userAgent.match(/Android/i);
      iOS = navigator.userAgent.match(/iPhone|iPad|iPod/i);
      return android || iOS;
    },
    isPhone: function() {
      var android, iOS;
      android = navigator.userAgent.match(/Android/i && navigator.userAgent.match(/Mobile/i));
      iOS = navigator.userAgent.match(/iPhone|iPod/i);
      return android || iOS;
    }
  };
});

suboutSvcs.factory("myHttpInterceptor", function($q, $appVersioning, $rootScope, $injector, $location, AuthToken) {
  return function(promise) {
    return promise.then((function(response) {
      var $http, current_time, deploy, mime, payloadData, signed_in_time, version;
      if (response.config.method === "POST") {
        $rootScope.inPosting = false;
      }
      mime = "application/json; charset=utf-8";
      if (response.headers()["content-type"] === mime) {
        payloadData = response.data ? response.data.payload : null;
        if (payloadData) {
          version = response.data.version;
          if (!$appVersioning.isAppVersionUpToDate(version)) {
            $rootScope.signOut();
            return;
          }
          deploy = response.data.deploy;
          if (!$appVersioning.isDeployTimestampUpToDate(deploy)) {
            $appVersioning.markForReload();
          }
          if (!payloadData) {
            return $q.reject(response);
          }
          $http = $injector.get('$http');
          if ($http.pendingRequests.length === 0) {
            $('.loading-animation').removeClass('loading');
            if ($.cookie("signed_in_time") && $rootScope.company && $rootScope.company.mode === "ghost") {
              signed_in_time = $.cookie("signed_in_time");
              current_time = (new Date()).getTime();
              if ((current_time - signed_in_time) / 1000 > 60 * 60) {
                $.removeCookie("signed_in_time");
                $.removeCookie(AuthToken);
                alert("Your session is expired. You should purchase one of our packages and sign up.");
                window.location.href = "http://subout.com/pricing";
              }
            }
          }
          response.data = payloadData;
        }
      }
      return response;
    }), function(response) {
      if (response.config.method === "POST") {
        $rootScope.inPosting = false;
      }
      $('.loading-animation').removeClass('loading');
      if (response.data.payload) {
        response.data = response.data.payload;
      }
      return $q.reject(response);
    });
  };
});

suboutSvcs.factory("$analytics", function($location) {
  return {
    trackPageview: function(url) {
      if (_gaq) {
        url || (url = $location.url());
        return _gaq.push(['_trackPageview', url]);
      }
    }
  };
});

suboutSvcs.factory("$config", function($location) {
  return {
    suboutBasicSubscriptionUrl: function() {
      switch ($location.host()) {
        case "subouttest.herokuapp.com":
          return "https://subouttest.chargify.com/h/3289099/subscriptions/new";
        case "suboutdev.herokuapp.com":
          return "https://suboutdev.chargify.com/h/3288752/subscriptions/new";
        case "suboutdemo.herokuapp.com":
          return "https://suboutdemo.chargify.com/h/3289094/subscriptions/new";
        case "suboutapp.com":
          return "https://subout.chargify.com/h/3267626/subscriptions/new";
        default:
          return "https://suboutvps.chargify.com/h/3307351/subscriptions/new";
      }
    },
    suboutProSubscriptionUrl: function() {
      switch ($location.host()) {
        case "subouttest.herokuapp.com":
          return "https://subouttest.chargify.com/h/3289099/subscriptions/new";
        case "suboutdev.herokuapp.com":
          return "https://suboutdev.chargify.com/h/3288752/subscriptions/new";
        case "suboutdemo.herokuapp.com":
          return "https://suboutdemo.chargify.com/h/3289094/subscriptions/new";
        case "suboutapp.com":
          return "https://subout.chargify.com/h/3267626/subscriptions/new";
        default:
          return "https://suboutvps.chargify.com/h/3307356/subscriptions/new";
      }
    },
    nationalSubscriptionUrl: function() {
      switch ($location.host()) {
        case "subouttest.herokuapp.com":
          return "https://subouttest.chargify.com/h/3289099/subscriptions/new";
        case "suboutdev.herokuapp.com":
          return "https://suboutdev.chargify.com/h/3288752/subscriptions/new";
        case "suboutdemo.herokuapp.com":
          return "https://suboutdemo.chargify.com/h/3289094/subscriptions/new";
        case "suboutapp.com":
          return "https://subout.chargify.com/h/3267626/subscriptions/new";
        default:
          return "https://suboutvps.chargify.com/h/3289102/subscriptions/new";
      }
    },
    stateByStateSubscriptionUrl: function() {
      switch ($location.host()) {
        case "subouttest.herokuapp.com":
          return "https://subouttest.chargify.com/h/3289101/subscriptions/new";
        case "suboutdev.herokuapp.com":
          return "https://suboutdev.chargify.com/h/3288754/subscriptions/new";
        case "suboutdemo.herokuapp.com":
          return "https://suboutdemo.chargify.com/h/3289096/subscriptions/new";
        case "suboutapp.com":
          return "https://subout.chargify.com/h/3266718/subscriptions/new";
        default:
          return "https://suboutvps.chargify.com/h/3289104/subscriptions/new";
      }
    }
  };
});

suboutSvcs.factory("soPagination", function($rootScope, $location) {
  return {
    paginate: function($scope, model, page, config, callback) {
      config = config || {};
      config.page = page;
      config.api_token = $rootScope.token.api_token;
      return model.paginate(config, function(data) {
        var info, meta, paginationNumPagesToShow, _i, _ref, _ref1, _results;
        info = callback ? callback($scope, data) : {};
        $scope.paginated_results = info.results || data.results;
        meta = data.meta;
        $scope.page = meta.page;
        $scope.maxPage = Math.ceil(meta.count / meta.per_page);
        paginationNumPagesToShow = info.paginationNumPagesToShow || 10;
        $scope.startPage = parseInt(($scope.page - 1) / paginationNumPagesToShow) * paginationNumPagesToShow + 1;
        $scope.endPage = Math.min($scope.startPage + paginationNumPagesToShow - 1, $scope.maxPage);
        return $scope.pages = (function() {
          _results = [];
          for (var _i = _ref = $scope.startPage, _ref1 = $scope.endPage; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; _ref <= _ref1 ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this);
      });
    },
    setPage: function($scope, page) {
      var _i, _ref, _results;
      if (__indexOf.call((function() {
        _results = [];
        for (var _i = 1, _ref = $scope.maxPage; 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this), page) >= 0 && page !== $scope.page) {
        return $location.search({
          page: page,
          sort_by: $scope.sortBy,
          sort_direction: $scope.sortDirection,
          query: $scope.query
        });
      }
    }
  };
});
