"use strict"

# Services 

angular.module("Museum.services", []).service "sharedProperties", ($rootScope) ->
  property = {}
  getProperty: (name) ->
    property[name]

  setProperty: (name, value) ->
    property[name] = value
    $rootScope.$broadcast "exhibitChange"

.service "storySetValidation", ($rootScope, $timeout) ->
  checkValidity: (scope) ->
    scope.item.images = [] unless scope.item.images?
    scope.item.long_description = '' unless scope.item.long_description?
    if scope.item.long_description.length isnt 0 && scope.item.audio && scope.root.number? && scope.root.images.length >= 1
      @markValid scope
      $rootScope.$broadcast 'changes_to_save', scope
    else
      @markInvalid scope

  markInvalid: (scope) ->
    console.log 'invalid'

    if scope.item.status is 'published'
      scope.root.invalid = true
      $timeout ->
        scope.item.status = 'passcode'
        scope.$digest() if scope.$digest?
        $rootScope.$broadcast 'changes_to_save', scope
      , 100
    else
      $rootScope.$broadcast 'changes_to_save', scope

  markValid: (scope) ->
    console.log 'valid'
    scope.root.invalid = false

.service "imageMappingHelpers", ($rootScope, errorProcessing, $http, $i18next) ->

  weight_calc = (item) ->
    weight = 0
    weight += item.image.order
    weight -= 100 if item.mappings[$rootScope.lang]?
    return weight

  sort_weight_func: (a, b) ->
    if weight_calc(a) > weight_calc(b)
      return 1
    else if weight_calc(a) < weight_calc(b)
      return -1
    else
      return 0

  sort_time_func: (a, b) ->
    if a.mappings[$rootScope.lang]? and b.mappings[$rootScope.lang]?
      if a.mappings[$rootScope.lang].timestamp >= 0
        if a.mappings[$rootScope.lang].timestamp > b.mappings[$rootScope.lang].timestamp
          return 1
        else if a.mappings[$rootScope.lang].timestamp < b.mappings[$rootScope.lang].timestamp
          return -1
    return 0

  calc_timestamp: (ui, initial = false) ->
    seek_bar = $('.jp-seek-bar:visible')
    jp_durat = $('.jp-duration:visible')
    jp_play  = $('.jp-play:visible')
    if initial
      current_position = ui.offset.left - seek_bar.offset().left
    else
      current_position = ui.position.left - jp_play.width()
    container_width  = seek_bar.width() - 15
    duration         = jp_durat.text()
    total_seconds    = parseInt(duration.split(':')[1], 10) + parseInt(duration.split(':')[0], 10) * 60
    pixel_sec_weight = total_seconds / container_width
    current_time = Math.round current_position * pixel_sec_weight
    current_time

  update_image: (image, backend_url) ->
    $http.put("#{backend_url}/media/#{image.image._id}", image.image).success (data) ->
      console.log 'ok'
      if image.mappings[$rootScope.lang]?
        mapping = image.mappings[$rootScope.lang]
        $http.put("#{backend_url}/media_mapping/#{mapping._id}", mapping).success (data) ->
          console.log 'ok'
        .error ->
          errorProcessing.addError $i18next 'Failed to set timestamp'
    .error ->
      errorProcessing.addError $i18next 'Failed to set timestamp'
    true

  create_mapping: (image, backend_url) ->
    console.log 'creating'
    # image.mappings[$rootScope.lang].media = image.image._id
    $http.post("#{backend_url}/media_mapping/", image.mappings[$rootScope.lang]).success (data) ->
      image.mappings[$rootScope.lang] = data
      console.log 'ok', data
    .error ->
      errorProcessing.addError $i18next 'Failed to set timestamp'
    true


.service "errorProcessing", ($rootScope, $timeout) ->
  errors: []
  addError: (error) ->
    error_object = 
      error: error
    @errors.push error_object
    $rootScope.$broadcast 'new_error', @errors
  getErrors: ->
    return @errors
  clearErrors: ->
    @errors = []
    $rootScope.$broadcast 'new_error', @errors
  deleteError: (index) ->
    @errors.splice(index, 1)
    $rootScope.$broadcast 'new_error', @errors
