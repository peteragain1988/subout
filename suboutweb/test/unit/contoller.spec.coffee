'use strict'
# MochaJS specs for controllers go here
# http://visionmedia.github.com/mocha/
# http://chaijs.com/
describe "controllers", ->
  beforeEach(module "subout")

  describe "AppCtrl", ->
    it "should populate the regions into the scope", inject ($rootScope, $controller, $location) ->
      $scope = $rootScope.$new()
      ctrl = $controller "AppCtrl",
        $scope: $scope,
        $rootScope : $rootScope,
        $location : $location
      expect($rootScope.ALL_REGIONS).not.to.equal(null)
      expect($rootScope.ALL_REGIONS['Georgia']).not.to.equal(null)

    it "should prepare a signout link", inject ($rootScope, $controller, $location) ->
      $scope = $rootScope.$new()
      ctrl = $controller "AppCtrl",
        $scope: $scope,
        $rootScope : $rootScope,
        $location : $location
      expect($rootScope.signOut).not.to.equal(null)

  describe "OpportunityCtrl", ->
    it "should have a working controller", inject ($rootScope, $controller, $location) ->
      $scope = $rootScope.$new()
      ctrl = $controller "OpportunityCtrl",
        $scope: $scope,
        $rootScope : $rootScope,
        $location : $location
      expect($scope.opportunities).not.to.equal(null)
