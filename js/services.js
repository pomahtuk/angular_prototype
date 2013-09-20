(function() {
  "use strict";
  angular.module("Museum.services", []).service("sharedProperties", function($rootScope) {
    var property;
    property = {};
    return {
      getProperty: function(name) {
        return property[name];
      },
      setProperty: function(name, value) {
        property[name] = value;
        return $rootScope.$broadcast("exhibitChange");
      }
    };
  });

}).call(this);
