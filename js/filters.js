(function() {
  "use strict";
  angular.module("Museum.filters", []).filter("interpolate", [
    "version", function(version) {
      return function(text) {
        return String(text).replace(/\%VERSION\%/g, version);
      };
    }
  ]);

}).call(this);
