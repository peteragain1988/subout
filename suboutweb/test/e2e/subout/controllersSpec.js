'use strict';
describe('Subout: Controllers', function() {

  beforeEach(function() {
    browser().navigateTo('/');
  });

  it('should automatically hop to the /sign_in page when the user is not authenticated', function() {
    expect(browser().location().url()).toBe("/sign_in");
  });

});
