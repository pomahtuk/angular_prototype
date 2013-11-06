(function() {
  "use strict";
  angular.module("Museum.filters", []).filter("numstring", function() {
    return function(input) {
      return String.fromCharCode(input + 97).toUpperCase();
    };
  }).filter("timerepr", function() {
    return function(input) {
      var minutes, seconds, source_seconds;
      source_seconds = parseInt(input, 10);
      if (!isNaN(source_seconds)) {
        minutes = Math.floor(source_seconds / 60);
        if (minutes.toString().length === 1) {
          minutes = "0" + minutes;
        }
        seconds = source_seconds - minutes * 60;
        if (seconds.toString().length === 1) {
          seconds = "0" + seconds;
        }
        return "" + minutes + ":" + seconds;
      }
    };
  });

}).call(this);
