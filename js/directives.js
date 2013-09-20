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
  }).directive("switchpubitem", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        provider: '=ngProvider'
      },
      template: "<div class=\"btn-group pull-right item_publish_settings ololo\">\n  <button class=\"btn btn-success dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\" ng-switch on=\"item.publish_state\">\n    <div class=\"extra\" ng-switch on=\"item.publish_state\">\n      <i class=\"icon-globe\" ng-switch-when=\"all\" ></i>\n      <i class=\"icon-user\" ng-switch-when=\"passcode\" ></i>\n    </div>\n    <span ng-switch-when=\"passcode\">Publish</span>\n    <span ng-switch-when=\"all\">Published</span>\n    <span class=\"caret\"></span>\n  </button>\n  <ul class=\"dropdown-menu status-select-dropdown\" role=\"menu\">\n    Who can see it in mobile application\n    <li ng-click=\"item.publish_state = 'all'\">\n      <i class=\"icon-globe\"></i> Everyone\n    </li>\n    <li  ng-click=\"item.publish_state = 'passcode'\">\n      <i class=\"icon-user\"></i> Only users who have passcode\n      <div class=\"limited-pass-hint hidden\">\n        <div class=\"limited-pass\">\n          {{provider.passcode}}\n        </div>\n        <a href=\"{{provider.passcode_edit_link}}\" target=\"_blank\">Edit</a>\n      </div>\n    </li>\n    <li class=\"divider\"></li>\n    <li class=\"other_list\">\n      <span class=\"other_lang\" ng-click=\"hidden_list=!hidden_list\" stop-event=\"click\">Other languages</a>\n      <ul class=\"other\" ng-hide=\"hidden_list\">\n        <li>\n          <span class=\"col-lg-4\">English </span><i class=\"icon-globe\"></i>\n        </li>\n        <li>\n          <span class=\"col-lg-4\">Italian </span><i class=\"icon-lock\"></i>\n        </li>\n        <li>\n          <span class=\"col-lg-4\">Japan</span>\n        </li>\n      </ul>\n    </li>\n  </ul>\n</div>",
      link: function(scope, element, attrs) {
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
      template: "<div class=\"btn-group\">\n  <button class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\">\n    <div class=\"extra_right\" ng-switch on=\"item.publish_state\">\n      <i class=\"icon-globe\" ng-switch-when=\"all\" ></i>\n      <i class=\"icon-user\" ng-switch-when=\"passcode\" ></i>\n    </div>\n    <span class=\"caret\"></span></button>\n  <ul class=\"dropdown-menu\" role=\"menu\">\n    Who can see it in mobile application\n    <li ng-click=\"item.publish_state = 'all'\">\n      <i class=\"icon-globe\"></i> Everyone\n    </li>\n    <li  ng-click=\"item.publish_state = 'passcode'\">\n      <i class=\"icon-user\"></i> Only users who have passcode\n      <div class=\"limited-pass-hint hidden\">\n        <div class=\"limited-pass\">\n          {{provider.passcode}}\n        </div>\n        <a href=\"{{provider.passcode_edit_link}}\" target=\"_blank\">Edit</a>\n      </div>\n    </li>\n  </ul>\n</div>",
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive("placeholderfield", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-lg-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">{{title}}</label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  <div class=\"col-lg-6 trigger\" ng-hide=\"edit_mode || item[field].length == 0\">\n    <span class=\"placeholder\" ng-click=\"edit_mode = true\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-lg-6 triggered\" ng-show=\"edit_mode || item[field].length == 0\">\n    <input class=\"form-control\" id=\"{{id}}\" ng-model=\"item[field]\" focus-me=\"edit_mode\" type=\"text\"  ng-blur=\"item.statuses[field]='progress'\">\n  </div>\n  <status-indicator ng-model=\"item\" ng-field=\"field\"></statusIndicator>\n</div>",
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive("placeholdertextarea", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-lg-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">{{title}}</label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  <div class=\"col-lg-6 trigger\" ng-hide=\"edit_mode || item[field].length == 0\">\n    <span class=\"placeholder large\" ng-click=\"edit_mode = true\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-lg-6 triggered\" ng-show=\"edit_mode || item[field].length == 0\">\n    <textarea class=\"form-control\" id=\"{{id}}\" focus-me=\"edit_mode\" ng-model=\"item[field]\" ng-blur=\"item.statuses[field]='progress'\">\n    </textarea>\n  </div>\n  <status-indicator ng-model=\"item\" ng-field=\"field\"></statusIndicator>\n</div>",
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive("quizanswer", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        collection: '=ngCollection',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField'
      },
      template: "<div class=\"form-group string optional checkbox_added\">\n  <label class=\"string optional control-label col-lg-2\" for=\"{{id}}\"></label>\n  <input class=\"coorect_answer_radio\" name=\"correct_answer\" type=\"radio\" value=\"{{item.id}}\" ng-model=\"checked\" ng-click=\"check_items(item)\"> <!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!! -->\n  <div class=\"col-lg-5 trigger\"  ng-hide=\"edit_mode || item[field].length == 0\">\n    <span class=\"placeholder\" ng-click=\"edit_mode = true\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-lg-5 triggered\" ng-show=\"edit_mode || item[field].length == 0\">\n    <input class=\"form-control\" id=\"{{id}}\" placeholder=\"Enter option\" type=\"text\" ng-model=\"item[field]\" focus-me=\"edit_mode\" ng-blur=\"item.statuses[field]='progress'\">\n  </div>\n  <status-indicator ng-model=\"item\" ng-field=\"field\"></statusIndicator>\n</div>",
      link: function(scope, element, attrs) {
        scope.checked = 0;
        scope.check_items = function(item) {
          var single_item, _i, _len, _ref;
          _ref = scope.collection;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            single_item = _ref[_i];
            single_item.correct = false;
          }
          item.correct = true;
          return console.log(item);
        };
        true;
        return scope.$watch('collection', function(newValue, oldValue) {
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
        }, true);
      }
    };
  }).directive("statusIndicator", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngModel',
        field: '=ngField'
      },
      template: "<div class=\"statuses\">\n  <div class='preloader' ng-show=\"item.statuses[field]=='progress'\"></div>\n  <div class=\"save_status\" ng-show=\"item.statuses[field]=='done'\">\n    <i class=\"icon-ok-sign\"></i>saved\n  </div>\n</div>",
      link: function(scope, element, attrs) {
        if (scope.item.statuses == null) {
          scope.item.statuses = {};
        }
        return scope.$watch('item.statuses[field]', function(newValue, oldValue) {
          if (newValue) {
            if (newValue === 'progress') {
              setTimeout(function() {
                return scope.$apply(scope.item.statuses[scope.field] = 'done');
              }, 500);
            }
            if (newValue === 'done') {
              return setTimeout(function() {
                return scope.$apply(scope.item.statuses[scope.field] = '');
              }, 700);
            }
          }
        }, true);
      }
    };
  });

}).call(this);
