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
.directive "switchpubitem", ($timeout, storySetValidation) ->
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
        <div class="extra" ng-switch on="item[field]">
          <i class="icon-globe"></i>
        </div>
        <span ng-switch-when="passcode">Publish</span>
        <span ng-switch-when="published">Published</span>
      </button>
      <button class="btn btn-default" ng-class="{'active btn-primary': item.status == 'passcode' }" ng-click="item.status = 'passcode'; status_process()" type="button" ng-switch on="item[field]">
        <div class="extra" ng-switch on="item[field]">
          <i class="icon-lock"></i>
        </div>
        <span ng-switch-when="passcode">Private</span>
        <span ng-switch-when="published">Make private</span>
      </button>
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
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown" type="button">
        <div class="extra_right" ng-switch on="item[field]">
          <i class="icon-globe" ng-switch-when="published" ></i>
          <i class="icon-lock" ng-switch-when="passcode" ></i>
        </div>
        <span class="caret"></span></button>
      <ul class="dropdown-menu pull-left" role="menu" >
        Who can see it in mobile application
        <li class="divider"></li>
        <li  ng-click="item[field] = 'published'; status_process()">
          <span class="check"><i ng-show="item[field] == 'published'" class="icon-ok"></i></span>
          <i class="icon-globe"></i> Everyone
        </li>
        <li ng-click="item[field] = 'passcode'; status_process()">
          <span class="check"><i ng-show="item[field] == 'passcode'" class="icon-ok"></i></span>
          <i class="icon-lock"></i> Only users who have passcode
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
      <label class="col-xs-2 control-label" for="museum_language_select">Language</label>
      <div class="help ng-scope" popover="Select language" popover-animation="true" popover-placement="bottom" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-xs-6 triggered">
        <select class="form-control" ng-model="museum.language">
          <option disabled="" selected="" value="dummy">Select a new language</option>
          <option value="{{translation}}" ng-repeat="(translation, lang) in $parent.$parent.translations">{{lang}}</option>
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
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">{{title}}</label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      {{active_exhibit}}
      <span class="empty_name_error {{field}}">can't be empty</span>
      <div class="col-xs-7 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-7 triggered">
        <input type="hidden" id="original_{{id}}" ng-model="item[field]" required>
        <input type="text" class="form-control" id="{{id}}" value="{{item[field]}}" placeholder="{{placeholder}}">
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
      if $scope.item[$scope.field] isnt $scope.oldValue
        $scope.status = 'progress'
        $scope.$digest()
        if $scope.$parent.new_item_creation and $scope.field is 'name'
          if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0 
            $rootScope.$broadcast 'save_new_exhibit'
            return true
        $rootScope.$broadcast 'changes_to_save', $scope
  link: (scope, element, attrs) ->
    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    control = element.find('.triggered > .form-control')

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show()
      control.val scope.item[scope.field]
      control.focus()
      control.removeClass 'ng-invalid'

    element.find('.triggered > .form-control').blur ->  
      elem = $ @
      unless scope.$parent.new_item_creation && scope.field is 'number'
        $timeout ->
          scope.item[scope.field] = elem.val()
          scope.$digest()
          scope.status_process()
        , 0, false
      if elem.val().length > 0
        triggered.hide()
        trigger.show()
      else
        elem.addClass 'ng-invalid'
        if scope.field is 'name' && scope.item.status isnt 'dummy'
          $timeout ->
            elem.val scope.oldValue
            scope.item[scope.field] = scope.oldValue
            scope.$digest()
            # element.find('.error_text').show()
            # setTimeout ->
            #   element.find('.error_text').hide()
            # , 2000
            triggered.hide()
            trigger.show()
            scope.status_process()
          , 0, false

    element.find('.triggered > .form-control').keyup ->  
      elem = $ @
      val = elem.val()
      if val is '' and scope.field is 'name'
        $timeout ->
          elem.val scope.oldValue
          scope.item[scope.field] = scope.oldValue
          scope.$digest()
          element.find('.error_text').show()
          setTimeout ->
            element.find('.error_text').hide()
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
        trigger.hide()
        triggered.show()
        control.val ''
        if scope.filed is 'name'
          triggered.find('.form-control').focus()
      else
        if scope.$parent.element_switch is true
          trigger.show()
          triggered.hide()

    true

.directive "placeholdertextarea", ($timeout) ->
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
        <span class="label label-danger" ng-show="field == 'long_description' && item[field].length == 0">Fill to publish</span>
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
    scope.length_text = "осталось символов: #{scope.max_length}"

    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    sumbols_left = element.find('.sumbols_left')
    control = triggered.children('.content_editable')

    element.find('div.placeholder').click ->
      trigger.hide()
      triggered.show()
      control.text scope.item[scope.field]
      control.focus()
      scope.length_text = "осталось символов: #{scope.max_length - control.text().length - 1}"
      sumbols_left.show()

    control.blur ->
      elem = $ @
      $timeout ->
        scope.item[scope.field] = elem.text()
        scope.$digest()
        scope.status_process()
      , 0, false
      if elem.text() isnt ''
        triggered.hide()
        trigger.show()
        sumbols_left.hide()
        scope.status_process()

    control.keyup (e) ->
      elem = $ @
      value = elem.text()
      if value.length >= scope.max_length
        elem.text value.substr(0, scope.max_length-1)
      scope.length_text = "осталось символов: #{scope.max_length - value.length - 1}"
      scope.$digest()

    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.length_text = "осталось символов: 255"
        control.text ''
        trigger.hide()
        triggered.show()
      else
        scope.max_length ||= 255
        # scope.length_text = "осталось символов: #{scope.max_length - newValue.length - 1}"
        # if newValue.length >= scope.max_length
        #   scope.item[scope.field] = newValue.substr(0, scope.max_length-1)
        if scope.$parent.element_switch is true
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
    <div class="form-group textfield string optional checkbox_added">
      <label class="string optional control-label col-xs-2" for="{{id}}">
        <span class='correct_answer_indicator'>correct</span>
      </label>
      <input class="coorect_answer_radio" name="correct_answer" type="radio" value="{{item._id}}" ng-model="checked" ng-click="check_items(item)">
      <div class="col-xs-5 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-5 triggered">
        <input class="form-control" id="{{id}}" name="{{item._id}}" placeholder="Enter option" type="text" ng-model="item[field]" required>
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
    parent: '=parent'
  template: """
    <div class="form-group audio">
      <label class="col-xs-2 control-label" for="audio">
        Audio
        <span class="label label-danger" ng-show="edit_mode">Fill to publish</span>
      </label>
      <div class="help">
        <i class="icon-question-sign" data-content="Supplementary field. You may indicate the exhibit’s inventory, or any other number, that will help you to identify the exhibit within your own internal information system." data-placement="bottom"></i>
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
        <span>&nbsp;&nbsp;processing audio</span>
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
        # console.log newValue
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

.directive 'canDragAndDrop', ->
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
            console.log 'error: file size'
            hide_drop_area()
        else
          console.log 'error: file type'
          hide_drop_area()
      success: (result) ->
        console.log result, scope.model
        for file in result
          if file.type is 'image'
            scope.model.images = [] unless scope.model.images?
            scope.$apply scope.model.images.push file
          else if file.type is 'audio'
            scope.$apply scope.model.stories[scope.$parent.current_museum.language].audio = file
          else if file.type is 'video'
            scope.$apply scope.model.stories[scope.$parent.current_museum.language].video = file
          scope.$digest()
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
        delimiter = 102.4
        speed = Math.round(data.bitrate / delimiter) / 10
        speed_text = "#{speed} Кб/с"
        if speed > 1000
          speed =  Math.round(speed / delimiter) / 10
          speed_text = "#{speed} Мб/с"
        $(".progress .progress-text").html "&nbsp;&nbsp; Загружено #{Math.round(data.loaded / 1024)} Кб из #{Math.round(data.total / 1024)} Кб, скорость: #{speed_text}"
        $(".progress .progress-bar").css "width", progress + "%"
        if data.loaded is data.total
          scope.$parent.last_save_time = new Date()
          hide_drop_area()
    ).prop("disabled", not $.support.fileInput).parent().addClass (if $.support.fileInput then `undefined` else "disabled")

    scope.$watch 'url', (newValue, oldValue) ->
      # console.log newValue
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

.directive 'deleteMedia', ->
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
                    scope.$apply scope.model.images.splice index, 1
                    scope.$digest()
            else if scope.media.type is 'audio'
              scope.model.audio = undefined
              scope.$digest()
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

    # console.log scope
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
                    $('.empty_name_error.name').show()
                    setTimeout ->
                      $('.empty_name_error.name').hide()
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
      lightbox.show()
      parent.height(lightbox.height() + 60) if lightbox.height() + 60 > parent.height()
      lightbox.find(".slider img.thumb.item_#{attrs.openLightbox}").click()
    true

.directive 'lightboxCropper', ($http) ->
  restrict: "E"
  replace: true
  transclude: true
  scope:
    model: '=model'
  template: """
    <div class="lightbox_area">
      <div class="explain_text">
        Select the preview area. Images won't crop. You can always return to this later on.
      </div>
      <button class="btn btn-warning apply_resize" type="button">Done</button>
      <div class="content">
        <div class="preview">
          PREVIEW
          <div class="exhibit">
            <div class="image">
              <img src="{{model.images[active_image_index].url}}">
            </div>
            <div class="description">
              <h4>
                {{model.number}} {{model.stories[$parent.current_museum.language].name}}
              </h4>
            </div>
          </div>
        </div>
        <div class="cropping_area">
          <img src="{{model.images[active_image_index].url}}">
        </div>
      </div>
      <div class="slider">
        <a class="left" href="#" ng-click="set_index(active_imge_index - 1)">
          <i class="icon-angle-left"></i>
        </a>
        <img class="thumb item_{{$index}}" ng-click="set_index($index)" ng-class="{'active':image.active}" src="{{image.thumbnailUrl}}" ng-repeat="image in model.images">
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
        console.log $scope.active_image_index, index

    $scope.check_active_image = ->
      for image, index in $scope.model.images
        image.active = if index is $scope.active_image_index
          true
        else
          false
      
  link: (scope, element, attrs) ->
    element = $ element
    right   = element.find('a.right')
    left    = element.find('a.left')
    cropper = element.find('.cropping_area img')
    preview = element.find('.exhibit .image img')
    done    = element.find('.apply_resize')
    parent  = element.parents('#drop_down, #museum_edit_dropdown')
    imageWidth  = 0
    imageHeight = 0
    max_height  = 330
    prev_height = 150
    prev_width  = 200
    selected    = {}
    bounds = []

    done.click ->
      image = scope.model.images[scope.active_image_index]
      scope.update_media scope.active_image_index, ->
        images =  scope.model.images
        images.sort (a, b) ->
          a = new Date(a.updated)
          b = new Date(b.updated)
          if a < b 
            1 
          else
            if a > b 
              -1 
            else 
              0
        scope.model.images = images
        if scope.model.type is 'exhibit' 
          $('ul.exhibits li.exhibit.active').find('.image img').attr 'src', image.thumbnailUrl
        parent.attr('style', '')
      element.hide()
      false

    scope.update_media = (index, callback) ->
      $http.put("#{scope.$parent.backend_url}/resize_thumb/#{scope.model.images[scope.active_image_index]._id}", selected).success (data) ->
        console.log  data
        scope.model.images[index] = data
        # scope.$digest()
        callback() if callback
        return true
      .error ->
        errorProcessing.addError 'Failed to update a thumbnail'
        return false

    showPreview = (coords) ->
      selected = coords
      rx = 200 / selected.w
      ry = 150 / selected.h
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

      if scope.model.images[scope.active_image_index].selection
        selected = JSON.parse scope.model.images[scope.active_image_index].selection 
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
            image.active = false
          newValue[0].active = true
          left.css({'opacity': 0})
          scope.active_image_index = 0

    scope.$watch 'active_image_index', (newValue, oldValue) ->
      if newValue?
        left.css({'opacity': 255})
        right.css({'opacity': 255})
        if newValue is scope.model.images.length - 1
          right.css({'opacity': 0})
        if newValue is 0
          left.css({'opacity': 0})
        scope.check_active_image()      

    true

.directive 'switchToggle', ($timeout) ->
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
            errorProcessing.addError 'Failed to save quiz state'
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
        $("label[for=#{selector}_enabled]").text('Enabled')
        $("label[for=#{selector}_disabled]").text('Disable')
        true
      else
        $("label[for=#{selector}_disabled]").text('Disabled')
        $("label[for=#{selector}_enabled]").text('Enable')
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