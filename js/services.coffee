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
    if scope.item.long_description? && scope.item.audio && scope.root.number? && scope.root.images.length >= 1
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

  markValid: (scope) ->
    console.log 'valid'
    scope.root.invalid = false


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
