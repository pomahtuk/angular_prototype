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
  }).service("storySetValidation", function($rootScope, $timeout) {
    return {
      checkValidity: function(scope) {
        if ((scope.item.long_description != null) && scope.item.audio && (scope.root.number != null) && scope.root.images.length >= 1) {
          this.markValid(scope);
          return $rootScope.$broadcast('changes_to_save', scope);
        } else {
          return this.markInvalid(scope);
        }
      },
      markInvalid: function(scope) {
        console.log('invalid');
        if (scope.item.status === 'published') {
          scope.root.invalid = true;
          return $timeout(function() {
            scope.item.status = 'passcode';
            if (scope.$digest != null) {
              scope.$digest();
            }
            return $rootScope.$broadcast('changes_to_save', scope);
          }, 100);
        }
      },
      markValid: function(scope) {
        console.log('valid');
        return scope.root.invalid = false;
      }
    };
  }).service("errorProcessing", function($rootScope, $timeout) {
    return {
      errors: [],
      addError: function(error) {
        var error_object;
        error_object = {
          error: error
        };
        this.errors.push(error_object);
        return $rootScope.$broadcast('new_error', this.errors);
      },
      getErrors: function() {
        return this.errors;
      },
      clearErrors: function() {
        this.errors = [];
        return $rootScope.$broadcast('new_error', this.errors);
      },
      deleteError: function(index) {
        this.errors.splice(index, 1);
        return $rootScope.$broadcast('new_error', this.errors);
      }
    };
  });

}).call(this);
