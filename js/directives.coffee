"use strict"

# Directives 
angular.module("Museum.directives", [])


# Focus and blur support
.directive "ngBlur", ->
  (scope, elem, attrs) ->
    elem.bind "blur", ->
      # console.log scope
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

# Custom HTML elements
.directive "switchpubitem", ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    provider: '=ngProvider'
  template: """
    <div class="btn-group pull-right item_publish_settings ololo">
      <button class="btn btn-success dropdown-toggle" data-toggle="dropdown" type="button" ng-switch on="item.publish_state">
        <div class="extra" ng-switch on="item.publish_state">
          <i class="icon-globe" ng-switch-when="all" ></i>
          <i class="icon-user" ng-switch-when="passcode" ></i>
        </div>
        <span ng-switch-when="passcode">Publish</span>
        <span ng-switch-when="all">Published</span>
        <span class="caret"></span>
      </button>
      <ul class="dropdown-menu status-select-dropdown" role="menu">
        Who can see it in mobile application
        <li ng-click="item.publish_state = 'all'">
          <i class="icon-globe"></i> Everyone
        </li>
        <li  ng-click="item.publish_state = 'passcode'">
          <i class="icon-user"></i> Only users who have passcode
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
            <li>
              <span class="col-lg-4">English </span><i class="icon-globe"></i>
            </li>
            <li>
              <span class="col-lg-4">Italian </span><i class="icon-lock"></i>
            </li>
            <li>
              <span class="col-lg-4">Japan</span>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  """  
  link: (scope, element, attrs) ->
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
        <li ng-click="item.publish_state = 'all'">
          <i class="icon-globe"></i> Everyone
        </li>
        <li ng-click="item.publish_state = 'passcode'">
          <i class="icon-user"></i> Only users who have passcode
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
  template: """
    <div class="form-group">
      <label class="col-lg-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-lg-6 trigger" ng-hide="edit_mode">
        <span class="placeholder" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-6 triggered" ng-show="edit_mode">
        <input class="form-control" id="{{id}}" ng-model="item[field]" focus-me="edit_mode" type="text" ng-blur="status='progress'">
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
  # The linking function will add behavior to the template
  link: (scope, element, attrs) ->
    scope.edit_mode = false
    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = true
      else
        scope.edit_mode = false
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
  template: """
    <div class="form-group">
      <label class="col-lg-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-lg-6 trigger" ng-hide="edit_mode">
        <span class="placeholder large" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-6 triggered" ng-show="edit_mode">
        <textarea class="form-control" id="{{id}}" focus-me="edit_mode" ng-model="item[field]" ng-blur="status='progress'">
        </textarea>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
  link: (scope, element, attrs) ->
    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = true
      else
        scope.edit_mode = false
    true

.directive "quizanswer", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    collection: '=ngCollection'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
  template: """
    <div class="form-group string optional checkbox_added">
      <label class="string optional control-label col-lg-2" for="{{id}}"></label>
      <input class="coorect_answer_radio" name="correct_answer" type="radio" value="{{item.id}}" ng-model="checked" ng-click="check_items(item)"> <!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
      <div class="col-lg-5 trigger"  ng-hide="edit_mode">
        <span class="placeholder" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-5 triggered" ng-show="edit_mode">
        <input class="form-control" id="{{id}}" placeholder="Enter option" type="text" ng-model="item[field]" focus-me="edit_mode" ng-blur="status='progress'">
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """
  controller : ($scope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.check_items = (item) ->
      for single_item in $scope.collection
        single_item.correct = false
      item.correct = true
    true
  link: (scope, element, attrs) ->
    scope.checked = 0
    scope.$watch 'collection', (newValue, oldValue) ->
      if newValue
        for single_item in newValue
          scope.checked = single_item.id if single_item.correct is true            

    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = true 

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
          setTimeout ->
            scope.$apply scope.item = 'done'
          , 500
        if newValue is 'done'
          setTimeout ->
            scope.$apply scope.item = ''
          , 700
    , true

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
      <label class="col-lg-2 control-label" for="audio">Audio</label>
      <div class="help">
        <i class="icon-question-sign" data-content="Supplementary field. You may indicate the exhibit’s inventory, or any other number, that will help you to identify the exhibit within your own internal information system." data-placement="bottom"></i>
      </div>
      <div class="col-lg-6 trigger" ng-hide="edit_mode">
        <div class="jp-jplayer" id="jquery_jplayer_1">
        </div>
        <div class="jp-audio" id="jp_container_1">
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
      <div class="col-lg-6 triggered" ng-show="edit_mode">
        <input type="file" id="exampleInputFile">
      </div>
      <status-indicator ng-binding="item" ng-field="field"></statusIndicator>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.edit_mode = false
    $("#jquery_jplayer_1").jPlayer
      swfPath: "/js"
      wmode: "window"
      preload: "auto"
      smoothPlayBar: true
      keyEnabled: true
      supplied: "oga"
    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = true
      else
        scope.edit_mode = false
        $("#jquery_jplayer_1").jPlayer "setMedia",
          oga:newValue
    true