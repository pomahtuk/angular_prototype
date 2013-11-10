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
        if (scope.item.images == null) {
          scope.item.images = [];
        }
        if (scope.item.long_description == null) {
          scope.item.long_description = '';
        }
        if (scope.item.long_description.length !== 0 && scope.item.audio && (scope.root.number != null) && scope.root.images.length >= 1) {
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
        } else {
          return $rootScope.$broadcast('changes_to_save', scope);
        }
      },
      markValid: function(scope) {
        console.log('valid');
        return scope.root.invalid = false;
      }
    };
  }).service("imageMappingHelpers", function($rootScope, errorProcessing, $http, $i18next) {
    var weight_calc;
    weight_calc = function(item) {
      var weight;
      weight = 0;
      weight += item.image.order;
      if (item.mappings[$rootScope.lang] != null) {
        weight -= 100;
      }
      return weight;
    };
    return {
      sort_weight_func: function(a, b) {
        if (weight_calc(a) > weight_calc(b)) {
          return 1;
        } else if (weight_calc(a) < weight_calc(b)) {
          return -1;
        } else {
          return 0;
        }
      },
      sort_time_func: function(a, b) {
        if ((a.mappings[$rootScope.lang] != null) && (b.mappings[$rootScope.lang] != null)) {
          if (a.mappings[$rootScope.lang].timestamp >= 0) {
            if (a.mappings[$rootScope.lang].timestamp > b.mappings[$rootScope.lang].timestamp) {
              return 1;
            } else if (a.mappings[$rootScope.lang].timestamp < b.mappings[$rootScope.lang].timestamp) {
              return -1;
            }
          }
        }
        return 0;
      },
      calc_timestamp: function(ui, initial) {
        var container_width, current_position, current_time, duration, jp_durat, jp_play, pixel_sec_weight, seek_bar, total_seconds;
        if (initial == null) {
          initial = false;
        }
        seek_bar = $('.jp-seek-bar:visible');
        jp_durat = $('.jp-duration:visible');
        jp_play = $('.jp-play:visible');
        if (initial) {
          current_position = ui.offset.left - seek_bar.offset().left;
        } else {
          current_position = ui.position.left - jp_play.width();
        }
        container_width = seek_bar.width() - 15;
        duration = jp_durat.text();
        total_seconds = parseInt(duration.split(':')[1], 10) + parseInt(duration.split(':')[0], 10) * 60;
        pixel_sec_weight = total_seconds / container_width;
        current_time = Math.round(current_position * pixel_sec_weight);
        return current_time;
      },
      update_image: function(image, backend_url) {
        $http.put("" + backend_url + "/media/" + image.image._id, image.image).success(function(data) {
          var mapping;
          console.log('ok');
          if (image.mappings[$rootScope.lang] != null) {
            mapping = image.mappings[$rootScope.lang];
            return $http.put("" + backend_url + "/media_mapping/" + mapping._id, mapping).success(function(data) {
              return console.log('ok');
            }).error(function() {
              return errorProcessing.addError($i18next('Failed to set timestamp'));
            });
          }
        }).error(function() {
          return errorProcessing.addError($i18next('Failed to set timestamp'));
        });
        return true;
      },
      create_mapping: function(image, backend_url) {
        console.log('creating');
        $http.post("" + backend_url + "/media_mapping/", image.mappings[$rootScope.lang]).success(function(data) {
          image.mappings[$rootScope.lang] = data;
          return console.log('ok', data);
        }).error(function() {
          return errorProcessing.addError($i18next('Failed to set timestamp'));
        });
        return true;
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
