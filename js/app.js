(function() {
  "use strict";
  var configureHttp;

  configureHttp = function(httpp) {
    var commonHeaders;
    commonHeaders = httpp.defaults.headers.common;
    commonHeaders['Accept'] = 'application/json';
    return commonHeaders['X-CSRF-TOKEN'] = $('meta[name="csrf-token"]').attr('content');
  };

  this.app = angular.module("Museum", ["Museum.filters", "Museum.services", "Museum.directives", "Museum.controllers", "ui.bootstrap", "ui.bootstrap.tpls", "angularLocalStorage", "ngProgress", "jm.i18next"]).config([
    "$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
      $routeProvider.when("/", {
        template: " ",
        controller: "IndexController"
      }).when("/:museum_id", {
        template: " ",
        controller: "IndexController"
      });
      $locationProvider.html5Mode(true);
      return $locationProvider.hashPrefix('!');
    }
  ]);

  angular.module("jm.i18next").config(function($i18nextProvider) {
    return $i18nextProvider.options = {
      useCookie: true,
      useLocalStorage: false,
      resGetPath: "../locales/__lng__/__ns__.json"
    };
  });

}).call(this);
