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
      $('.museum_navigation_menu').slideToggle(300)
      setTimeout ->
        $.scrollTo(0,0)
      , 0

.directive "toggleFilters", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      filters = $('.filters_bar')
      # actions = $('.actions_bar')
      margin = filters.css('top')
      if margin is '0px'
        filters.animate {'top': '-44px'}, 300
      else
        filters.animate {'top': '0px'}, 300
      scope.filters_opened = !scope.filters_opened

.directive 'postRender', ($timeout) ->
  restrict : 'A',
  # terminal : true
  # transclude : true
  link : (scope, element, attrs) ->
    if scope.$last
      $timeout scope.grid, 200
    true

# Custom HTML elements
.directive "switchpubitem", ($timeout, storySetValidation, $i18next) ->
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
    root: '=root'
  template: """
    <div class="btn-group pull-right item_publish_settings" ng-hide="item.status == 'draft'">
      <button class="btn btn-default" ng-class="{'active btn-success': item.status == 'published'}" ng-click="item.status = 'published'; status_process()" type="button" ng-switch on="item[field]">
        <div class="extra">
          <i class="icon-globe"></i>
        </div>
        <span ng-switch-default>{{ 'Publish' | i18next }}</span>
        <span ng-switch-when="published">{{ 'Published' | i18next }}</span>
      </button>


      <button class="btn btn-default" ng-hide="item.status == 'opas_invisible'" ng-class="{'active btn-primary': item.status == 'passcode' }" ng-click="item.status = 'passcode'; status_process()" type="button" ng-switch on="item[field]">
        <div class="extra">
          <i class="icon-lock"></i>
        </div>
        <span ng-switch-when="passcode">{{ 'Private' | i18next }}</span>
        <span ng-switch-when="published">{{ 'Make private' | i18next }}</span>
      </button>


      <button class="btn btn-default" ng-show="item.status == 'opas_invisible'" ng-class="{'active btn-danger': item.status == 'opas_invisible' }" ng-click="item.status = 'opas_invisible'; status_process()" type="button">
        <div class="extra">
          <i class="icon-eye-close"></i>
        </div>
        <span>{{ 'Invisible' | i18next }}</span>
        <!--<span>Make private</span>-->
      </button>


      <button class="btn btn-default dropdown-toggle">
        <span>
          <i class="icon-caret-down"></i>
        </span>
      </button>
      <ul class="dropdown-menu">
        <li ng-hide="item.status == 'opas_invisible'">
          <a href="#" ng-click="item.status = 'opas_invisible'; status_process()">
            <i class="icon-eye-close"></i> {{ 'Make invisible' | i18next }}
          </a>
        </li>
        <li ng-hide="item.status == 'passcode'  || item.status == 'published'">
          <a href="#" ng-click="item.status = 'passcode'; status_process()">
            <i class="icon-lock"></i> {{ 'Make private' | i18next }}
          </a>
        </li>
      </ul>
    </div>
  """ 
  controller: ($scope, $rootScope, $element, $attrs, storySetValidation) ->
    $scope.status_process = ->
      storySetValidation.checkValidity $scope

  link: (scope, element, attrs) ->
    scope.hidden_list = true
    true

.directive "switchpub", ($timeout) ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    provider: '=ngProvider'
    field: '@field'
    field_type: '@type'
    root: '=root'
  template: """
    <div class="btn-group pull-right">
      <button class="btn btn-default" type="button">
        <div ng-switch on="item[field]">
          <i class="icon-globe" ng-switch-when="published" ng-click="item[field] = 'passcode'; status_process()" ></i>
          <i class="icon-lock" ng-switch-when="passcode" ng-click="item[field] = 'published'; status_process()" ></i>
          <i class="icon-eye-close" ng-switch-when="opas_invisible" ng-click="item[field] = 'published'; status_process()" ></i>
        </div>
      </button>
    </div>
  """  
  controller: ($scope, $rootScope, $element, $attrs, storySetValidation) ->
    $scope.status_process = ->
      storySetValidation.checkValidity $scope

  link: (scope, element, attrs) ->
    true

.directive "newLangSwitch", ($rootScope) ->
  restrict: "E"
  replace: true
  scope:
    museum: '=museum'
  template: """
    <div class="form-group">
      <label class="col-xs-2 control-label" for="museum_language_select">{{ 'Language' | i18next }}</label>
      <div class="help ng-scope" popover="{{ 'Select language' | i18next }}" popover-animation="true" popover-placement="bottom" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-xs-6 triggered">
        <select class="form-control" ng-model="museum.language">
          <option disabled="" selected="" value="dummy">{{ 'Select a new language' | i18next }}</option>
          <option value="{{translation}}" ng-repeat="(translation, lang) in $parent.$parent.translations">{{translation | i18next }}</option>
        </select>
     </div>
    </div>
  """
  controller: ($scope, $element, $attrs) ->
    true
  link: (scope, element, attrs) ->
    
    scope.$watch 'museum.language', (newValue, oldValue) ->
      if newValue?
        if newValue isnt 'new_lang'
          console.log 'select', newValue
          # scope.$parent.create_new_language = false
          # $rootScope.$broadcast 'new_museum_language', newValue

    true

.directive "placeholderfield", ($timeout) ->
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
    <div class="form-group textfield {{field}}">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">
        {{title}}
        <span class="label label-danger informer" ng-show="empty_name_error">{{ "can't be empty" | i18next }}</span>
      </label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      {{active_exhibit}}
      <div class="col-xs-7 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-7 triggered">
        <input type="hidden" id="original_{{id}}" ng-model="item[field]" required>
        <input type="text" class="form-control" id="{{id}}" value="{{item[field]}}" placeholder="{{placeholder}}">
        <div class="additional_controls">
          <a href="#" class="apply"><i class="icon-ok"></i></a>
          <!--<a href="#" class="cancel"><i class="icon-remove"></i></a>-->
        </div>
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
      if $scope.item[$scope.field] isnt $scope.oldValue
        $scope.status = 'progress'
        $scope.$digest()
        if $scope.$parent.new_item_creation and $scope.field is 'name'
          if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0 
            $rootScope.$broadcast 'save_new_exhibit'
            return true
        if $scope.field is 'name' && $scope.item.status is 'draft'
          $scope.item.status = 'passcode'

        $rootScope.$broadcast 'changes_to_save', $scope

  link: (scope, element, attrs) ->
    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    control = element.find('.triggered > .form-control')
    additional = triggered.find('.additional_controls')

    scope.empty_name_error = false

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show()
      control.val scope.item[scope.field]
      control.focus()
      control.removeClass 'ng-invalid'

    element.find('.triggered > .form-control').focus ->
      additional.show()

    element.find('.triggered > .form-control').blur ->
      elem = $ @
      value = elem.val()
      additional.hide()
      $timeout ->
        unless scope.$parent.new_item_creation && scope.field is 'number'
          scope.item[scope.field] = value
          scope.$digest()
          if elem.val().length > 0
            scope.status_process()
          else
            return true
        if elem.val().length > 0
          triggered.hide()
          trigger.show()
        else
          elem.addClass 'ng-invalid'
          if scope.field is 'name' && scope.item.status isnt 'dummy'
            elem.val scope.oldValue
            scope.item[scope.field] = scope.oldValue
            scope.$digest()
            # element.find('.error_text').show()
            # setTimeout ->
            #   element.find('.error_text').hide()
            # , 2000
            triggered.hide()
            trigger.show()
            scope.status_process() if scope.item[scope.field] isnt ''
      , 100

    element.find('.triggered > .form-control').keyup ->  
      elem = $ @
      val = elem.val()
      if val is '' and scope.field is 'name' and scope.item[scope.field] isnt ''
        $timeout ->
          elem.val scope.oldValue
          scope.item[scope.field] = scope.oldValue
          scope.empty_name_error = true
          scope.$digest()
          setTimeout ->
            scope.empty_name_error = false
            scope.$digest()
          , 2000
          scope.status_process()
        , 0, false
      true

    scope.$watch 'item[field]', (newValue, oldValue) ->
      scope.status = ''
      criteria = if scope.field is 'number'
        newValue?
      else
        newValue
      unless criteria
        additional.hide()
        trigger.hide()
        triggered.show()
        control.val ''
        if scope.field is 'name'
          triggered.find('.form-control').focus()
      else
        additional.show()
        # if scope.$parent.element_switch is true
        element.find('.triggered > .form-control').val newValue
        trigger.show()
        triggered.hide()

    true

.directive "placeholdertextarea", ($timeout, storySetValidation, $i18next) ->
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
    <div class="form-group textfield large_field">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">
        {{title}}
        <span class="label label-danger" ng-show="field == 'long_description' && item[field].length == 0">{{ "Fill to publish" | i18next }}</span>
      </label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-xs-7 trigger">
        <div class="placeholder large" ng-click="update_old()">{{item[field]}}</div>
      </div>
      <div class="col-xs-7 triggered">
        <input type="hidden" id="original_{{id}}" ng-model="item[field]" required">
        <div class="content_editable" contenteditable="true" id="{{id}}" placeholder="{{placeholder}}">{{item[field]}}</div>
        <div class="additional_controls">
          <a href="#" class="apply"><i class="icon-ok"></i></a>
          <!--<a href="#" class="cancel"><i class="icon-remove"></i></a>-->
        </div>
      </div>
      <span class="sumbols_left">
        {{length_text}}
      </span>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]
    $scope.status_process = ->
      if $scope.item[$scope.field] isnt $scope.oldValue
        $scope.status = 'progress'
        $scope.$digest()
        $rootScope.$broadcast 'changes_to_save', $scope
  link: (scope, element, attrs) ->
    scope.length_text = "#{scope.max_length} symbols left"

    scope.max_length ||= 2000

    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    sumbols_left = element.find('.sumbols_left')
    control = triggered.children('.content_editable')
    additional = triggered.find('.additional_controls')

    element.find('div.placeholder').click ->
      trigger.hide()
      triggered.show()
      control.text scope.item[scope.field]
      control.focus()
      scope.length_text = "#{scope.max_length - control.text().length} #{$i18next('symbols left')}"
      sumbols_left.show()

    control.focus ->
      sumbols_left.show()
      additional.show()

    control.blur ->
      elem = $ @
      sumbols_left.hide()
      scope.item[scope.field] = elem.text()
      scope.$digest()
      scope.status_process()
      if elem.text() isnt ''
        triggered.hide()
        trigger.show()
        scope.status_process()
      else
        additional.hide()

    control.keyup (e) ->
      elem = $ @
      value = elem.text()
      if value.length > scope.max_length
        elem.text value.substr(0, scope.max_length)
      scope.length_text = "#{scope.max_length - value.length} #{$i18next('symbols left')}"
      scope.$digest()

    scope.$watch 'item[field]', (newValue, oldValue) ->
      scope.max_length ||= 2000
      
      unless newValue
        scope.length_text = "2000 #{$i18next('symbols left')}"
        control.text ''
        trigger.hide()
        triggered.show()
        # sumbols_left.show()
        additional.hide()
        if scope.field is 'long_description'
          storySetValidation.checkValidity {item: scope.item, root: scope.$parent.active_exhibit, field_type: 'story'}
      else
        additional.show()
        scope.length_text = "#{scope.max_length - newValue.length} #{$i18next('symbols left')}"
        # if newValue.length >= scope.max_length
        #   scope.item[scope.field] = newValue.substr(0, scope.max_length-1)
        if scope.$parent.element_switch is true
          trigger.show()
          triggered.hide()
          sumbols_left.hide()
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
    <div class="form-group textfield string optional checkbox_added">
      <label class="string optional control-label col-xs-2" for="{{id}}">
        <span class='correct_answer_indicator'>{{ "correct" | i18next }}</span>
      </label>
      <input class="coorect_answer_radio" name="correct_answer" type="radio" value="{{item._id}}" ng-model="checked" ng-click="check_items(item)">
      <div class="col-xs-5 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-5 triggered">
        <input class="form-control" id="{{id}}" name="{{item._id}}" placeholder="Enter option" type="text" ng-model="item[field]" required>
        <div class="error_text">{{ "can't be blank" | i18next }}</div>
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
      if $scope.item[$scope.field] isnt $scope.oldValue 
        $scope.status = 'progress'
        $scope.$digest()
        $rootScope.$broadcast 'changes_to_save', $scope

  link: (scope, element, attrs) ->
    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    indicator = element.find('.correct_answer_indicator')

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show().children().first().focus()

    element.find('.triggered > *').blur ->
      elem = $ @
      scope.status_process()
      if elem.val() isnt ''
        triggered.hide()
        trigger.show()

    scope.$watch 'collection', (newValue, oldValue) ->
      if newValue
        scope.checked = newValue[0]._id
        for single_item in newValue
          scope.checked = single_item._id if single_item.correct is true            

    scope.$watch 'item.content', (newValue, oldValue) ->
      unless newValue
        trigger.hide()
        triggered.show()
      else
        if scope.$parent.element_switch is true
          trigger.show()
          triggered.hide()

    scope.$watch 'item.correct_saved', (newValue, oldValue) ->
      if newValue is true
        indicator.show()
        setTimeout ->
          indicator.hide()
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
        <i class="icon-ok-sign"></i>{{ "saved" | i18next }}
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
    parent: '=parent'
  template: """
    <div class="form-group audio">
      <label class="col-xs-2 control-label" for="audio">
        {{ "Audio" | i18next }}
        <span class="label label-danger" ng-show="edit_mode == 'empty'">{{ "Fill to publish" | i18next }}</span>
      </label>
      <div class="help">
        <i class="icon-question-sign" data-content="{{ "Supplementary field." | i18next }}" data-placement="bottom"></i>
      </div>
      <div class="col-xs-9 trigger" ng-show="edit_mode == 'value'">
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
            <div class="jp-timeline">
              <div class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="#" id="visibility_filter">{{item[field].name}}<span class="caret"></span></a>
                <ul class="dropdown-menu" role="menu">
                  <li role="presentation">
                    <a href="#" class="replace_media" data-confirm="Are you sure you wish to replace this audio?" data-method="delete" data-link="{{$parent.$parent.backend_url}}/media/{{item[field]._id}}">Replace</a>
                  </li>
                  <li role="presentation">
                    <a href="{{item[field].url}}" target="_blank">Download</a>
                  </li>
                  <li role="presentation">
                    <a class="remove" href="#" data-confirm="Are you sure you wish to delete this audio?" data-method="delete" data-link="{{$parent.$parent.backend_url}}/media/{{media._id}}" delete-media="" stop-event="" media="item[field]" parent="item">Delete</a>
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
      </div>
      <div class="triggered" ng-show="edit_mode == 'empty'">
        <img class="upload_audio" src="/img/audio_drag.png" />
        <span>drag audio here or </span>
        <a href="#" class="btn btn-default" button-file-upload="">Click to upload</a>
      </div>
      <div class="col-xs-9 processing" ng-show="edit_mode == 'processing'">
        <img class="upload_audio" src="/img/medium_loader.GIF" style="float: left;"/> 
        <span>{{ "&nbsp;&nbsp;processing audio" | i18next }}</span>
      </div>
      <status-indicator ng-binding="item" ng-field="field"></statusIndicator>
    </div>
  """
  # controller: ($scope, $element, $attrs) ->
  #   $scope.replace_media = ()  ->
  #     true
  link: (scope, element, attrs) ->

    scope.edit_mode = false

    element = $ element
    element.find('.replace_media').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      elem   = $ @

      if confirm elem.data('confirm')
        parent = elem.parents('#drop_down, #museum_drop_down')
        parent.click()
        input = parent.find('.images :file')
        input.click()

    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = 'empty'
      else if newValue is 'processing'
        scope.edit_mode = 'processing'
      else
        scope.edit_mode = 'value'
        $("#jquery_jplayer_#{scope.id}").jPlayer
          cssSelectorAncestor: "#jp_container_#{scope.id}"
          swfPath: "/js"
          wmode: "window"
          preload: "auto"
          smoothPlayBar: true
          # keyEnabled: true
          supplied: "mp3, ogg"
        $("#jquery_jplayer_#{scope.id}").jPlayer "setMedia",
          mp3: newValue.url
          ogg: newValue.thumbnailUrl
    true

.directive "player", ->
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
    <div class="player">
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
          <div class="jp-timeline">
            <a class="dropdown-toggle" href="#">{{item[field].name}}</a>
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
      <div class="points_position_holder">
        <div class="image_connection" connection-draggable ng-class="{'hovered': image.image.hovered}" data-image-index="{{$index}}" draggable ng-repeat="image in $parent.active_exhibit.stories[$parent.current_museum.language].mapped_images" ng-mouseenter="set_hover(image, true)" ng-mouseout="set_hover(image, false)">
          {{ charFromNum(image.image.order) }}
        </div>
      </div>
    </div>
  """
  controller: ($scope, $element, $attrs) ->
    $scope.charFromNum = (num)  ->
      String.fromCharCode(num + 97).toUpperCase()

    $scope.set_hover = (image, sign) ->
      image.image.hovered = sign
      $scope.$parent.active_exhibit.has_hovered = sign

  link: (scope, element, attrs) ->
    scope.$watch 'item[field]', (newValue, oldValue) ->
      if newValue
        $("#jquery_jplayer_#{scope.id}").jPlayer
          cssSelectorAncestor: "#jp_container_#{scope.id}"
          swfPath: "/js"
          wmode: "window"
          preload: "auto"
          smoothPlayBar: true
          # keyEnabled: true
          supplied: "mp3, ogg"
        $("#jquery_jplayer_#{scope.id}").jPlayer "setMedia",
          mp3: newValue.url
          ogg: newValue.thumbnailUrl

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
        <a href="#">{{item || 'Search' | i18next }}</a>
      </div>
      <div class="search_input" ng-show="museum_search_visible">
        <input class="form-control" ng-model="item" placeholder="{{ "Search" | i18next }}" type="text" focus-me="museum_input_focus">
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

.directive 'canDragAndDrop', (errorProcessing, $i18next) ->
  restrict : 'A'
  scope:
    model: '=model'
    url: '@uploadTo'
    selector: '@selector'
    selector_dropzone: '@selectorDropzone'
  link : (scope, element, attrs) ->

    scope.$parent.loading_in_progress = false

    fileSizeMb = 50

    element = $("##{scope.selector}")
    dropzone = $("##{scope.selector_dropzone}")

    checkExtension = (object) ->
      extension = object.files[0].name.split('.').pop().toLowerCase()
      type = 'unsupported'
      type = 'image' if $.inArray(extension, gon.acceptable_extensions.image) != -1
      type = 'audio' if $.inArray(extension, gon.acceptable_extensions.audio) != -1
      type = 'video' if $.inArray(extension, gon.acceptable_extensions.video) != -1
      type

    correctFileSize = (object) ->
      object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024

    hide_drop_area = ->
      $(".progress").hide()
      setTimeout ->
        $("body").removeClass "in"
        scope.$parent.loading_in_progress = false
        scope.$parent.forbid_switch = false
      , 1000

    initiate_progress = ->
      scope.$parent.loading_in_progress = true
      scope.$parent.forbid_switch = true
      scope.$digest()
      $("body").addClass "in"
      $(".progress .progress-bar").css "width", 0 + "%"
      $(".progress").show()

    element.fileupload(
      url: scope.url
      dataType: "json"
      dropZone: dropzone
      change: (e, data) ->
        initiate_progress()
      drop: (e, data) ->
        initiate_progress()
        $.each data.files, (index, file) ->
          console.log "Dropped file: " + file.name
      add: (e, data) ->
        type = checkExtension(data)
        if type is 'image' || type is 'audio' || type is 'video'
          if correctFileSize(data)
            parent = scope.model._id
            parent = scope.model.stories[scope.$parent.current_museum.language]._id if type is 'audio' || type is 'video'
            data.formData = {
              type: type
              parent: parent
            }
            data.submit()
            if type is 'audio'
              scope.model.stories[scope.$parent.current_museum.language].audio = 'processing'
          else
            errorProcessing.addError $i18next 'File is bigger than 50mb'
            hide_drop_area()
        else
          errorProcessing.addError $i18next 'Unsupported file type'
          hide_drop_area()
      success: (result) ->
        for file in result
          if file.type is 'image'
            scope.model.images = [] unless scope.model.images?
            new_image = {}
            new_image.image = file
            if file.cover is true
              scope.$apply scope.model.cover = file
            scope.$apply scope.model.images.push new_image
          else if file.type is 'audio'
            scope.$apply scope.model.stories[scope.$parent.current_museum.language].audio = file
          else if file.type is 'video'
            scope.$apply scope.model.stories[scope.$parent.current_museum.language].video = file
          scope.$digest()
      error: (result, status, errorThrown) ->
        if errorThrown == 'abort'
          errorProcessing.addError $i18next 'Uploading aborted'
        else
          if result.status == 422
            response = jQuery.parseJSON(result.responseText)
            responseText = response.link[0]
            rrorProcessing.addError $i18next 'Error during file upload. Prototype error'
          else
            errorProcessing.addError $i18next 'Error during file upload. Prototype error'
        errorProcessing.addError $i18next 'Error during file upload. Prototype error'
        hide_drop_area()
      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        delimiter = 102.4
        speed = Math.round(data.bitrate / delimiter) / 10
        speed_text = "#{speed} Кб/с"
        if speed > 1000
          speed =  Math.round(speed / delimiter) / 10
          speed_text = "#{speed} Мб/с"
        $(".progress .progress-text").html "#{$i18next('&nbsp;&nbsp; Uploaded')} #{Math.round(data.loaded / 1024)} #{$i18next('Kb of')} #{Math.round(data.total / 1024)} #{$i18next('Kb, speed:')} #{speed_text}"
        $(".progress .progress-bar").css "width", progress + "%"
        if data.loaded is data.total
          scope.$parent.last_save_time = new Date()
          hide_drop_area()
    ).prop("disabled", not $.support.fileInput).parent().addClass (if $.support.fileInput then `undefined` else "disabled")

    scope.$watch 'url', (newValue, oldValue) ->
      if newValue
        element.fileupload "option", "url", newValue

.directive "buttonFileUpload", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    # upload = $("##{attr[selector]}")

    elem.click (e) ->
      e.preventDefault()
      elem = $ @
      parent = elem.parents('#drop_down, #museum_edit_dropdown')
      parent.find(':file').click()

.directive 'deleteMedia', (storySetValidation) ->
  restrict : 'A'
  scope:
    model: '=parent'
    media: '=media'
  link : (scope, element, attrs) ->
    element = $ element
    element.click (e) ->
      e.preventDefault()
      e.stopPropagation()
      elem   = $ @

      if confirm elem.data('confirm')
        $.ajax
          url: elem.data('link')
          type: elem.data('method')
          success: (data) ->
            if scope.media.type is 'image'
              for image, index in scope.model.images
                if image?
                  if image._id is data
                    if image.cover is true
                      scope.model.cover = {}
                    scope.model.images.splice index, 1
                    scope.$digest()
              if scope.model.images.length is 0 && scope.model.stories[scope.$parent.$parent.current_museum.language].status is 'published'
                storySetValidation.checkValidity {item: scope.model.stories[scope.$parent.$parent.current_museum.language], root: scope.model, field_type: 'story'}
            else if scope.media.type is 'audio'
              scope.model.audio = undefined
              #should
              scope.$digest()
              if scope.model.status is 'published'
                storySetValidation.checkValidity {item: scope.model, root: scope.$parent.$parent.active_exhibit, field_type: 'story'}
            scope.$parent.last_save_time = new Date()

.directive 'dragAndDropInit', ->
  link: (scope, element, attrs) ->

    $(document).bind 'drop dragover', (e) ->
      e.preventDefault()

    $(document).bind "dragover", (e) ->
      dropZone = $(".dropzone")
      doc      = $("body")
      timeout = scope.dropZoneTimeout
      unless timeout
        doc.addClass "in"
      else
        clearTimeout timeout
      found = false
      found_index = 0
      node = e.target
      loop
        if node is dropZone[0]
          found = true
          found_index = 0
          break
        else if node is dropZone[1]
          found = true
          found_index = 1
          break
        node = node.parentNode
        break unless node?
      if found
        dropZone[found_index].addClass "hover"
      else
        scope.dropZoneTimeout = setTimeout ->
          unless scope.loading_in_progress
            scope.dropZoneTimeout = null
            dropZone.removeClass "in hover"
            doc.removeClass "in"
        , 300

.directive 'dropDownEdit', ($timeout, $http) ->
  restrict: 'A'
  link: (scope, element, attrs) ->

    quiz_watcher     = null
    question_watcher = null
    name_watcher     = null
    answers_watcher  = null
    qr_code_watcher  = null

    scope.$watch 'active_exhibit.stories[current_museum.language]', (newValue, oldValue) ->
      quiz_watcher() if quiz_watcher?
      question_watcher() if question_watcher?
      name_watcher() if name_watcher?
      answers_watcher() if answers_watcher?
      qr_code_watcher() if qr_code_watcher?
      if newValue?
        quiz_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].quiz', (newValue, oldValue) ->
          if newValue?
            if newValue isnt oldValue
              if newValue.status is 'published'
                console.log 'pub'
                unless $("#story_quiz_enabled").is(':checked')
                  setTimeout ->
                    unless scope.quizform.$valid
                      setTimeout ->
                        $("#story_quiz_disabled").click()
                      , 10
                  , 100
                else
                  setTimeout ->
                    $("#story_quiz_enabled").click()
                  , 10
              else
                unless $("#story_quiz_disabled").is(':checked')
                  setTimeout ->
                    $("#story_quiz_disabled").click()
                  , 10

        question_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].quiz.question', (newValue, oldValue) ->
          if scope.quizform? && newValue isnt oldValue
            # console.log $scope.quizform
            if scope.quizform.$valid
              scope.mark_quiz_validity(scope.quizform.$valid)
            else
              setTimeout ->
                $("#story_quiz_disabled").click()
                scope.mark_quiz_validity(scope.quizform.$valid)
              , 10

        name_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].name', (newValue, oldValue) ->
          if newValue?
            form = $('#media form')
            if form.length > 0
              if scope.active_exhibit.stories[scope.current_museum.language].status is 'dummy'
                scope.active_exhibit.stories[scope.current_museum.language].status = 'passcode' if newValue
              else
                unless scope.new_item_creation
                  unless newValue 
                    scope.active_exhibit.stories[scope.current_museum.language].name = oldValue
                    scope.empty_name_error = true
                    setTimeout ->
                      scope.empty_name_error = false
                    , 1500
                # else
                #   if newValue and $scope.$parent.new_item_creation
                #     $rootScope.$broadcast 'save_new_exhibit'

        answers_watcher = scope.$watch ->
          if scope.active_exhibit.stories[scope.current_museum.language]?
            angular.toJson(scope.active_exhibit.stories[scope.current_museum.language].quiz.answers)
          else
            undefined
        , (newValue, oldValue) ->
          if newValue?
            if scope.quizform?
              if scope.quizform.$valid
                scope.mark_quiz_validity(scope.quizform.$valid)
              else
                setTimeout ->
                  $("#story_quiz_disabled").click()
                , 10

        # qr_code workaround
        qr_code_watcher =  scope.$watch 'active_exhibit.stories[current_museum.language]', (newValue, oldValue) ->
          if newValue
            unless scope.active_exhibit.stories[scope.current_museum.language].qr_code
              $http.get("#{scope.backend_url}/qr_code/#{scope.active_exhibit.stories[scope.current_museum.language]._id}").success (d) ->
                scope.active_exhibit.stories[scope.current_museum.language].qr_code = d

.directive 'openLightbox', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    parent   = element.parents('#drop_down, #museum_edit_dropdown')
    lightbox = parent.find('.lightbox_area')
    element.click ->
      if element.parents('li').hasClass('dragged')
        element.parents('li').removeClass('dragged')
      else
        lightbox.show()
        parent.height(lightbox.height() + 60) if lightbox.height() + 60 > parent.height()
        lightbox.find(".slider img.thumb.item_#{attrs.openLightbox}").click()
    true

.directive 'lightboxCropper', ($http, errorProcessing, $i18next) ->
  restrict: "E"
  replace: true
  transclude: true
  scope:
    model: '=model'
  template: """
    <div class="lightbox_area">
      <div class="explain_text">
        {{ "Select the preview area. Images won't crop. You can always return to this later on." | i18next }}
      </div>
      <button class="btn btn-warning apply_resize" type="button">{{ "Done" | i18next }}</button>
      <div class="content">
        <div class="preview">
          {{ "PREVIEW" | i18next }}
          <div class="mobile">
            <div class="image">
              <img src="{{model.images[active_image_index].image.url}}">
            </div>
          </div>
        </div>
        <div class="cropping_area">
          <img src="{{model.images[active_image_index].image.url}}">
        </div>
      </div>
      <div class="slider">
        <a class="left" href="#" ng-click="set_index(active_image_index - 1)">
          <i class="icon-angle-left"></i>
        </a>
        <ul class="images_sortable" sortable="model.images">
          <li class="thumb item_{{$index}} " ng-class="{'active':image.image.active, 'timestamp': image.mappings[model.language] >= 0}" ng-repeat="image in images">
            <img ng-click="set_index($index)" src="{{image.image.thumbnailUrl}}" />
            <a class="cover" ng-class="{'active':image.image.cover}" ng-click="make_cover($index)" ng-switch on="image.image.cover">
              <span ng-switch-when="true"><i class="icon-ok"></i> {{ "Cover" | i18next }}</span>
              <span ng-switch-default><i class="icon-ok"></i> {{ "Set cover" | i18next }}</span>
            </a>
          </li>
        </ul>
        <a class="right" href="#" ng-click="set_index(active_image_index + 1)">
          <i class="icon-angle-right"></i>
        </a>
      </div>
    </div>
  """
  controller: ($scope, $element, $attrs) ->

    $scope.set_index = (index) ->
      $scope.update_media $scope.active_image_index, ->
        $scope.active_image_index = index

    $scope.make_cover = (index) ->
      $scope.model.cover = $scope.model.images[index]
      for image in $scope.model.images
        if image.image._id isnt $scope.model.cover.image._id
          image.image.cover = false
        else
          image.image.cover = true
          setTimeout (->
            @.order = 0).bind(image.image)()
          , 500
        $http.put("#{$scope.$parent.backend_url}/media/#{image.image._id}", image.image).success (data) ->
          console.log 'ok'
        .error ->
          errorProcessing.addError $i18next 'Failed to set cover' 

    $scope.check_active_image = ->
      for image, index in $scope.model.images
        image.image.active = if index is $scope.active_image_index
          true
        else
          false
      
  link: (scope, element, attrs) ->
    element = $ element
    right   = element.find('a.right')
    left    = element.find('a.left')
    cropper = element.find('.cropping_area img')
    preview = element.find('.mobile .image img')
    done    = element.find('.apply_resize')
    parent  = element.parents('#drop_down, #museum_edit_dropdown')
    imageWidth  = 0
    imageHeight = 0
    max_height  = 330
    prev_height = 133
    prev_width  = 177
    selected    = {}
    bounds = []

    done.click ->
      scope.update_media scope.active_image_index
      # this line resizes parent back
      parent.attr('style', '')
      #####
      element.hide()
      false

    scope.update_media = (index, callback) ->
      $http.put("#{scope.$parent.backend_url}/resize_thumb/#{scope.model.images[scope.active_image_index].image._id}", selected).success (data) ->
        console.log  data
        angular.extend(scope.model.images[index].image, data)
        callback() if callback
        return true
      .error ->
        errorProcessing.addError $i18next 'Failed to update a thumbnail'
        return false

    showPreview = (coords) ->
      selected = coords
      rx = 177 / selected.w
      ry = 133 / selected.h
      preview.css
        width: Math.round(rx * bounds[0]) + "px"
        height: Math.round(ry * bounds[1]) + "px"
        marginLeft: "-" + Math.round(rx * selected.x) + "px"
        marginTop: "-" + Math.round(ry * selected.y) + "px"

    getSelection = (selection) ->
      # console.log selection
      result = [selection.x, selection.y, selection.x2, selection.y2] #array [ x, y, x2, y2 ]
      result

    cropper.on 'load', ->
      imageWidth = cropper.get(0).naturalWidth
      imageHeight = cropper.get(0).naturalHeight

      cropper.height max_height
      cropper.width imageWidth * ( max_height / imageHeight )

      preview.attr 'style', ""

      if scope.model.images[scope.active_image_index].image.selection
        selected = JSON.parse scope.model.images[scope.active_image_index].image.selection 
      else
        selected = {
          x: 0
          y: 0
          w: imageWidth
          h: imageHeight
          x2: imageWidth
          y2: imageHeight
        }

      options =
        boxWidth: cropper.width()
        boxHeight: cropper.height()
        aspectRatio: 4 / 3
        setSelect: getSelection(selected)
        trueSize: [imageWidth, imageHeight]
        onChange: showPreview
        onSelect: showPreview
      
      @jcrop.destroy() if @jcrop

      jcrop = null

      cropper.Jcrop options, -> 
        jcrop = @
        bounds = jcrop.getBounds()

      showPreview selected

      @jcrop = jcrop

    scope.$watch 'model.images', (newValue, oldValue) ->
      if newValue?
        if newValue.length > 0
          for image in newValue
            image.image.active = false
          newValue[0].active = true
          left.css({'opacity': 0})
          scope.active_image_index = 0

    scope.$watch 'active_image_index', (newValue, oldValue) ->
      if newValue?
        if newValue is -1
          newValue = 0
        left.css({'opacity': 255})
        right.css({'opacity': 255})
        if newValue is scope.model.images.length - 1
          right.css({'opacity': 0})
        if newValue is 0
          left.css({'opacity': 0})
        scope.check_active_image()      

    true

.directive 'sortable', ($http, errorProcessing, $i18next) ->
  restrict: 'A'
  scope:
    images: "=sortable"
  link: (scope, element, attrs) ->
    element  = $ element
    backend  = scope.$parent.backend_url || scope.$parent.$parent.backend_url
    element.disableSelection()
    element.sortable
      placeholder: "ui-state-highlight"
      cancel: ".timestamp"
      items: "li:not(.timestamp)"
      start: (event, ui) ->
        ui.item.data 'start', ui.item.index()
      update: ( event, ui ) ->
        elements = element.find('li')
        start    = ui.item.data('start')
        end      = ui.item.index()
        scope.images.splice(end, 0, scope.images.splice(start, 1)[0])
        if scope.images[end].order isnt end
          for image, index in scope.images
            image.order = index
            $http.put("#{backend}/media/#{image._id}", image).success (data) ->
              console.log 'ok'
            .error ->
              errorProcessing.addError $i18next 'Failed to update order' 
          scope.$apply()

.directive 'draggable', ($rootScope, $i18next, imageMappingHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    console.log scope
    element  = $ element

    weight_calc = imageMappingHelpers.weight_calc

    element.draggable
      axis: "x"
      containment: "parent"
      cursor: "pointer"
      drag: (event, ui) ->
        current_time = imageMappingHelpers.calc_timestamp(ui, false)
        image = scope.$parent.$parent.active_exhibit.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        if image?
          if image.mappings[$rootScope.lang].timestamp isnt current_time
            image.mappings[$rootScope.lang].timestamp = current_time
            scope.$parent.$parent.active_exhibit.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)
            for item, index in scope.$parent.$parent.active_exhibit.images
              item.image.order = index
            scope.$parent.$parent.$digest()
        true
      stop: ( event, ui ) ->
        console.log 'drag_stop'
        scope.$parent.$parent.active_exhibit.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)
        for item, index in scope.$parent.$parent.active_exhibit.images
          item.image.order = index
          imageMappingHelpers.update_image(item, scope.$parent.$parent.backend_url)

        scope.$parent.$parent.$digest()
        event.stopPropagation()

.directive 'draggableRevert', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    element.draggable
      revert: true
      cursor: "pointer"
      start: ( event, ui ) ->
        ui.helper.addClass('dragged')
        element.parents('.description').find('.timline_container').addClass('highlite')
      stop: ( event, ui ) ->
        element.parents('.description').find('.timline_container').removeClass('highlite')
        event.stopPropagation()

.directive 'droppable', ($http, errorProcessing, $i18next, imageMappingHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    element.droppable
      accept: '.dragable_image'
      out: ( event, ui ) ->
        element.removeClass 'can_drop'
      over: ( event, ui ) ->
        element.addClass 'can_drop'
      drop: ( event, ui ) -> 
        console.log 'dropped'
        element.removeClass 'can_drop'
        found     = false
        dropped   = ui.draggable
        droppedOn = $ @
        dropped.attr('style', '')
        seek_bar = element.find('.jp-seek-bar')
        jp_durat = element.find('.jp-duration')
        jp_play  = element.find('.jp-play')
        target_image =  scope.active_exhibit.images[dropped.data('array-index')]
        scope.active_exhibit.stories[scope.current_museum.language].mapped_images = [] unless scope.active_exhibit.stories[scope.current_museum.language].mapped_images?
        for image in scope.active_exhibit.stories[scope.current_museum.language].mapped_images
          if image.image._id is target_image.image._id
            found = true
            break       
        unless found
          scope.active_exhibit.stories[scope.current_museum.language].mapped_images.push target_image 
          target_image.mappings[dropped.data('lang')] = {}
          target_image.mappings[dropped.data('lang')].timestamp = imageMappingHelpers.calc_timestamp(ui, true)
          target_image.mappings[dropped.data('lang')].language  = dropped.data('lang')
          target_image.mappings[dropped.data('lang')].media     = target_image.image._id
          scope.active_exhibit.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)
          for item, index in scope.active_exhibit.images
            item.image.order = index
            imageMappingHelpers.update_image(item, scope.backend_url)

          imageMappingHelpers.create_mapping(target_image, scope.backend_url)

          scope.$digest()

          scope.recalculate_marker_positions(scope.active_exhibit.stories[scope.current_museum.language], element)

    true

.directive 'switchToggle', ($timeout, $i18next) ->
  restrict: 'A'
  controller:  ($scope, $rootScope, $element, $attrs, $http) ->
    selector = $attrs['quizSwitch']
    $scope.quiz_state = (form, item) ->
      $scope.mark_quiz_validity(form.$valid)
      if form.$valid
        $timeout ->
          $http.put("#{$scope.backend_url}/quiz/#{item._id}", item).success (data) ->
            console.log data
          .error ->
            errorProcessing.addError $i18next 'Failed to save quiz state'
          true
        , 0
      else
        setTimeout ->
          $("##{selector}_disabled").click()
        , 300     
      true

    $scope.mark_quiz_validity = (valid) ->
      form = $("##{selector} form")
      if valid
        form.removeClass 'has_error'
      else
        form.addClass 'has_error'
        question = form.find('#story_quiz_attributes_question, #museum_story_quiz_attributes_question')
        question.addClass 'ng-invalid' if question.val() is ''
      true

  link: (scope, element, attrs) ->
    selector = attrs['quizSwitch']
    $("##{selector}_enabled, ##{selector}_disabled").change ->
      elem = $ @
      if elem.attr('id') is "#{selector}_enabled"
        $("label[for=#{selector}_enabled]").text($i18next('Enabled'))
        $("label[for=#{selector}_disabled]").text($i18next('Disable'))
        true
      else
        $("label[for=#{selector}_disabled]").text($i18next('Disabled'))
        $("label[for=#{selector}_enabled]").text($i18next('Enable'))
        true

.directive 'errorNotification', (errorProcessing) ->
  restrict: "E"
  replace: true
  transclude: true
  template: """
    <div class="error_notifications" ng-hide="errors.length == 0">
      <div class="alert alert-danger" ng-repeat="error in errors">
        {{error.error}}
        <a class="close" href="#" ng-click="dismiss_error($index)" >&times;</a>
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.errors = errorProcessing.getErrors()

    scope.dismiss_error = (index) ->
      errorProcessing.deleteError(index)

    scope.$on 'new_error', (event, errors) ->
      scope.errors = errors

.directive 'scrollspyInit', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    opener = {
      target: $('.museum_edit_opener')
    }
    $("ul.exhibits").scrollspy
      min: 50
      max: 99999
      onEnter: (element, position) ->
        $(".float_menu").addClass "navbar-fixed-top"
        $(".navigation").addClass "bottom-padding"
        $(".to_top").show()

      onLeave: (element, position) ->
        $(".float_menu").removeClass "navbar-fixed-top"
        $(".navigation").removeClass "bottom-padding"
        $(".to_top").hide() unless $(".to_top").hasClass 'has_position'

      onTick: (position,state,enters,leaves) ->
        if scope.museum_edit_dropdown_opened
          scope.show_museum_edit(opener)

.directive 'toTop', (errorProcessing) ->
  restrict: "E"
  replace: true
  transclude: true
  template: """
    <div class="to_top">
      <div class="to_top_panel">
        <div class="to_top_button" title="Наверх">
          <span class="arrow"><i class="icon-long-arrow-up"></i></span>
        </div>
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    element = $ element

    element.click ->
      if element.hasClass 'has_position'
        element.removeClass 'has_position'
        pos = element.data('scrollPosition')
        element.find('.arrow i').removeClass("icon-long-arrow-down").addClass("icon-long-arrow-up")
        $.scrollTo pos, 0
      else
        element.addClass 'has_position'
        pos = $(document).scrollTop()
        element.data('scrollPosition', pos)
        element.find('.arrow i').addClass("icon-long-arrow-down").removeClass("icon-long-arrow-up")
        $.scrollTo 0, 0