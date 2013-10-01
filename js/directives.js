(function() {
  "use strict";
  angular.module("Museum.directives", []).directive("ngBlur", function() {
    return function(scope, elem, attrs) {
      return elem.bind("blur", function() {
        return scope.$apply(attrs.ngBlur);
      });
    };
  }).directive("ngFocus", function($timeout) {
    return function(scope, elem, attrs) {
      return scope.$watch(attrs.ngFocus, function(newval) {
        if (newval) {
          return $timeout((function() {
            return elem[0].focus();
          }), 0, false);
        }
      });
    };
  }).directive("focusMe", function($timeout, $parse) {
    return {
      link: function(scope, element, attrs) {
        var model;
        model = $parse(attrs.focusMe);
        scope.$watch(model, function(value) {
          if (value === true) {
            return $timeout(function() {
              return element[0].focus();
            });
          }
        });
        return element.bind("blur", function() {
          return scope.$apply(model.assign(scope, false));
        });
      }
    };
  }).directive("stopEvent", function() {
    return {
      link: function(scope, element, attr) {
        return element.bind(attr.stopEvent, function(e) {
          return e.stopPropagation();
        });
      }
    };
  }).directive("resizer", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        elem.focus(function() {
          return elem.animate({
            'width': '+=150'
          }, 200);
        });
        return elem.blur(function() {
          return elem.animate({
            'width': '-=150'
          }, 200);
        });
      }
    };
  }).directive("toggleMenu", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        return elem.click(function() {
          $('.navigation').toggleClass('navbar-fixed-top');
          $('.museum_navigation_menu').slideToggle(300);
          $('body').toggleClass('fixed_navbar');
          return setTimeout(function() {
            return $.scrollTo(0, 0);
          }, 0);
        });
      }
    };
  }).directive("toggleFilters", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        return elem.click(function() {
          $('.filters_bar').slideToggle(200);
          return setTimeout(function() {
            return $('body').toggleClass('filers');
          }, 100);
        });
      }
    };
  }).directive('postRender', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        if (scope.$last) {
          $timeout(scope.grid, 0);
        }
        return true;
      }
    };
  }).directive("switchpubitem", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        provider: '=ngProvider',
        current_museum: '=ngMuseum',
        trans: '=translations'
      },
      template: "<div class=\"btn-group pull-right item_publish_settings\">\n  <button class=\"btn btn-success dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\" ng-switch on=\"item.stories[current_museum.language].status\">\n    <div class=\"extra\" ng-switch on=\"item.stories[current_museum.language].status\">\n      <i class=\"icon-globe\" ng-switch-when=\"published\" ></i>\n      <i class=\"icon-user\" ng-switch-when=\"passcode\" ></i>\n    </div>\n    <span ng-switch-when=\"passcode\">Publish</span>\n    <span ng-switch-when=\"published\">Published</span>\n    <span class=\"caret\"></span>\n  </button>\n  <ul class=\"dropdown-menu status-select-dropdown\" role=\"menu\">\n    Who can see it in mobile application\n    <li class=\"divider\"></li>\n    <li ng-click=\"item.stories[current_museum.language].status = 'published'\">\n      <i class=\"icon-globe\"></i> Everyone\n      <span class=\"check\" ng-show=\"item.stories[current_museum.language].status == 'published'\">✓</span>\n    </li>\n    <li  ng-click=\"item.stories[current_museum.language].status = 'passcode'\">\n      <i class=\"icon-user\"></i> Only users who have passcode\n      <span class=\"check\" ng-show=\"item.stories[current_museum.language].status == 'passcode'\">✓</span>\n      <div class=\"limited-pass-hint hidden\">\n        <div class=\"limited-pass\">\n          {{provider.passcode}}\n        </div>\n        <a href=\"{{provider.passcode_edit_link}}\" target=\"_blank\">Edit</a>\n      </div>\n    </li>\n    <li class=\"divider\"></li>\n    <li class=\"other_list\">\n      <span class=\"other_lang\" ng-click=\"hidden_list=!hidden_list\" stop-event=\"click\">Other languages</a>\n      <ul class=\"other\" ng-hide=\"hidden_list\">\n        <li ng-repeat=\"(name, story) in item.stories\" ng-switch on=\"story.status\">\n          <span class=\"col-lg-4\">{{trans[name]}} </span>\n          <i class=\"icon-globe\" ng-switch-when=\"published\" ></i>\n          <i class=\"icon-user\" ng-switch-when=\"passcode\" ></i>\n        </li>\n      </ul>\n    </li>\n  </ul>\n</div>",
      link: function(scope, element, attrs) {
        scope.hidden_list = true;
        return true;
      }
    };
  }).directive("switchpub", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        provider: '=ngProvider'
      },
      template: "<div class=\"btn-group\">\n  <button class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\">\n    <div class=\"extra_right\" ng-switch on=\"item.status\">\n      <i class=\"icon-globe\" ng-switch-when=\"published\" ></i>\n      <i class=\"icon-user\" ng-switch-when=\"passcode\" ></i>\n    </div>\n    <span class=\"caret\"></span></button>\n  <ul class=\"dropdown-menu\" role=\"menu\">\n    Who can see it in mobile application\n    <li class=\"divider\"></li>\n    <li  ng-click=\"item.status = 'published'\">\n      <i class=\"icon-globe\"></i> Everyone\n      <span class=\"check\" ng-show=\"item.status == 'published'\">✓</span>\n    </li>\n    <li ng-click=\"item.status = 'passcode'\">\n      <i class=\"icon-user\"></i> Only users who have passcode\n      <span class=\"check\" ng-show=\"item.status == 'passcode'\">✓</span>\n      <div class=\"limited-pass-hint hidden\">\n        <div class=\"limited-pass\">\n          {{provider.passcode}}\n        </div>\n        <a href=\"{{provider.passcode_edit_link}}\" target=\"_blank\">Edit</a>\n      </div>\n    </li>\n  </ul>\n</div>",
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive("placeholderfield", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField',
        inv_sign: '=invalidsign',
        placeholder: '=placeholder',
        field_type: '@type'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-xs-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">{{title}}</label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  {{active_exhibit}}\n  <span class=\"empty_name_error {{field}}\">can't be empty</span>\n  <div class=\"col-xs-6 trigger\" ng-hide=\"edit_mode || empty_val\">\n    <span class=\"placeholder\" ng-click=\"edit_mode = true\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-xs-6 triggered\" ng-show=\"edit_mode || empty_val\">\n    <input class=\"form-control\" id=\"{{id}}\" ng-model=\"item[field]\" focus-me=\"edit_mode\" type=\"text\" ng-blur=\"status_process()\" required placeholder=\"{{placeholder}}\">\n    <div class=\"error_text {{field}}\" >can't be blank</div>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.field];
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] && $scope.item[$scope.field].length !== 0) {
            $scope.status = 'progress';
            $rootScope.$broadcast('changes_to_save', $scope);
            $scope.empty_val = false;
            return $scope.edit_mode = false;
          } else {
            return $scope.empty_val = true;
          }
        };
      },
      link: function(scope, element, attrs) {
        scope.edit_mode = false;
        scope.$watch('item[field]', function(newValue, oldValue) {
          scope.status = '';
          if (!newValue) {
            return scope.empty_val = true;
          } else {
            return scope.empty_val = false;
          }
        });
        scope.$watch('inv_sign', function(newValue, oldValue) {
          if (newValue === true) {
            return setTimeout(function() {
              scope.name_error = false;
              return console.log(scope.name_error);
            }, 1000);
          } else {
            return scope.empty_val = false;
          }
        });
        return true;
      }
    };
  }).directive("placeholdertextarea", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField',
        max_length: '@maxlength',
        placeholder: '=placeholder',
        field_type: '@type'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-xs-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">{{title}}</label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  <span class=\"sumbols_left\" ng-hide=\"status == 'progress' || status == 'done' || empty_val || !edit_mode \">\n    {{length_text}}\n  </span>\n  <div class=\"col-lg-6 trigger\" ng-hide=\"edit_mode || empty_val\">\n    <span class=\"placeholder large\" ng-click=\"edit_mode = true\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-lg-6 triggered\" ng-show=\"edit_mode || empty_val\">\n    <textarea class=\"form-control\" id=\"{{id}}\" focus-me=\"edit_mode\" ng-model=\"item[field]\" ng-blur=\"status_process()\" required placeholder=\"{{placeholder}}\">\n    </textarea>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.field];
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] && $scope.item[$scope.field].length !== 0) {
            $scope.status = 'progress';
            console.log($scope.item);
            $scope.empty_val = false;
            return $scope.edit_mode = false;
          } else {
            return $scope.empty_val = true;
          }
        };
      },
      link: function(scope, element, attrs) {
        scope.length_text = "осталось символов: 255";
        scope.edit_mode = false;
        scope.$watch('item[field]', function(newValue, oldValue) {
          if (!newValue) {
            scope.empty_val = true;
            return scope.length_text = "осталось символов: 255";
          } else {
            scope.empty_val = false;
            scope.max_length || (scope.max_length = 255);
            scope.length_text = "осталось символов: " + (scope.max_length - newValue.length - 1);
            if (newValue.length >= scope.max_length) {
              return scope.item[scope.field] = newValue.substr(0, scope.max_length - 1);
            }
          }
        });
        return true;
      }
    };
  }).directive("quizanswer", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        collection: '=ngCollection',
        id: '@ngId'
      },
      template: "<div class=\"form-group string optional checkbox_added\">\n  <label class=\"string optional control-label col-xs-2\" for=\"{{id}}\">\n    <span class='correct_answer_indicator' ng-show=\"item.correct_saved\">correct</span>\n  </label>\n  <input class=\"coorect_answer_radio\" name=\"correct_answer\" type=\"radio\" value=\"{{item.id}}\" ng-model=\"checked\" ng-click=\"check_items(item)\">\n  <div class=\"col-xs-5 trigger\" ng-hide=\"edit_mode || empty_val\">\n    <span class=\"placeholder\" ng-click=\"edit_mode = true\">{{item.content}}</span>\n  </div>\n  <div class=\"col-xs-5 triggered\" ng-show=\"edit_mode || empty_val\">\n    <input class=\"form-control\" id=\"{{id}}\" name=\"{{item.id}}\" placeholder=\"Enter option\" type=\"text\" ng-model=\"item.content\" focus-me=\"edit_mode\" ng-blur=\"status_process()\" required>\n    <div class=\"error_text\">can't be blank</div>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.content];
        if ($scope.item.correct_saved == null) {
          $scope.item.correct_saved = false;
        }
        $scope.check_items = function(item) {
          var sub_item, _i, _len, _ref;
          _ref = $scope.collection;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            sub_item = _ref[_i];
            sub_item.correct = false;
            sub_item.correct_saved = false;
          }
          item.correct = true;
          return $scope.item.correct_saved = true;
        };
        return $scope.status_process = function() {
          if ($scope.item.content && $scope.item.content.length !== 0) {
            $scope.status = 'progress';
            $scope.empty_val = false;
            return $scope.edit_mode = false;
          } else {
            return $scope.empty_val = true;
          }
        };
      },
      link: function(scope, element, attrs) {
        scope.edit_mode = false;
        scope.empty_val = false;
        scope.checked = 0;
        scope.$watch('collection', function(newValue, oldValue) {
          var single_item, _i, _len, _results;
          if (newValue) {
            _results = [];
            for (_i = 0, _len = newValue.length; _i < _len; _i++) {
              single_item = newValue[_i];
              if (single_item.correct === true) {
                _results.push(scope.checked = single_item.id);
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          }
        });
        scope.$watch('item.content', function(newValue, oldValue) {
          if (!newValue) {
            scope.edit_mode = true;
            return scope.empty_val = true;
          } else {
            return scope.empty_val = false;
          }
        });
        return scope.$watch('item.correct_saved', function(newValue, oldValue) {
          if (newValue === true) {
            return setTimeout(function() {
              return scope.$apply(scope.item.correct_saved = false);
            }, 1000);
          }
        }, true);
      }
    };
  }).directive("statusIndicator", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngBinding',
        field: '=ngField'
      },
      template: "<div class=\"statuses\">\n  <div class='preloader' ng-show=\"item=='progress'\"></div>\n  <div class=\"save_status\" ng-show=\"item=='done'\">\n    <i class=\"icon-ok-sign\"></i>saved\n  </div>\n</div>",
      link: function(scope, element, attrs) {
        scope.$watch('item', function(newValue, oldValue) {
          if (newValue) {
            if (newValue === 'progress') {
              scope.progress_timeout = setTimeout(function() {
                return scope.$apply(scope.item = 'done');
              }, 500);
            }
            if (newValue === 'done') {
              return scope.done_timeout = setTimeout(function() {
                return scope.$apply(scope.item = '');
              }, 700);
            }
          } else {
            clearTimeout(scope.done_timeout);
            return clearTimeout(scope.progress_timeout);
          }
        }, true);
        return true;
      }
    };
  }).directive("audioplayer", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-xs-2 control-label\" for=\"audio\">Audio</label>\n  <div class=\"help\">\n    <i class=\"icon-question-sign\" data-content=\"Supplementary field. You may indicate the exhibit’s inventory, or any other number, that will help you to identify the exhibit within your own internal information system.\" data-placement=\"bottom\"></i>\n  </div>\n  <div class=\"col-xs-6 trigger\" ng-hide=\"edit_mode\">\n    <div class=\"jp-jplayer\" id=\"jquery_jplayer_{{id}}\">\n    </div>\n    <div class=\"jp-audio\" id=\"jp_container_{{id}}\">\n      <div class=\"jp-type-single\">\n        <div class=\"jp-gui jp-interface\">\n          <ul class=\"jp-controls\">\n            <li>\n            <a class=\"jp-play\" href=\"javascript:;\" tabindex=\"1\"></a>\n            </li>\n            <li>\n            <a class=\"jp-pause\" href=\"javascript:;\" tabindex=\"1\"></a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"dropdown\">\n          <a data-toggle=\"dropdown\" href=\"#\" id=\"visibility_filter\">Audioguide 01<span class=\"caret\"></span></a>\n          <ul aria-labelledby=\"visibility_filter\" class=\"dropdown-menu\" role=\"menu\">\n            <li role=\"presentation\">\n            <a href=\"#\" role=\"menuitem\" tabindex=\"-1\">Replace</a>\n            </li>\n            <li role=\"presentation\">\n            <a href=\"#\" role=\"menuitem\" tabindex=\"-1\">Download</a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"jp-progress\">\n          <div class=\"jp-seek-bar\">\n            <div class=\"jp-play-bar\">\n            </div>\n          </div>\n        </div>\n        <div class=\"jp-time-holder\">\n          <div class=\"jp-current-time\">\n          </div>\n          <div class=\"jp-duration\">\n          </div>\n        </div>\n        <div class=\"jp-no-solution\">\n          <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href=\"http://get.adobe.com/flashplayer/\" target=\"_blank\"></a>\n        </div>\n      </div>\n    </div>\n  </div>\n  <div class=\"col-xs-6 triggered\" ng-show=\"edit_mode\">\n    <input type=\"file\" id=\"exampleInputFile\">\n  </div>\n  <status-indicator ng-binding=\"item\" ng-field=\"field\"></statusIndicator>\n</div>",
      link: function(scope, element, attrs) {
        scope.edit_mode = false;
        scope.$watch('item[field]', function(newValue, oldValue) {
          if (!newValue) {
            return scope.edit_mode = true;
          } else {
            scope.edit_mode = false;
            console.log(newValue);
            $("#jquery_jplayer_" + scope.id).jPlayer({
              cssSelectorAncestor: "#jp_container_" + scope.id,
              swfPath: "/js",
              wmode: "window",
              preload: "auto",
              smoothPlayBar: true,
              keyEnabled: true,
              supplied: "m4a, oga"
            });
            return $("#jquery_jplayer_" + scope.id).jPlayer("setMedia", {
              m4a: newValue,
              oga: newValue
            });
          }
        });
        return true;
      }
    };
  }).directive("museumSearch", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngModel'
      },
      template: "<div class=\"searches\">\n  <div class=\"search\" ng-hide=\"museum_search_visible\" ng-click=\"museum_search_visible=true; museum_input_focus = true\">\n    <i class=\"icon-search\"></i>\n    <a href=\"#\">{{item || 'Search'}}</a>\n  </div>\n  <div class=\"search_input\" ng-show=\"museum_search_visible\">\n    <input class=\"form-control\" ng-model=\"item\" placeholder=\"Search\" type=\"text\" focus-me=\"museum_input_focus\">\n    <a class=\"search_reset\" href=\"#\" ng-click=\"item=''\">\n      <i class=\"icon-remove-sign\"></i>\n    </a>\n  </div>\n</div>",
      controller: function($scope, $element) {
        $scope.museum_search_visible = false;
        $scope.museum_input_focus = false;
        $($element).find('.search_input input').blur(function() {
          var elem;
          elem = $(this);
          $scope.$apply($scope.museum_input_focus = false);
          return elem.animate({
            width: '150px'
          }, 150, function() {
            $scope.$apply($scope.museum_search_visible = false);
            return true;
          });
        });
        return $($element).find('.search_input input').focus(function() {
          var input, width;
          input = $(this);
          width = $('body').width() - 700;
          if (width > 150) {
            return input.animate({
              width: "" + width + "px"
            }, 300);
          }
        });
      },
      link: function(scope, element, attrs) {
        return true;
      }
    };
  });

}).call(this);
