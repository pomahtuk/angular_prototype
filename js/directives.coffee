"use strict"

# Directives 
angular.module("Museum.directives", [])

# Focus and blur support
.directive "ngBlur", ->
  (scope, elem, attrs) ->
    elem.bind "blur", ->
      scope.$apply attrs.ngBlur

.directive "ngFocus", ($timeout) ->
  (scope, elem, attrs) ->
    scope.$watch attrs.ngFocus, (newval) ->
      if newval
        $timeout (->
          elem[0].focus()
        ), 0, false

.directive "focusMe", ($timeout, $parse) ->  
  link: (scope, element, attrs) ->
    model = $parse(attrs.focusMe)
    scope.$watch model, (value) ->
      if value is true
        $timeout ->
          element[0].focus()
    element.bind "blur", ->
      scope.$apply model.assign(scope, false)

# Helper directives
.directive "stopEvent", ->
  link: (scope, element, attr) ->
    element.bind attr.stopEvent, (e) ->
      e.stopPropagation()

.directive "resizer", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.focus ->
      elem.animate {'width': '+=150'}, 200
    elem.blur ->
      elem.animate {'width': '-=150'}, 200

.directive "toggleMenu", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      $('.navigation').toggleClass 'navbar-fixed-top'
      $('.museum_navigation_menu').slideToggle(300)
      $('body').toggleClass('fixed_navbar')
      setTimeout ->
        $.scrollTo(0,0)
      , 0

.directive "toggleFilters", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      $('.filters_bar').slideToggle(200)
      setTimeout ->
        $('body').toggleClass('filers')
      , 100

.directive 'postRender', ($timeout) ->
  restrict : 'A',
  # terminal : true
  # transclude : true
  link : (scope, element, attrs) ->
    if scope.$last
      $timeout scope.grid, 0
    true

# Custom HTML elements
.directive "switchpubitem", ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    provider: '=ngProvider'
    current_museum: '=ngMuseum'
    trans: '=translations'
  template: """
    <div class="btn-group pull-right item_publish_settings">
      <button class="btn btn-success dropdown-toggle" data-toggle="dropdown" type="button" ng-switch on="item.stories[current_museum.language].publish_state">
        <div class="extra" ng-switch on="item.stories[current_museum.language].publish_state">
          <i class="icon-globe" ng-switch-when="all" ></i>
          <i class="icon-user" ng-switch-when="passcode" ></i>
        </div>
        <span ng-switch-when="passcode">Publish</span>
        <span ng-switch-when="all">Published</span>
        <span class="caret"></span>
      </button>
      <ul class="dropdown-menu status-select-dropdown" role="menu">
        Who can see it in mobile application
        <li class="divider"></li>
        <li ng-click="item.stories[current_museum.language].publish_state = 'all'">
          <i class="icon-globe"></i> Everyone
          <span class="check" ng-show="item.stories[current_museum.language].publish_state == 'all'">✓</span>
        </li>
        <li  ng-click="item.stories[current_museum.language].publish_state = 'passcode'">
          <i class="icon-user"></i> Only users who have passcode
          <span class="check" ng-show="item.stories[current_museum.language].publish_state == 'passcode'">✓</span>
          <div class="limited-pass-hint hidden">
            <div class="limited-pass">
              {{provider.passcode}}
            </div>
            <a href="{{provider.passcode_edit_link}}" target="_blank">Edit</a>
          </div>
        </li>
        <li class="divider"></li>
        <li class="other_list">
          <span class="other_lang" ng-click="hidden_list=!hidden_list" stop-event="click">Other languages</a>
          <ul class="other" ng-hide="hidden_list">
            <li ng-repeat="(name, story) in item.stories" ng-switch on="story.publish_state">
              <span class="col-lg-4">{{trans[name]}} </span>
              <i class="icon-globe" ng-switch-when="all" ></i>
              <i class="icon-user" ng-switch-when="passcode" ></i>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  """  
  link: (scope, element, attrs) ->
    scope.hidden_list = true
    true

.directive "switchpub", ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    provider: '=ngProvider'
  template: """
    <div class="btn-group">
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown" type="button">
        <div class="extra_right" ng-switch on="item.publish_state">
          <i class="icon-globe" ng-switch-when="all" ></i>
          <i class="icon-user" ng-switch-when="passcode" ></i>
        </div>
        <span class="caret"></span></button>
      <ul class="dropdown-menu" role="menu">
        Who can see it in mobile application
        <li class="divider"></li>
        <li  ng-click="item.publish_state = 'all'">
          <i class="icon-globe"></i> Everyone
          <span class="check" ng-show="item.publish_state == 'all'">✓</span>
        </li>
        <li ng-click="item.publish_state = 'passcode'">
          <i class="icon-user"></i> Only users who have passcode
          <span class="check" ng-show="item.publish_state == 'passcode'">✓</span>
          <div class="limited-pass-hint hidden">
            <div class="limited-pass">
              {{provider.passcode}}
            </div>
            <a href="{{provider.passcode_edit_link}}" target="_blank">Edit</a>
          </div>
        </li>
      </ul>
    </div>
  """  
  link: (scope, element, attrs) ->
    true

.directive "placeholderfield", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
    inv_sign: '=invalidsign'
    placeholder: '=placeholder'
  template: """
    <div class="form-group">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      {{active_exhibit}}
      <span class="empty_name_error {{field}}">can't be empty</span>
      <div class="col-xs-6 trigger" ng-hide="edit_mode || empty_val">
        <span class="placeholder" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-xs-6 triggered" ng-show="edit_mode || empty_val">
        <input class="form-control" id="{{id}}" ng-model="item[field]" focus-me="edit_mode" type="text" ng-blur="status_process()" required placeholder="{{placeholder}}">
        <div class="error_text {{field}}" >can't be blank</div>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.status_process = ->
      if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0
        $scope.status = 'progress'
        $scope.empty_val = false
        $scope.edit_mode = false
      else
        $scope.empty_val = true
  link: (scope, element, attrs) ->
    scope.edit_mode = false
    scope.$watch 'item[field]', (newValue, oldValue) ->
      scope.status    = ''
      unless newValue
        scope.empty_val = true
      else
        scope.empty_val = false
    scope.$watch 'inv_sign', (newValue, oldValue) ->
      if newValue is true
        setTimeout ->
          scope.name_error = false
          console.log scope.name_error
        , 1000
      else
        scope.empty_val = false

    # scope.$watch 'status', (newValue, oldValue) ->
    #   if newValue is 'progress'
    #     scope.exhibits = angular.copy(scope.work_exhibits)
    #     scope.$apply

    true

.directive "placeholdertextarea", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
    max_length: '@maxlength'
    placeholder: '=placeholder'
  template: """
    <div class="form-group">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <span class="sumbols_left" ng-hide="status == 'progress' || status == 'done' || empty_val || !edit_mode ">
        {{length_text}}
      </span>
      <div class="col-lg-6 trigger" ng-hide="edit_mode || empty_val">
        <span class="placeholder large" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-6 triggered" ng-show="edit_mode || empty_val">
        <textarea class="form-control" id="{{id}}" focus-me="edit_mode" ng-model="item[field]" ng-blur="status_process()" required placeholder="{{placeholder}}">
        </textarea>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.status_process = ->
      if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0
        $scope.status = 'progress'
        $scope.empty_val = false
        $scope.edit_mode = false
      else
        $scope.empty_val = true
  link: (scope, element, attrs) ->
    scope.length_text = "осталось символов: 255"
    scope.edit_mode = false
    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.empty_val = true
        scope.length_text = "осталось символов: 255"
      else
        scope.empty_val = false
        scope.max_length ||= 255
        scope.length_text = "осталось символов: #{scope.max_length - newValue.length - 1}"
        if newValue.length >= scope.max_length
          scope.item[scope.field] = newValue.substr(0, scope.max_length-1)
    true

.directive "quizanswer", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    collection: '=ngCollection'
    id: '@ngId'
  template: """
    <div class="form-group string optional checkbox_added">
      <label class="string optional control-label col-xs-2" for="{{id}}">
        <span class='correct_answer_indicator' ng-show="item.correct_saved">correct</span>
      </label>
      <input class="coorect_answer_radio" name="correct_answer" type="radio" value="{{item.id}}" ng-model="checked" ng-click="check_items(item)">
      <div class="col-xs-5 trigger" ng-hide="edit_mode || empty_val">
        <span class="placeholder" ng-click="edit_mode = true">{{item.title}}</span>
      </div>
      <div class="col-xs-5 triggered" ng-show="edit_mode || empty_val">
        <input class="form-control" id="{{id}}" name="{{item.id}}" placeholder="Enter option" type="text" ng-model="item.title" focus-me="edit_mode" ng-blur="status_process()" required>
        <div class="error_text">can't be blank</div>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.title]
    $scope.item.correct_saved = false unless $scope.item.correct_saved?

    $scope.check_items = (item) ->
      for sub_item in $scope.collection
        sub_item.correct = false
        sub_item.correct_saved = false
      item.correct = true
      $scope.item.correct_saved = true

    $scope.status_process = ->
      if $scope.item.title && $scope.item.title.length isnt 0
        $scope.status = 'progress'
        $scope.empty_val = false
        $scope.edit_mode = false
      else
        $scope.empty_val = true

  link: (scope, element, attrs) ->
    scope.edit_mode = false
    scope.empty_val = false

    scope.checked = 0
    scope.$watch 'collection', (newValue, oldValue) ->
      if newValue
        for single_item in newValue
          scope.checked = single_item.id if single_item.correct is true            

    scope.$watch 'item.title', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = true
        scope.empty_val = true
      else
        scope.empty_val = false

    scope.$watch 'item.correct_saved', (newValue, oldValue) ->
      if newValue is true
        setTimeout ->
          scope.$apply scope.item.correct_saved = false
        , 1000

    , true

.directive "statusIndicator", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngBinding'
    field: '=ngField'
  template: """
    <div class="statuses">
      <div class='preloader' ng-show="item=='progress'"></div>
      <div class="save_status" ng-show="item=='done'">
        <i class="icon-ok-sign"></i>saved
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.$watch 'item', (newValue, oldValue) ->
      # code below just emulates work of server and some latency
      if newValue
        if newValue is 'progress'
          scope.progress_timeout = setTimeout ->
            scope.$apply scope.item = 'done'
          , 500
        if newValue is 'done'
          scope.done_timeout = setTimeout ->
            scope.$apply scope.item = ''
          , 700
      else
        clearTimeout(scope.done_timeout)
        clearTimeout(scope.progress_timeout)
    , true

    true

.directive "audioplayer", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
  template: """
    <div class="form-group">
      <label class="col-xs-2 control-label" for="audio">Audio</label>
      <div class="help">
        <i class="icon-question-sign" data-content="Supplementary field. You may indicate the exhibit’s inventory, or any other number, that will help you to identify the exhibit within your own internal information system." data-placement="bottom"></i>
      </div>
      <div class="col-xs-6 trigger" ng-hide="edit_mode">
        <div class="jp-jplayer" id="jquery_jplayer_{{id}}">
        </div>
        <div class="jp-audio" id="jp_container_{{id}}">
          <div class="jp-type-single">
            <div class="jp-gui jp-interface">
              <ul class="jp-controls">
                <li>
                <a class="jp-play" href="javascript:;" tabindex="1"></a>
                </li>
                <li>
                <a class="jp-pause" href="javascript:;" tabindex="1"></a>
                </li>
              </ul>
            </div>
            <div class="dropdown">
              <a data-toggle="dropdown" href="#" id="visibility_filter">Audioguide 01<span class="caret"></span></a>
              <ul aria-labelledby="visibility_filter" class="dropdown-menu" role="menu">
                <li role="presentation">
                <a href="#" role="menuitem" tabindex="-1">Replace</a>
                </li>
                <li role="presentation">
                <a href="#" role="menuitem" tabindex="-1">Download</a>
                </li>
              </ul>
            </div>
            <div class="jp-progress">
              <div class="jp-seek-bar">
                <div class="jp-play-bar">
                </div>
              </div>
            </div>
            <div class="jp-time-holder">
              <div class="jp-current-time">
              </div>
              <div class="jp-duration">
              </div>
            </div>
            <div class="jp-no-solution">
              <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank"></a>
            </div>
          </div>
        </div>
      </div>
      <div class="col-xs-6 triggered" ng-show="edit_mode">
        <input type="file" id="exampleInputFile">
      </div>
      <status-indicator ng-binding="item" ng-field="field"></statusIndicator>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.edit_mode = false
    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = true
      else
        scope.edit_mode = false
        console.log newValue
        $("#jquery_jplayer_#{scope.id}").jPlayer
          cssSelectorAncestor: "#jp_container_#{scope.id}"
          swfPath: "/js"
          wmode: "window"
          preload: "auto"
          smoothPlayBar: true
          keyEnabled: true
          supplied: "m4a, oga"
        $("#jquery_jplayer_#{scope.id}").jPlayer "setMedia",
          m4a: newValue
          oga: newValue
    true

.directive "museumSearch", ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngModel'
  template: """
    <div class="searches">
      <div class="search" ng-hide="museum_search_visible" ng-click="museum_search_visible=true; museum_input_focus = true">
        <i class="icon-search"></i>
        <a href="#">{{item || 'Search'}}</a>
      </div>
      <div class="search_input" ng-show="museum_search_visible">
        <input class="form-control" ng-model="item" placeholder="Search" type="text" focus-me="museum_input_focus">
        <a class="search_reset" href="#" ng-click="item=''">
          <i class="icon-remove-sign"></i>
        </a>
      </div>
    </div>
  """ 
  controller: ($scope, $element) ->
    $scope.museum_search_visible = false
    $scope.museum_input_focus = false

    $($element).find('.search_input input').blur ->
      elem   = $ @
      $scope.$apply $scope.museum_input_focus = false
      elem.animate {width: '150px'}, 150, ->
        $scope.$apply $scope.museum_search_visible = false
        true

    $($element).find('.search_input input').focus ->
      input = $ @
      width = $('body').width() - 700
      if width > 150
        input.animate {width: "#{width}px"}, 300

  link: (scope, element, attrs) ->
    true