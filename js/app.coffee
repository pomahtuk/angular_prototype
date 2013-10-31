"use strict"

configureHttp = (httpp) ->
  commonHeaders = httpp.defaults.headers.common
  commonHeaders['Accept']       = 'application/json'
  commonHeaders['X-CSRF-TOKEN'] = $('meta[name="csrf-token"]').attr('content')

# Declare app level module which depends on filters, and services
@app = angular.module("Museum", ["Museum.filters", "Museum.services", "Museum.directives", "Museum.controllers", "ui.bootstrap", "ui.bootstrap.tpls", "angularLocalStorage", "ngProgress", "jm.i18next"])
.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    template: " "
    controller: "IndexController"
  .when "/:museum_id",
    template: " "
    controller: "IndexController"
  $locationProvider.html5Mode true
  $locationProvider.hashPrefix '!'
]

angular.module("jm.i18next").config ($i18nextProvider) ->
  $i18nextProvider.options =
    # lng: 'ru'
    useCookie: true
    useLocalStorage: false
    resGetPath: "../locales/__lng__/__ns__.json"


# @app.config (RestangularProvider) ->
#   RestangularProvider.setBaseUrl('http://192.168.216.128:3000/')