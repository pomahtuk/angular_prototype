"use strict"

# Filters 
angular.module("Museum.filters", []).filter "interpolate", ["version", (version) ->
  (text) ->
    String(text).replace /\%VERSION\%/g, version
]