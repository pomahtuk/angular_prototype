(function() {
  "use strict";
  var configureHttp;

  configureHttp = function(httpp) {
    var commonHeaders;
    commonHeaders = httpp.defaults.headers.common;
    commonHeaders['Accept'] = 'application/json';
    return commonHeaders['X-CSRF-TOKEN'] = $('meta[name="csrf-token"]').attr('content');
  };

  this.app = angular.module("Museum", ["Museum.filters", "Museum.services", "Museum.directives", "Museum.controllers", "ui.bootstrap", "ui.bootstrap.tpls", "angularLocalStorage"]);

  this.app.config([
    '$httpProvider', function($httpProvider, httpConfig) {
      return configureHttp($httpProvider);
    }
  ]);

}).call(this);
