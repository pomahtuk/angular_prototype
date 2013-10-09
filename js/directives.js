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
          var filters, margin;
          filters = $('.filters_bar');
          margin = filters.css('top');
          if (margin === '0px') {
            filters.animate({
              'top': '-44px'
            }, 300);
          } else {
            filters.animate({
              'top': '0px'
            }, 300);
          }
          scope.filters_opened = !scope.filters_opened;
          scope.$digest();
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
          $timeout(scope.grid, 200);
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
        trans: '=translations',
        field: '@field',
        field_type: '@type',
        root: '=root'
      },
      template: "<div class=\"btn-group pull-right item_publish_settings\">\n  <button class=\"btn btn-success dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\" ng-switch on=\"item[field]\">\n    <div class=\"extra\" ng-switch on=\"item[field]\">\n      <i class=\"icon-globe\" ng-switch-when=\"published\" ></i>\n      <i class=\"icon-lock\" ng-switch-when=\"passcode\" ></i>\n    </div>\n    <span ng-switch-when=\"passcode\">Publish</span>\n    <span ng-switch-when=\"published\">Published</span>\n    <span class=\"caret\"></span>\n  </button>\n  <ul class=\"dropdown-menu status-select-dropdown\" role=\"menu\">\n    Who can see it in mobile application\n    <li class=\"divider\"></li>\n    <li ng-click=\"item[field] = 'published'; status_process()\">\n    <span class=\"check\"><i ng-show=\"item[field] == 'published'\" class=\"icon-ok\"></i></span>\n      <i class=\"icon-globe\"></i> Everyone\n    </li>\n    <li ng-click=\"item[field] = 'passcode'; status_process()\">\n      <span class=\"check\"><i ng-show=\"item[field] == 'passcode'\" class=\"icon-ok\"></i></span>\n      <i class=\"icon-lock\"></i> Only users who have passcode\n      <div class=\"limited-pass-hint hidden\">\n        <div class=\"limited-pass\">\n          {{provider.passcode}}\n        </div>\n        <a href=\"{{provider.passcode_edit_link}}\" target=\"_blank\">Edit</a>\n      </div>\n    </li>\n    <li class=\"divider\"></li>\n    <li class=\"other_list\">\n      <span class=\"other_lang\" ng-click=\"hidden_list=!hidden_list\" stop-event=\"click\">Other languages</a>\n      <ul class=\"other\" ng-hide=\"hidden_list\">\n        <li ng-repeat=\"(name, story) in root.stories\" ng-switch on=\"story.status\">\n          <span class=\"col-lg-4\">{{trans[name]}} </span>\n          <i class=\"icon-globe\" ng-switch-when=\"published\" ></i>\n          <i class=\"icon-lock\" ng-switch-when=\"passcode\" ></i>\n        </li>\n      </ul>\n    </li>\n  </ul>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        return $scope.status_process = function() {
          var valid;
          valid = true;
          if (valid) {
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
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
        provider: '=ngProvider',
        field: '@field',
        field_type: '@type'
      },
      template: "<div class=\"btn-group pull-right\">\n  <button class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\" type=\"button\">\n    <div class=\"extra_right\" ng-switch on=\"item[field]\">\n      <i class=\"icon-globe\" ng-switch-when=\"published\" ></i>\n      <i class=\"icon-lock\" ng-switch-when=\"passcode\" ></i>\n    </div>\n    <span class=\"caret\"></span></button>\n  <ul class=\"dropdown-menu pull-left\" role=\"menu\" >\n    Who can see it in mobile application\n    <li class=\"divider\"></li>\n    <li  ng-click=\"item[field] = 'published'; status_process()\">\n      <span class=\"check\"><i ng-show=\"item[field] == 'published'\" class=\"icon-ok\"></i></span>\n      <i class=\"icon-globe\"></i> Everyone\n    </li>\n    <li ng-click=\"item[field] = 'passcode'; status_process()\">\n      <span class=\"check\"><i ng-show=\"item[field] == 'passcode'\" class=\"icon-ok\"></i></span>\n      <i class=\"icon-lock\"></i> Only users who have passcode\n      <div class=\"limited-pass-hint hidden\">\n        <div class=\"limited-pass\">\n          {{provider.passcode}}\n        </div>\n        <a href=\"{{provider.passcode_edit_link}}\" target=\"_blank\">Edit</a>\n      </div>\n    </li>\n  </ul>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        return $scope.status_process = function() {
          var valid;
          valid = true;
          if (valid) {
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive("placeholderfield", function($timeout) {
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
      template: "<div class=\"form-group textfield\">\n  <label class=\"col-xs-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">{{title}}</label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  {{active_exhibit}}\n  <span class=\"empty_name_error {{field}}\">can't be empty</span>\n  <div class=\"col-xs-6 trigger\">\n    <span class=\"placeholder\" ng-click=\"update_old()\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-xs-6 triggered\">\n    <input type=\"hidden\" id=\"original_{{id}}\" ng-model=\"item[field]\" required\">\n    <input type=\"text\" class=\"form-control\" id=\"{{id}}\" value=\"{{item[field]}}\" placeholder=\"{{placeholder}}\">\n    <div class=\"error_text {{field}}\" >can't be blank</div>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.field];
        $scope.update_old = function() {
          return $scope.oldValue = $scope.item[$scope.field];
        };
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] !== $scope.oldValue) {
            $scope.status = 'progress';
            $scope.$digest();
            if ($scope.$parent.$parent.new_item_creation && $scope.field === 'name') {
              if ($scope.item[$scope.field] && $scope.item[$scope.field].length !== 0) {
                console.log('wow');
                $rootScope.$broadcast('save_new_exhibit');
                return true;
              }
            }
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
      link: function(scope, element, attrs) {
        var trigger, triggered;
        element = $(element);
        trigger = element.find('.trigger');
        triggered = element.find('.triggered');
        element.find('span.placeholder').click(function() {
          trigger.hide();
          triggered.show().children('.form-control').focus();
          return element.find('.triggered > .form-control').removeClass('ng-invalid');
        });
        element.find('.triggered > .form-control').blur(function() {
          var elem;
          elem = $(this);
          $timeout(function() {
            scope.item[scope.field] = elem.val();
            scope.$digest();
            return scope.status_process();
          }, 0, false);
          if (elem.val() !== '') {
            triggered.hide();
            return trigger.show();
          } else {
            elem.addClass('ng-invalid');
            if (scope.field === 'name') {
              return $timeout(function() {
                elem.val(scope.oldValue);
                scope.item[scope.field] = scope.oldValue;
                scope.$digest();
                return scope.status_process();
              }, 0, false);
            }
          }
        });
        element.find('.triggered > .form-control').keyup(function() {
          return true;
        });
        scope.$watch('item[field]', function(newValue, oldValue) {
          scope.status = '';
          if (!newValue) {
            console.log('hiding', scope.field);
            trigger.hide();
            triggered.show();
            if (scope.filed === 'name') {
              return triggered.find('.form-control').focus();
            }
          } else {
            if (scope.$parent.$parent.element_switch === true) {
              trigger.show();
              return triggered.hide();
            }
          }
        });
        return true;
      }
    };
  }).directive("placeholdertextarea", function($timeout) {
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
      template: "<div class=\"form-group textfield large_field\">\n  <label class=\"col-xs-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">{{title}}</label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  <div class=\"col-lg-6 trigger\">\n    <span class=\"placeholder large\" ng-click=\"update_old()\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-lg-6 triggered\">\n    <input type=\"hidden\" id=\"original_{{id}}\" ng-model=\"item[field]\" required\">\n    <textarea class=\"form-control\" id=\"{{id}}\" placeholder=\"{{placeholder}}\">{{item[field]}}</textarea>\n  </div>\n  <span class=\"sumbols_left\">\n    {{length_text}}\n  </span>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.field];
        $scope.update_old = function() {
          return $scope.oldValue = $scope.item[$scope.field];
        };
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] && $scope.item[$scope.field].length !== 0) {
            if ($scope.item[$scope.field] !== $scope.oldValue) {
              $scope.status = 'progress';
              $scope.$digest();
              $rootScope.$broadcast('changes_to_save', $scope);
            }
            $scope.empty_val = false;
            return $scope.edit_mode = false;
          } else {
            return $scope.empty_val = true;
          }
        };
      },
      link: function(scope, element, attrs) {
        var sumbols_left, trigger, triggered;
        scope.length_text = "осталось символов: 255";
        element = $(element);
        trigger = element.find('.trigger');
        triggered = element.find('.triggered');
        sumbols_left = element.find('.sumbols_left');
        element.find('span.placeholder').click(function() {
          trigger.hide();
          triggered.show().children('.form-control').focus();
          return sumbols_left.show();
        });
        element.find('.triggered > .form-control').blur(function() {
          var elem;
          elem = $(this);
          $timeout(function() {
            scope.item[scope.field] = elem.val();
            scope.$digest();
            return scope.status_process();
          }, 0, false);
          if (elem.val() !== '') {
            triggered.hide();
            trigger.show();
            return sumbols_left.hide();
          }
        });
        element.find('.triggered > .form-control').keyup(function(e) {
          var elem, value;
          elem = $(this);
          value = elem.val();
          if (value.length >= scope.max_length) {
            elem.val(value.substr(0, scope.max_length - 1));
          }
          scope.length_text = "осталось символов: " + (scope.max_length - value.length - 1);
          return scope.$digest();
        });
        scope.$watch('item[field]', function(newValue, oldValue) {
          if (!newValue) {
            scope.length_text = "осталось символов: 255";
            trigger.hide();
            return triggered.show();
          } else {
            scope.max_length || (scope.max_length = 255);
            if (scope.$parent.$parent.element_switch === true) {
              trigger.show();
              triggered.hide();
            }
            return true;
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
        id: '@ngId',
        field: '@field',
        field_type: '@type'
      },
      template: "<div class=\"form-group textfield string optional checkbox_added\">\n  <label class=\"string optional control-label col-xs-2\" for=\"{{id}}\">\n    <span class='correct_answer_indicator'>correct</span>\n  </label>\n  <input class=\"coorect_answer_radio\" name=\"correct_answer\" type=\"radio\" value=\"{{item._id}}\" ng-model=\"checked\" ng-click=\"check_items(item)\">\n  <div class=\"col-xs-5 trigger\">\n    <span class=\"placeholder\" ng-click=\"update_old()\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-xs-5 triggered\">\n    <input class=\"form-control\" id=\"{{id}}\" name=\"{{item._id}}\" placeholder=\"Enter option\" type=\"text\" ng-model=\"item[field]\" required>\n    <div class=\"error_text\">can't be blank</div>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.content];
        if ($scope.item.correct_saved == null) {
          $scope.item.correct_saved = false;
        }
        $scope.check_items = function(item) {
          return $rootScope.$broadcast('quiz_changes_to_save', $scope, item);
        };
        $scope.update_old = function() {
          return $scope.oldValue = $scope.item[$scope.field];
        };
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] !== $scope.oldValue) {
            $scope.status = 'progress';
            $scope.$digest();
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
      link: function(scope, element, attrs) {
        var indicator, trigger, triggered;
        element = $(element);
        trigger = element.find('.trigger');
        triggered = element.find('.triggered');
        indicator = element.find('.correct_answer_indicator');
        element.find('span.placeholder').click(function() {
          trigger.hide();
          return triggered.show().children().first().focus();
        });
        element.find('.triggered > *').blur(function() {
          var elem;
          elem = $(this);
          scope.status_process();
          if (elem.val() !== '') {
            triggered.hide();
            return trigger.show();
          }
        });
        scope.$watch('collection', function(newValue, oldValue) {
          var single_item, _i, _len, _results;
          if (newValue) {
            scope.checked = newValue[0]._id;
            _results = [];
            for (_i = 0, _len = newValue.length; _i < _len; _i++) {
              single_item = newValue[_i];
              if (single_item.correct === true) {
                _results.push(scope.checked = single_item._id);
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          }
        });
        scope.$watch('item.content', function(newValue, oldValue) {
          if (!newValue) {
            trigger.hide();
            return triggered.show();
          } else {
            console.log(scope.$parent.$parent.element_switch);
            if (scope.$parent.$parent.element_switch === true) {
              trigger.show();
              return triggered.hide();
            }
          }
        });
        return scope.$watch('item.correct_saved', function(newValue, oldValue) {
          if (newValue === true) {
            indicator.show();
            return setTimeout(function() {
              indicator.hide();
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
        field: '@ngField',
        parent: '=parent'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-xs-2 control-label\" for=\"audio\">Audio</label>\n  <div class=\"help\">\n    <i class=\"icon-question-sign\" data-content=\"Supplementary field. You may indicate the exhibit’s inventory, or any other number, that will help you to identify the exhibit within your own internal information system.\" data-placement=\"bottom\"></i>\n  </div>\n  <div class=\"col-xs-6 trigger\" ng-hide=\"edit_mode\">\n    <div class=\"jp-jplayer\" id=\"jquery_jplayer_{{id}}\">\n    </div>\n    <div class=\"jp-audio\" id=\"jp_container_{{id}}\">\n      <div class=\"jp-type-single\">\n        <div class=\"jp-gui jp-interface\">\n          <ul class=\"jp-controls\">\n            <li>\n            <a class=\"jp-play\" href=\"javascript:;\" tabindex=\"1\"></a>\n            </li>\n            <li>\n            <a class=\"jp-pause\" href=\"javascript:;\" tabindex=\"1\"></a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"dropdown\">\n          <a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\" id=\"visibility_filter\">{{item[field].name}}<span class=\"caret\"></span></a>\n          <ul class=\"dropdown-menu\" role=\"menu\">\n            <li role=\"presentation\">\n              <a href=\"#\" class=\"replace_media\" data-confirm=\"Are you sure you wish to replace this audio?\" data-method=\"delete\" data-link=\"{{$parent.$parent.backend_url}}/media/{{item[field]._id}}\">Replace</a>\n            </li>\n            <li role=\"presentation\">\n              <a href=\"{{item[field].url}}\" target=\"_blank\">Download</a>\n            </li>\n            <li role=\"presentation\">\n              <a class=\"remove\" href=\"#\" data-confirm=\"Are you sure you wish to delete this audio?\" data-method=\"delete\" data-link=\"{{$parent.$parent.backend_url}}/media/{{media._id}}\" delete-media=\"\" stop-event=\"\" media=\"item[field]\" parent=\"item\">Delete</a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"jp-progress\">\n          <div class=\"jp-seek-bar\">\n            <div class=\"jp-play-bar\">\n            </div>\n          </div>\n        </div>\n        <div class=\"jp-time-holder\">\n          <div class=\"jp-current-time\">\n          </div>\n          <div class=\"jp-duration\">\n          </div>\n        </div>\n        <div class=\"jp-no-solution\">\n          <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href=\"http://get.adobe.com/flashplayer/\" target=\"_blank\"></a>\n        </div>\n      </div>\n    </div>\n  </div>\n  <div class=\"triggered\" ng-show=\"edit_mode\">\n    <a href=\"#\" class=\"btn btn-default\" button-file-upload=\"\">Upload a file</a> or drag an audio here\n  </div>\n  <status-indicator ng-binding=\"item\" ng-field=\"field\"></statusIndicator>\n</div>",
      link: function(scope, element, attrs) {
        scope.edit_mode = false;
        element = $(element);
        element.find('.replace_media').click(function(e) {
          var elem, input, parent;
          e.preventDefault();
          e.stopPropagation();
          elem = $(this);
          if (confirm(elem.data('confirm'))) {
            parent = elem.parents('#drop_down, #museum_drop_down');
            parent.click();
            input = parent.find('.images :file');
            return input.click();
          }
        });
        scope.$watch('item[field]', function(newValue, oldValue) {
          if (!newValue) {
            return scope.edit_mode = true;
          } else {
            scope.edit_mode = false;
            $("#jquery_jplayer_" + scope.id).jPlayer({
              cssSelectorAncestor: "#jp_container_" + scope.id,
              swfPath: "/js",
              wmode: "window",
              preload: "auto",
              smoothPlayBar: true,
              keyEnabled: true,
              supplied: "mp3, ogg"
            });
            return $("#jquery_jplayer_" + scope.id).jPlayer("setMedia", {
              mp3: newValue.url,
              ogg: newValue.thumbnailUrl
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
  }).directive('canDragAndDrop', function() {
    return {
      restrict: 'A',
      require: '?ngModel',
      scope: {
        model: '=ngModel',
        url: '@uploadTo',
        selector: '@selector',
        selector_dropzone: '@selectorDropzone'
      },
      link: function(scope, element, attrs) {
        var checkExtension, correctFileSize, dropzone, fileSizeMb, hide_drop_area, initiate_progress;
        scope.$parent.$parent.loading_in_progress = false;
        fileSizeMb = 50;
        element = $("#" + scope.selector);
        dropzone = $("#" + scope.selector_dropzone);
        checkExtension = function(object) {
          var extension, type;
          extension = object.files[0].name.split('.').pop().toLowerCase();
          type = 'unsupported';
          if ($.inArray(extension, gon.acceptable_extensions.image) !== -1) {
            type = 'image';
          }
          if ($.inArray(extension, gon.acceptable_extensions.audio) !== -1) {
            type = 'audio';
          }
          return type;
        };
        correctFileSize = function(object) {
          return object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024;
        };
        hide_drop_area = function() {
          $(".progress").hide();
          return setTimeout(function() {
            $("body").removeClass("in");
            scope.$parent.$parent.loading_in_progress = false;
            return scope.$parent.$parent.forbid_switch = false;
          }, 1000);
        };
        initiate_progress = function() {
          scope.$parent.$parent.loading_in_progress = true;
          scope.$parent.$parent.forbid_switch = true;
          scope.$digest();
          $("body").addClass("in");
          $(".progress .progress-bar").css("width", 0 + "%");
          return $(".progress").show();
        };
        element.fileupload({
          url: scope.url,
          dataType: "json",
          dropZone: dropzone,
          change: function(e, data) {
            return initiate_progress();
          },
          drop: function(e, data) {
            initiate_progress();
            return $.each(data.files, function(index, file) {
              return console.log("Dropped file: " + file.name);
            });
          },
          add: function(e, data) {
            if (checkExtension(data) === 'image' || checkExtension(data) === 'audio') {
              if (correctFileSize(data)) {
                return data.submit();
              } else {
                console.log('error: file size');
                return hide_drop_area();
              }
            } else {
              console.log('error: file type');
              return hide_drop_area();
            }
          },
          success: function(result) {
            var file, _i, _len, _results;
            console.log(result, scope.model);
            _results = [];
            for (_i = 0, _len = result.length; _i < _len; _i++) {
              file = result[_i];
              if (file.type === 'image') {
                if (scope.model.images == null) {
                  scope.model.images = [];
                }
                scope.$apply(scope.model.images.push(file));
              } else if (file.type === 'audio') {
                scope.$apply(scope.model.audio = file);
              }
              _results.push(scope.$digest());
            }
            return _results;
          },
          error: function(result, status, errorThrown) {
            var response, responseText;
            console.log(status, result, errorThrown);
            if (errorThrown === 'abort') {
              return console.log('abort');
            } else {
              if (result.status === 422) {
                response = jQuery.parseJSON(result.responseText);
                responseText = response.link[0];
                return console.log(responseText);
              } else {
                return console.log('unknown error');
              }
            }
          },
          progressall: function(e, data) {
            var progress;
            progress = parseInt(data.loaded / data.total * 100, 10);
            $(".progress .progress-bar").css("width", progress + "%");
            if (data.loaded === data.total) {
              scope.$parent.$parent.last_save_time = new Date();
              return hide_drop_area();
            }
          }
        }).prop("disabled", !$.support.fileInput).parent().addClass(($.support.fileInput ? undefined : "disabled"));
        return scope.$watch('url', function(newValue, oldValue) {
          if (newValue) {
            return element.fileupload("option", "url", newValue);
          }
        });
      }
    };
  }).directive("buttonFileUpload", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        return elem.click(function(e) {
          var parent;
          e.preventDefault();
          elem = $(this);
          parent = elem.parents('#drop_down, #museum_drop_down');
          return parent.find('.images :file').click();
        });
      }
    };
  }).directive('deleteMedia', function() {
    return {
      restrict: 'A',
      scope: {
        model: '=parent',
        media: '=media'
      },
      link: function(scope, element, attrs) {
        element = $(element);
        return element.click(function(e) {
          var elem;
          e.preventDefault();
          e.stopPropagation();
          elem = $(this);
          if (confirm(elem.data('confirm'))) {
            return $.ajax({
              url: elem.data('link'),
              type: elem.data('method'),
              success: function(data) {
                var image, index, _i, _len, _ref;
                if (scope.media.type === 'image') {
                  _ref = scope.model.images;
                  for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
                    image = _ref[index];
                    if (image != null) {
                      if (image._id === data) {
                        scope.$apply(scope.model.images.splice(index, 1));
                        scope.$digest();
                      }
                    }
                  }
                } else if (scope.media.type === 'audio') {
                  scope.model.audio = void 0;
                  scope.$digest();
                }
                return scope.$parent.$parent.last_save_time = new Date();
              }
            });
          }
        });
      }
    };
  }).directive('dragAndDropInit', function() {
    return {
      link: function(scope, element, attrs) {
        $(document).bind('drop dragover', function(e) {
          return e.preventDefault();
        });
        return $(document).bind("dragover", function(e) {
          var doc, dropZone, found, found_index, node, timeout;
          dropZone = $(".dropzone");
          doc = $("body");
          timeout = scope.dropZoneTimeout;
          if (!timeout) {
            doc.addClass("in");
          } else {
            clearTimeout(timeout);
          }
          found = false;
          found_index = 0;
          node = e.target;
          while (true) {
            if (node === dropZone[0]) {
              found = true;
              found_index = 0;
              break;
            } else if (node === dropZone[1]) {
              found = true;
              found_index = 1;
              break;
            }
            node = node.parentNode;
            if (node == null) {
              break;
            }
          }
          if (found) {
            return dropZone[found_index].addClass("hover");
          } else {
            return scope.dropZoneTimeout = setTimeout(function() {
              if (!scope.loading_in_progress) {
                scope.dropZoneTimeout = null;
                dropZone.removeClass("in hover");
                return doc.removeClass("in");
              }
            }, 300);
          }
        });
      }
    };
  }).directive('switchToggle', function($timeout) {
    return {
      restrict: 'A',
      controller: function($scope, $rootScope, $element, $attrs, $http) {
        var selector;
        selector = $attrs['quizSwitch'];
        $scope.quiz_state = function(form, item) {
          $scope.mark_quiz_validity(form.$valid);
          if (form.$valid) {
            $timeout(function() {
              $http.put("" + $scope.backend_url + "/quiz/" + item._id, item).success(function(data) {
                return console.log(data);
              }).error(function() {
                return console.log('fail');
              });
              return true;
            }, 0);
          } else {
            setTimeout(function() {
              return $("#" + selector + "_disabled").click();
            }, 300);
          }
          return true;
        };
        return $scope.mark_quiz_validity = function(valid) {
          var form, question;
          form = $("#" + selector + " form");
          if (valid) {
            form.removeClass('has_error');
          } else {
            form.addClass('has_error');
            question = form.find('#story_quiz_attributes_question, #museum_story_quiz_attributes_question');
            if (question.val() === '') {
              question.addClass('ng-invalid');
            }
          }
          return true;
        };
      },
      link: function(scope, element, attrs) {
        var selector;
        selector = attrs['quizSwitch'];
        return $("#" + selector + "_enabled, #" + selector + "_disabled").change(function() {
          var elem;
          elem = $(this);
          if (elem.attr('id') === ("" + selector + "_enabled")) {
            $("label[for=" + selector + "_enabled]").text('Enabled');
            $("label[for=" + selector + "_disabled]").text('Disable');
            return true;
          } else {
            $("label[for=" + selector + "_disabled]").text('Disabled');
            $("label[for=" + selector + "_enabled]").text('Enable');
            return true;
          }
        });
      }
    };
  });

}).call(this);
