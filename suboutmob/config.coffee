exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  modules:
    definition: false
    wrapper: false
  paths:
    public: '../public/mo'
    ignored: /(\/styles\/bootstrap\/)|(\/custom\/)|(bootstrap-3.0.0)|(test\/)/
    watched: ['app', 'scripts', 'vendor']
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^vendor/
      order:
        before: [
          'vendor/scripts/console-helper.js'
          'vendor/scripts/jquery/jquery-1.7.2.js'
          'vendor/scripts/jquery/jquery-ui-1.9.2.custom.min.js'
          'vendor/scripts/jquery/jquery.timeago.js'
          'vendor/scripts/jquery/jquery.timeentry.js'
          'vendor/scripts/jquery/jquery.iframe-transport.js'
          'vendor/scripts/jquery/jquery.fileupload.js'
          'vendor/scripts/jquery/jquery.cloudinary.js'
          'vendor/scripts/jquery/jquery.cookie.js'
          'vendor/scripts/jquery/lightbox.js'
          'vendor/scripts/jquery/jquery.maskedinput.js'
          'vendor/scripts/classify.min.js'
          'vendor/scripts/bootstrap/bootstrap.min.js'
          'vendor/scripts/bootstrap/bootstrap-multiselect.js'
          'vendor/scripts/underscore/underscore-min.js'
          'vendor/scripts/lodash.min.js'
          'vendor/scripts/underscore/underscore.string.js'

          'vendor/scripts/angular/angular.min.js'
          'vendor/scripts/angular-ui/angular-ui.js'
          'vendor/scripts/angular/angular-resource.js'
          'vendor/scripts/angular/angular-cookies.js'

          'vendor/styles/mobile-angular-ui/js/mobile-angular-ui.min.js'
          'vendor/styles/mobile-angular-ui/js/mobile-angular-ui.gestures.min.js'

        ]
    stylesheets:
      joinTo:
        'css/app.css': /^(app|vendor)/
      order:
        before: [
          'vendor/styles/jquery-ui/jquery-ui-1.9.1.custom.css'
          'vendor/styles/jquery/lightbox.css'
          'vendor/styles/select2/select2.css'
        ]
    templates:
      joinTo: 'js/templates.js'

  # Enable or disable minifying of result js / css files.
  # minify: true
  coffeelint:
    pattern: /^app\/.*\.coffee$/
    options:
      max_line_length:
        value: "80"
        level: "ignore"
