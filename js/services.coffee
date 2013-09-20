"use strict"

# Services 

angular.module("Museum.services", []).service "sharedProperties", ($rootScope) ->
  property = {}
  getProperty: (name) ->
    property[name]

  setProperty: (name, value) ->
    property[name] = value
    $rootScope.$broadcast "exhibitChange"