subout.directive 'multiple', ->
  scope: false,
  link: (scope, element, attrs) ->
    element.multiselect
      enableFiltering: true
      selectAllText: "All"
      buttonText: (options, select)->
        if (options.length == 0)
          return "#{attrs.placeholder} <b class='caret'></b>"
        else if (options.length > 3)
          return options.length + ' selected <b class="caret"></b>'
        else
          selected = ""
          options.each ()->
            selected += $(this).text() + ", "

          return selected.substr(0, selected.length-2) + ' <b class="caret"></b>'

    scope.$watch ->
      return element[0].length
    ,()->
      element.multiselect('rebuild')

    scope.$watch attrs.ngModel
    ,() ->
      element.multiselect('refresh')

    if (scope.$last)
      element.multiselect('refresh')
        
subout.directive "relativeTime", ->
  link: (scope, element, iAttrs) ->
    variable = iAttrs["relativeTime"]
    scope.$watch variable, ->
      $(element).timeago() if $(element).attr('title') isnt ""

subout.directive "whenScrolled", ->
  (scope, element, attr) ->
    fn = ->
      if $(window).scrollTop() > $(document).height() - $(window).height() - 50
        scope.$apply(attr.whenScrolled)

    scope.$on('$routeChangeStart', ->
      fn = ->
      return null
    )

    $(window).scroll ->
      fn()

subout.directive "salesInfoMessages", ($rootScope) ->
  link: (scope, iElement, iAttrs) ->
    variable = iAttrs["salesInfoMessages"]
    scope.$watch variable, ->
      messages = scope[variable]
      if messages and messages.length > 0
        $rootScope.salesInfoMessageIdx = ($rootScope.salesInfoMessageIdx || 0) % messages.length
        iElement.text(messages[$rootScope.salesInfoMessageIdx])
        $rootScope.salesInfoMessageIdx += 1
