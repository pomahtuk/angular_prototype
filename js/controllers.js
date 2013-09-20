(function() {
  "use strict";
  var isSameLine, lastOfLine, tileGrid;

  lastOfLine = function(elem) {
    var pred, top;
    elem = $(elem);
    top = elem.offset().top;
    pred = function() {
      return top < $(this).offset().top;
    };
    return $.merge(elem, elem.nextUntil(pred)).last();
  };

  isSameLine = function(x, y) {
    return x.length > 0 && y.length > 0 && x.offset().top === y.offset().top;
  };

  tileGrid = function(collection, tileWidth, tileSpace, tileListMargin) {
    var diff, lineSize, marginLeft, tileRealWidth, windowRealWidth, windowWidth;
    windowWidth = $(window).innerWidth();
    tileRealWidth = tileWidth + tileSpace;
    windowRealWidth = windowWidth - tileListMargin * 2 + tileSpace;
    lineSize = Math.floor(windowRealWidth / tileRealWidth);
    diff = windowWidth - (lineSize * tileRealWidth - tileSpace);
    marginLeft = Math.floor(diff / 2);
    collection.css({
      'margin-right': 0,
      'margin-left': tileSpace
    });
    return collection.each(function(i) {
      if (i % lineSize !== 0) {
        return;
      }
      return $(this).css({
        'margin-left': marginLeft
      });
    });
  };

  angular.module("Museum.controllers", []).controller('IndexController', [
    '$scope', '$http', '$filter', '$window', 'sharedProperties', function($scope, $http, $filter, $window, sharedProperties) {
      var attachDropDown, closeDropDown, dropDown, dummy_focusout_process, findActive;
      $scope.museums = [
        {
          name: 'Imperial Peace Museum',
          packege_status: 'generated',
          city: 'London',
          image: '/img/museum.jpg',
          type: 'museum'
        }, {
          name: 'Imperial War Museum',
          packege_status: 'generated',
          city: 'Tokio',
          image: '/img/museum.jpg',
          type: 'museum'
        }, {
          name: 'Imperial Peace Exhibitin',
          packege_status: 'generated',
          city: 'Moscow',
          image: '/img/museum.jpg',
          type: 'museum'
        }, {
          name: 'Imperial War Exhibitin',
          packege_status: 'generated',
          city: 'Berlin',
          image: '/img/museum.jpg',
          type: 'museum'
        }, {
          name: 'Republican Peace Museum',
          packege_status: 'process',
          city: 'Tokio',
          image: '/img/museum.jpg',
          type: 'tour'
        }, {
          name: 'Republican Peace Exhibitin',
          packege_status: 'process',
          city: 'London',
          image: '/img/museum.jpg',
          type: 'tour'
        }, {
          name: 'Republican War Museum',
          packege_status: 'process',
          city: 'Berlin',
          image: '/img/museum.jpg',
          type: 'tour'
        }, {
          name: 'Republican War Exhibitin',
          packege_status: 'process',
          city: 'London',
          image: '/img/museum.jpg',
          type: 'museum'
        }
      ];
      $scope.current_museum = {
        language: 'ru',
        name: 'Museum of modern art',
        stories: [
          {
            name: 'Russian',
            language: 'ru'
          }, {
            name: 'Spanish',
            language: 'es'
          }, {
            name: 'English',
            language: 'en'
          }
        ],
        new_story_link: '/1/1/1/'
      };
      $scope.user = {
        mail: 'pman89@yandex.ru',
        providers: [
          {
            name: 'IZI.travel Test Provider'
          }, {
            name: 'IZI.travel Second Provider'
          }
        ]
      };
      $scope.provider = {
        name: 'content_1',
        id: '1',
        passcode: 'passcode',
        passcode_edit_link: '/1/pass/edit/'
      };
      $scope.exhibits = [
        {
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
          number: '1',
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
          publish_state: 'all',
          description: '',
          qr_code: {
            url: '/img/qr_code.png',
            print_link: 'http://localhost:8000/img/qr_code.png'
          },
          images: [
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }, {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ],
          stories: [
            {
              language: 'ru',
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
              description: 'test description',
              audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg',
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                answers: [
                  {
                    title: 'yes',
                    correct: false,
                    id: 0
                  }, {
                    title: 'may be',
                    correct: true,
                    id: 1
                  }, {
                    title: 'who cares?',
                    correct: false,
                    id: 2
                  }, {
                    title: 'nope',
                    correct: false,
                    id: 3
                  }
                ]
              }
            }
          ]
        }, {
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
          number: '1',
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
          publish_state: 'all',
          description: '',
          qr_code: {
            url: '/img/qr_code.png',
            print_link: 'http://localhost:8000/img/qr_code.png'
          },
          images: [
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }, {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ],
          stories: [
            {
              language: 'ru',
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
              description: 'test description',
              audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg',
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                answers: [
                  {
                    title: 'yes',
                    correct: true,
                    id: 0
                  }, {
                    title: 'may be',
                    correct: false,
                    id: 1
                  }, {
                    title: 'who cares?',
                    correct: false,
                    id: 2
                  }, {
                    title: 'nope',
                    correct: false,
                    id: 3
                  }
                ]
              }
            }
          ]
        }, {
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
          number: '1',
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
          statsu: 'draft',
          publish_state: 'all',
          description: '',
          qr_code: {
            url: '/img/qr_code.png',
            print_link: 'http://localhost:8000/img/qr_code.png'
          },
          images: [
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }, {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ],
          stories: [
            {
              language: 'ru',
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
              description: 'test description',
              audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg',
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                answers: [
                  {
                    title: 'yes',
                    correct: true,
                    id: 0
                  }, {
                    title: 'may be',
                    correct: false,
                    id: 1
                  }, {
                    title: 'who cares?',
                    correct: false,
                    id: 2
                  }, {
                    title: 'nope',
                    correct: false,
                    id: 3
                  }
                ]
              }
            }
          ]
        }
      ];
      dropDown = $('#drop_down').removeClass('hidden').hide();
      findActive = function() {
        return $('ul.exhibits li.exhibit.active');
      };
      dummy_focusout_process = function(active) {
        var field, number, remove, _i, _len, _ref;
        if (dropDown.find('#name').val() === '') {
          remove = true;
          _ref = dropDown.find('#media .form-control:not(#opas_number)');
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            field = _ref[_i];
            field = $(field);
            if (field.val() !== '') {
              remove = false;
            }
          }
          if (remove) {
            return active.remove();
          } else {
            number = active.data('number');
            $('ul.exhibits').append(modal_template(number));
            $('#dummyModal').modal({
              show: true,
              backdrop: 'static'
            });
            $('#dummyModal').find('.btn-default').click(function() {
              active.remove();
              return $('#dummyModal, .modal-backdrop').remove();
            });
            return $('#dummyModal').find('.btn-primary').click(function() {
              active.removeClass('dummy');
              dropDown.find('#name').val("item_" + number);
              active.find('.opener').removeClass('draft');
              return $('#dummyModal, .modal-backdrop').remove();
            });
          }
        }
      };
      closeDropDown = function() {
        var active;
        active = findActive();
        if (active.hasClass('dummy')) {
          dummy_focusout_process(active);
        }
        dropDown.hide();
        return active.removeClass('active');
      };
      attachDropDown = function(li) {
        var hasParent;
        li = $(li);
        hasParent = dropDown.hasClass('inited');
        dropDown.show().insertAfter(lastOfLine(li));
        if (!hasParent) {
          dropDown.addClass('inited');
          dropDown.find('a.done, .close').unbind('click').bind('click', function(e) {
            e.preventDefault();
            return closeDropDown();
          });
          dropDown.find('>.prev-ex').unbind('click').bind('click', function(e) {
            var active, prev;
            e.preventDefault();
            active = findActive();
            prev = active.prev('.exhibit');
            if (prev.attr('id') === 'drop_down') {
              prev = prev.prev();
            }
            if (prev.length > 0) {
              return prev.find('.opener .description').click();
            } else {
              return active.siblings('.exhibit').last().find('.opener').click();
            }
          });
          dropDown.find('>.next-ex').unbind('click').bind('click', function(e) {
            var active, next;
            e.preventDefault();
            active = findActive();
            next = active.next();
            if (next.attr('id') === 'drop_down') {
              next = next.next();
            }
            if (next.length > 0) {
              return next.find('.opener .description').click();
            } else {
              return active.siblings('.exhibit').first().find('.opener').click();
            }
          });
          dropDown.find('.label-content').unbind('click').bind('click', function(e) {
            var elem, parent;
            elem = $(this);
            parent = elem.parents('.dropdown-menu').prev('.dropdown-toggle');
            if (elem.hasClass('everyone')) {
              return parent.html("<div class='extra'><i class='icon-globe'></i></div> Published <span class='caret'></span>");
            } else {
              return parent.html("<div class='extra'><i class='icon-user'></i></div> Publish <span class='caret'></span>");
            }
          });
          dropDown.find('#delete_story input[type=radio]').unbind('change').bind('change', function() {
            var container, elem;
            elem = $(this);
            container = $('#delete_story');
            if (elem.attr('id') === 'lang_selected') {
              if (elem.is(':checked')) {
                return $('#delete_story .other_variants').slideDown(150);
              }
            } else {
              return $('#delete_story .other_variants').slideUp(150);
            }
          });
          $('#story_quiz_enabled, #story_quiz_disabled').unbind('change').bind('change', function() {
            var elem, quiz;
            elem = $(this);
            quiz = dropDown.find('.form-wrap');
            console.log(elem.val());
            if (elem.attr('id') === 'story_quiz_enabled') {
              $('label[for=story_quiz_enabled]').text('Enabled');
              $('label[for=story_quiz_disabled]').text('Disable');
              return true;
            } else {
              $('label[for=story_quiz_disabled]').text('Disabled');
              $('label[for=story_quiz_enabled]').text('Enable');
              return true;
            }
          });
          return dropDown.find('a.delete_story').unbind('click').bind('click', function(e) {
            var elem;
            elem = $(this);
            if (elem.hasClass('no_margin')) {
              e.preventDefault();
              e.stopPropagation();
              return closeDropDown();
            }
          });
        }
      };
      $scope.open_dropdown = function(event) {
        var clicked, close, delete_story, done, item_publish_settings, number, previous;
        clicked = $(event.target).parents('li');
        if (clicked.hasClass('active')) {
          closeDropDown();
          return false;
        }
        previous = findActive();
        if (previous.hasClass('dummy')) {
          dummy_focusout_process(previous);
        }
        previous.removeClass('active');
        clicked.addClass('active');
        dropDown.find('h2').text(clicked.find('h4').text());
        if (!isSameLine(clicked, previous)) {
          attachDropDown(clicked);
          $('body').scrollTo(clicked, 500, 150);
        }
        item_publish_settings = dropDown.find('.item_publish_settings');
        done = dropDown.find('.done');
        close = dropDown.find('.close');
        delete_story = dropDown.find('.delete_story');
        if (clicked.hasClass('dummy')) {
          number = clicked.data('number');
          $('#opas_number').val(number).blur();
          $('#name').focus();
          item_publish_settings.hide();
          done.hide();
          close.show();
          return delete_story.addClass('no_margin');
        } else {
          item_publish_settings.show();
          done.show();
          close.hide();
          return delete_story.removeClass('no_margin');
        }
      };
      $scope.museum_type_filter = '';
      $scope.grid = function() {
        var collection, tileListMargin, tileSpace, tileWidth;
        collection = $('.exhibits>li.exhibit');
        tileListMargin = 59;
        tileWidth = collection.width();
        tileSpace = parseInt(collection.css('margin-left')) + parseInt(collection.css('margin-right'));
        $('.exhibits').css({
          'text-align': 'left'
        });
        tileGrid(collection, tileWidth, tileSpace, tileListMargin);
        return $(window).resize(tileGrid.bind(this, collection, tileWidth, tileSpace, tileListMargin));
      };
      $scope.museum_list_prepare = function() {
        var count, list, row_count, width;
        list = $('ul.museum_list');
        count = list.find('li').length;
        width = $('body').width();
        row_count = (count * 150 + 160) / width;
        if (row_count > 1) {
          $('.museum_filters').show();
          return list.width(width - 200);
        } else {
          $('.museum_filters').hide();
          return list.width(width - 100);
        }
      };
      setTimeout(function() {
        $scope.grid();
        return $scope.museum_list_prepare();
      }, 100);
      sharedProperties.setProperty('exhibit', $scope.exhibits[0]);
      angular.element($window).bind("resize", function() {
        $scope.grid();
        return $scope.museum_list_prepare();
      });
      $('.museum_navigation_menu .search').click(function() {
        var elem;
        elem = $(this);
        elem.hide();
        return elem.next().show().children().first().focus();
      });
      $('.museum_navigation_menu .search_input input').blur(function() {
        var elem, parent;
        elem = $(this);
        parent = elem.parents('.search_input');
        return elem.animate({
          width: '150px'
        }, 150, function() {
          parent.hide();
          return parent.prev().show();
        });
      });
      $('.museum_navigation_menu .search_input input').focus(function() {
        var input, width;
        input = $(this);
        width = $('body').width() - 700;
        if (width > 150) {
          return input.animate({
            width: "" + width + "px"
          }, 300);
        }
      });
      $scope.toggle_menu = function(elem) {
        var museum_nav, nav, padding;
        elem = $(elem.target);
        museum_nav = $('.museum_navigation_menu');
        nav = $('.navigation');
        if (museum_nav.is(':visible')) {
          padding = elem.data('last-padding');
          museum_nav.slideUp(300);
          nav.addClass('navbar-fixed-top');
          return $('body').css({
            'padding-top': "" + padding
          });
        } else {
          padding = $('body').css('padding-top');
          elem.data('last-padding', padding);
          museum_nav.slideDown(300);
          nav.removeClass('navbar-fixed-top');
          return $('body').css({
            'padding-top': '0px'
          });
        }
      };
      return $scope.toggle_filters = function(elem) {
        var filters_bar, nav;
        elem = $(elem.target);
        filters_bar = $('.filters_bar');
        nav = $('.navigation');
        if (elem.hasClass('active')) {
          filters_bar.css({
            overflow: 'hidden'
          });
          filters_bar.animate({
            height: "0px"
          }, 200);
          elem.removeClass('active');
          if (nav.hasClass('navbar-fixed-top')) {
            return $('body').animate({
              'padding-top': '-=44px'
            }, 200);
          }
        } else {
          filters_bar.animate({
            height: "44px"
          }, 200, function() {
            return filters_bar.css({
              overflow: 'visible'
            });
          });
          if (nav.hasClass('navbar-fixed-top')) {
            $('body').animate({
              'padding-top': '+=44px'
            }, 200);
          }
          return elem.addClass('active');
        }
      };
    }
  ]).controller('EditItemController', [
    '$scope', '$http', '$filter', 'sharedProperties', function($scope, $http, $filter, sharedProperties) {
      $scope.exhibit = sharedProperties.getProperty('exhibit');
      return $scope.$on('exhibitChange', function() {
        return $scope.exhibit = sharedProperties.getProperty('exhibit');
      });
    }
  ]);

}).call(this);
