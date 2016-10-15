basePath = '../';

files = [
  MOCHA,
  MOCHA_ADAPTER,
  './config/mocha.conf.js',

  //Subout Code
  '../subout/public/js/vendor.js',
  '../subout/public/js/app.js',

  //Test-Specific Code
  './node_modules/chai/chai.js',
  './test/lib/chai-should.js',
  './test/lib/chai-expect.js',
  './test/lib/angular/angular-mocks.js',

  //Test-Specs
  '../subout/public/test/unit.js'
];

port = 9201;
runnerPort = 9301;
captureTimeout = 5000;

shared = require(__dirname + "/testacular.shared.conf.js").shared
growl     = shared.growl;
colors    = shared.colors;
singleRun = shared.singleRun;
autoWatch = shared.autoWatch;
browsers  = shared.defaultBrowsers;
reporters = shared.defaultReporters;

reportSlowerThan = 500;
