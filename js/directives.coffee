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
  transclude: true
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
      <div class="col-lg-6 trigger" ng-hide="edit_mode || item[field].length == 0">
        <span class="placeholder" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-6 triggered" ng-show="edit_mode || item[field].length == 0">
        <input class="form-control" id="{{id}}" ng-model="item[field]" focus-me="edit_mode" type="text"  ng-blur="item.statuses[field]='progress'">
      </div>
      <status-indicator ng-model="item" ng-field="field"></statusIndicator>
    </div>
  """  
  # The linking function will add behavior to the template
  link: (scope, element, attrs) ->
    true

.directive "placeholdertextarea", ->
  restrict: "E"
  replace: true
  transclude: true
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
      <div class="col-lg-6 trigger" ng-hide="edit_mode || item[field].length == 0">
        <span class="placeholder large" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-6 triggered" ng-show="edit_mode || item[field].length == 0">
        <textarea class="form-control" id="{{id}}" focus-me="edit_mode" ng-model="item[field]" ng-blur="item.statuses[field]='progress'">
        </textarea>
      </div>
      <status-indicator ng-model="item" ng-field="field"></statusIndicator>
    </div>
  """  
  link: (scope, element, attrs) ->
    # console.log scope.item[scope.field]
    true

.directive "quizanswer", ->
  restrict: "E"
  replace: true
  transclude: true
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
      <div class="col-lg-5 trigger"  ng-hide="edit_mode || item[field].length == 0">
        <span class="placeholder" ng-click="edit_mode = true">{{item[field]}}</span>
      </div>
      <div class="col-lg-5 triggered" ng-show="edit_mode || item[field].length == 0">
        <input class="form-control" id="{{id}}" placeholder="Enter option" type="text" ng-model="item[field]" focus-me="edit_mode" ng-blur="item.statuses[field]='progress'">
      </div>
      <status-indicator ng-model="item" ng-field="field"></statusIndicator>
    </div>
  """  
  link: (scope, element, attrs) ->

    scope.checked = 0

    scope.check_items = (item) ->
      for single_item in scope.collection
        single_item.correct = false
      item.correct = true
      console.log item
    true

    scope.$watch 'collection', (newValue, oldValue) ->
      if newValue
        for single_item in newValue
          scope.checked = single_item.id if single_item.correct is true            
    , true

.directive "statusIndicator", ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngModel'
    field: '=ngField'
  template: """
    <div class="statuses">
      <div class='preloader' ng-show="item.statuses[field]=='progress'"></div>
      <div class="save_status" ng-show="item.statuses[field]=='done'">
        <i class="icon-ok-sign"></i>saved
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.item.statuses = {} unless scope.item.statuses?
    scope.$watch 'item.statuses[field]', (newValue, oldValue) ->
      # code below just emulates work of server and some latency
      if newValue
        if newValue is 'progress'
          setTimeout ->
            scope.$apply scope.item.statuses[scope.field] = 'done'
          , 500
        if newValue is 'done'
          setTimeout ->
            scope.$apply scope.item.statuses[scope.field] = ''
          , 700
    , true