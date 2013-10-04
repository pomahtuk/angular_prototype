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
      $timeout scope.grid, 200
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
    field: '@field'
    field_type: '@type'
  template: """
    <div class="btn-group pull-right item_publish_settings">
      <button class="btn btn-success dropdown-toggle" data-toggle="dropdown" type="button" ng-switch on="item[field]">
        <div class="extra" ng-switch on="item[field]">
          <i class="icon-globe" ng-switch-when="published" ></i>
          <i class="icon-user" ng-switch-when="passcode" ></i>
        </div>
        <span ng-switch-when="passcode">Publish</span>
        <span ng-switch-when="published">Published</span>
        <span class="caret"></span>
      </button>
      <ul class="dropdown-menu status-select-dropdown" role="menu">
        Who can see it in mobile application
        <li class="divider"></li>
        <li ng-click="item[field] = 'published'; status_process()">
          <i class="icon-globe"></i> Everyone
          <span class="check" ng-show="item[field] == 'published'">✓</span>
        </li>
        <li ng-click="item[field] = 'passcode'; status_process()">
          <i class="icon-user"></i> Only users who have passcode
          <span class="check" ng-show="item[field] == 'passcode'">✓</span>
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
            <li ng-repeat="(name, story) in item.stories" ng-switch on="story.status">
              <span class="col-lg-4">{{trans[name]}} </span>
              <i class="icon-globe" ng-switch-when="published" ></i>
              <i class="icon-user" ng-switch-when="passcode" ></i>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  """ 
  controller: ($scope, $rootScope, $element, $attrs) ->
    $scope.status_process = ->
      valid = true
      if valid
        $rootScope.$broadcast 'changes_to_save', $scope
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
    field: '@field'
    field_type: '@type'
  template: """
    <div class="btn-group">
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown" type="button">
        <div class="extra_right" ng-switch on="item[field]">
          <i class="icon-globe" ng-switch-when="published" ></i>
          <i class="icon-user" ng-switch-when="passcode" ></i>
        </div>
        <span class="caret"></span></button>
      <ul class="dropdown-menu" role="menu">
        Who can see it in mobile application
        <li class="divider"></li>
        <li  ng-click="item[field] = 'published'; status_process()">
          <i class="icon-globe"></i> Everyone
          <span class="check" ng-show="item[field] == 'published'">✓</span>
        </li>
        <li ng-click="item[field] = 'passcode'; status_process()">
          <i class="icon-user"></i> Only users who have passcode
          <span class="check" ng-show="item[field] == 'passcode'">✓</span>
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
  controller: ($scope, $rootScope, $element, $attrs) ->
    $scope.status_process = ->
      valid = true
      if valid
        $rootScope.$broadcast 'changes_to_save', $scope
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
    field_type: '@type'
  template: """
    <div class="form-group textfield">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      {{active_exhibit}}
      <span class="empty_name_error {{field}}">can't be empty</span>
      <div class="col-xs-6 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-6 triggered">
        <input class="form-control" id="{{id}}" ng-model="item[field]" required placeholder="{{placeholder}}">
        <div class="error_text {{field}}" >can't be blank</div>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]
    $scope.status_process = ->
      if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0 
        if $scope.item[$scope.field] isnt $scope.oldValue
          $scope.status = 'progress'
          if $scope.$parent.$parent.new_item_creation and $scope.field is 'name'
            console.log 'wow'
            $rootScope.$broadcast 'save_new_exhibit'
          else
            $rootScope.$broadcast 'changes_to_save', $scope
  link: (scope, element, attrs) ->
    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show().children().first().focus()

    element.find('.triggered > *').blur ->
      elem = $ @
      scope.status_process()
      if elem.val() isnt ''
        triggered.hide()
        trigger.show()

    # scope.edit_mode = false
    scope.$watch 'item[field]', (newValue, oldValue) ->
      scope.status = ''
      unless newValue
        trigger.hide()
        if scope.filed is 'name'
          triggered.find('.form-control').focus()
      else
        if scope.$parent.$parent.element_switch is true
          if triggered.is(':visible')
            trigger.show()
            triggered.hide()

    # scope.$watch 'inv_sign', (newValue, oldValue) ->
    #   if newValue is true
    #     setTimeout ->
    #       scope.name_error = false
    #       console.log scope.name_error
    #     , 1000
    #   else
    #     scope.empty_val = false

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
    field_type: '@type'
  template: """
    <div class="form-group textfield">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <span class="sumbols_left" ng-hide="status == 'progress' || status == 'done' || empty_val || !edit_mode ">
        {{length_text}}
      </span>
      <div class="col-lg-6 trigger">
        <span class="placeholder large" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-lg-6 triggered">
        <textarea class="form-control" id="{{id}}" ng-model="item[field]" required placeholder="{{placeholder}}">
        </textarea>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]
    $scope.status_process = ->
      if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0 
        if $scope.item[$scope.field] isnt $scope.oldValue
          $scope.status = 'progress'
          $rootScope.$broadcast 'changes_to_save', $scope
        $scope.empty_val = false
        $scope.edit_mode = false
      else
        $scope.empty_val = true
  link: (scope, element, attrs) ->
    scope.length_text = "осталось символов: 255"

    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show().children().first().focus()

    element.find('.triggered > *').blur ->
      elem = $ @
      scope.status_process()
      if elem.val() isnt ''
        triggered.hide()
        trigger.show()

    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.length_text = "осталось символов: 255"
        trigger.hide()
        triggered.show()
      else
        scope.max_length ||= 255
        scope.length_text = "осталось символов: #{scope.max_length - newValue.length - 1}"
        if newValue.length >= scope.max_length
          scope.item[scope.field] = newValue.substr(0, scope.max_length-1)
        if scope.$parent.$parent.element_switch is true
          if triggered.is(':visible')
            trigger.show()
            triggered.hide()
        true
    true

.directive "quizanswer", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    collection: '=ngCollection'
    id: '@ngId'
    field: '@field'
    field_type: '@type'
  template: """
    <div class="form-group string optional checkbox_added">
      <label class="string optional control-label col-xs-2" for="{{id}}">
        <span class='correct_answer_indicator' ng-show="item.correct_saved">correct</span>
      </label>
      <input class="coorect_answer_radio" name="correct_answer" type="radio" value="{{item._id}}" ng-model="checked" ng-click="check_items(item)">
      <div class="col-xs-5 trigger" ng-hide="edit_mode || empty_val">
        <span class="placeholder" ng-click="edit_mode = true; update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-5 triggered" ng-show="edit_mode || empty_val">
        <input class="form-control" id="{{id}}" name="{{item._id}}" placeholder="Enter option" type="text" ng-model="item[field]" focus-me="edit_mode" ng-blur="status_process()" required>
        <div class="error_text">can't be blank</div>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.content]
    $scope.item.correct_saved = false unless $scope.item.correct_saved?

    $scope.check_items = (item) ->
      $rootScope.$broadcast 'quiz_changes_to_save', $scope, item

    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]

    $scope.status_process = ->
      console.log 'status_process'
      if $scope.item[$scope.field] && $scope.item.content.length isnt 0
        console.log $scope.oldValue, $scope.item[$scope.field]
        if $scope.item[$scope.field] isnt $scope.oldValue 
          $scope.status = 'progress'
          $rootScope.$broadcast 'changes_to_save', $scope
        $scope.empty_val = false
        $scope.edit_mode = false
      else
        $scope.empty_val = true

  link: (scope, element, attrs) ->
    scope.edit_mode = false
    scope.empty_val = false

    scope.$watch 'collection', (newValue, oldValue) ->
      if newValue
        scope.checked = newValue[0]._id
        for single_item in newValue
          scope.checked = single_item._id if single_item.correct is true            

    scope.$watch 'item.content', (newValue, oldValue) ->
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

.directive 'canDragAndDrop', ($timeout) ->
  restrict : 'A'
  require: '?ngModel'
  scope:
    model: '=ngModel'
    url: '@uploadTo'
  link : (scope, element, attrs) ->

    console.log scope.url, scope.model

    $(document).bind 'drop dragover', (e) ->
      e.preventDefault()

    $(document).bind "dragover", (e) ->
      dropZone = $("#dropzone")
      doc      = $(".page")
      timeout = scope.dropZoneTimeout
      unless timeout
        doc.addClass "in"
      else
        clearTimeout timeout
      found = false
      node = e.target
      loop
        if node is dropZone[0]
          found = true
          break
        node = node.parentNode
        break unless node?
      if found
        dropZone.addClass "hover"
      else
        dropZone.removeClass "hover"
      scope.dropZoneTimeout = setTimeout(->
        scope.dropZoneTimeout = null
        dropZone.removeClass "in hover"
        doc.removeClass "in" unless scope.loading_in_progress
      , 100)

    $("#fileupload").fileupload(
      url: scope.url
      dataType: "json"
      dropZone: $(".dropdown_area")
      drop: (e, data) ->
        scope.loading_in_progress = true
        $.each data.files, (index, file) ->
          console.log "Dropped file: " + file.name
      success: (result) ->
        console.log result
        for image in result
          scope.model.images.push image
      error: (result, status, errorThrown) ->
        console.log status, result, errorThrown
        if errorThrown == 'abort'
          console.log 'abort'
        else
          if result.status == 422
            response = jQuery.parseJSON(result.responseText)
            responseText = response.link[0]
            console.log responseText
          else
            console.log 'unknown error'
      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $("#progress .progress-bar").css "width", progress + "%"
        if progress is 100
          setTimeout ->
            $(".page").removeClass "in"
            scope.loading_in_progress = false
          , 1000
    ).prop("disabled", not $.support.fileInput).parent().addClass (if $.support.fileInput then `undefined` else "disabled")

    scope.$watch 'url', (newValue, oldValue) ->
      console.log newValue
      $("#fileupload").fileupload "option", "url", newValue

