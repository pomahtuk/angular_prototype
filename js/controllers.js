(function() {
  "use strict";
  var isSameLine, lastOfLine, tileGrid;

  $.fn.refresh = function() {
    return $(this.selector);
  };

  $.fn.isEmpty = function() {
    return this.length === 0;
  };

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

  this.gon = {
    "google_api_key": "AIzaSyCPyGutBfuX48M72FKpF4X_CxxPadq6r4w",
    "acceptable_extensions": {
      "audio": ["mp3", "ogg", "aac", "wav", "amr", "3ga", "m4a", "wma", "mp4", "mp2", "flac"],
      "image": ["jpg", "jpeg", "gif", "png", "tiff", "bmp"],
      "video": ["mp4", "m4v"]
    },
    "development": false
  };

  angular.module("Museum.controllers", []).controller('IndexController', [
    '$scope', '$http', '$filter', '$window', '$modal', 'storage', '$routeParams', 'ngProgress', function($scope, $http, $filter, $window, $modal, storage, $routeParams, ngProgress) {
      var content_provider_id, dropDown, exhibit, findActive, get_index, get_lang, get_name, get_number, get_state, index, museum_id, _i, _len, _ref;
      window.sc = $scope;
      $scope.exhibit_search = '';
      $scope.criteriaMatch = function(criteria) {
        return function(item) {
          var in_string;
          if (item.stories[$scope.current_museum.language].name) {
            in_string = item.stories[$scope.current_museum.language].name.toLowerCase().indexOf(criteria.toLowerCase()) > -1;
            $scope.grid();
            return in_string || criteria === '';
          } else {
            return true;
          }
        };
      };
      museum_id = $routeParams.museum_id != null ? $routeParams.museum_id : "52485ff1da0484df71000002";
      content_provider_id = $routeParams.content_provider_id != null ? $routeParams.content_provider_id : "52485ff1da0484df71000001";
      $scope.backend_url = "http://192.168.216.128:3000";
      $scope.sort_field = 'number';
      $scope.sort_direction = 1;
      $scope.sort_text = 'Sort 0-9';
      $scope.ajax_progress = true;
      $scope.reload_exhibits = function(sort_field, sort_direction) {
        ngProgress.color('#fd6e3b');
        ngProgress.start();
        return $http.get("" + $scope.backend_url + "/provider/" + content_provider_id + "/museums/" + museum_id + "/exhibits/" + sort_field + "/" + sort_direction).success(function(data) {
          var exhibit, exhibits, item, story, _i, _j, _len, _len1, _ref;
          exhibits = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            exhibit = item.exhibit;
            exhibit.images = item.images;
            exhibit.stories = {};
            _ref = item.stories;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              story = _ref[_j];
              story.story.quiz = story.quiz.quiz;
              story.story.quiz.answers = story.quiz.answers;
              exhibit.stories[story.story.language] = story.story;
            }
            exhibits.push(exhibit);
          }
          ngProgress.complete();
          $scope.exhibits = exhibits;
          $scope.active_exhibit = $scope.exhibits[0];
          return $scope.ajax_progress = false;
        });
      };
      $scope.reload_exhibits($scope.sort_field, $scope.sort_direction);
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
      $scope.translations = {
        ru: 'Russian',
        en: 'English',
        es: 'Spanish'
      };
      storage.bind($scope, 'exhibits', {
        defaultValue: [
          {
            index: 0,
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
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 1,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }, {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 2,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }
            ],
            stories: {
              ru: {
                name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
                description: 'test description',
                publish_state: 'all',
                audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg',
                quiz: {
                  question: 'are you sure?',
                  description: 'can you tell me?',
                  state: 'published',
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
            }
          }, {
            index: 1,
            name: 'двунадесятыми праздниками',
            number: '2',
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
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 1,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }, {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 2,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }
            ],
            stories: {
              ru: {
                name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
                description: 'test description',
                audio: '',
                publish_state: 'all',
                quiz: {
                  question: 'are you sure?',
                  description: 'can you tell me?',
                  state: 'published',
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
            }
          }, {
            index: 2,
            name: 'Владимирская, с двунадесятыми',
            number: '3',
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
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 1,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }, {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 2,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }
            ],
            stories: {
              ru: {
                name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
                description: 'test description',
                audio: '',
                publish_state: 'all',
                quiz: {
                  question: 'are you sure?',
                  description: 'can you tell me?',
                  state: 'published',
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
            }
          }
        ]
      });
      storage.bind($scope, 'current_museum', {
        defaultValue: {
          language: 'ru',
          def_lang: 'ru',
          name: 'Museum of modern art',
          index: 2,
          number: 3,
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
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
              id: 1,
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }, {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
              id: 2,
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ],
          stories: {
            en: {
              name: 'English',
              language: 'en',
              publish_state: 'all',
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                state: 'published',
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
            },
            es: {
              name: 'Spanish',
              language: 'es',
              publish_state: 'all',
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                state: 'published',
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
            },
            ru: {
              name: 'Russian',
              language: 'ru',
              publish_state: 'all',
              audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg',
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                state: 'published',
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
          },
          new_story_link: '/1/1/1/'
        }
      });
      dropDown = $('#drop_down').removeClass('hidden').hide();
      if ($scope.exhibits != null) {
        _ref = $scope.exhibits;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          exhibit = _ref[index];
          if (exhibit != null) {
            exhibit.active = false;
            exhibit.selected = false;
          } else {
            $scope.exhibits.splice(index, 1);
          }
        }
        $scope.active_exhibit = $scope.exhibits[0];
      }
      findActive = function() {
        return $('ul.exhibits li.exhibit.active');
      };
      $scope.dummy_focusout_process = function(active) {
        var field, remove, _j, _len1, _ref1;
        if (dropDown.find('#name').val() === '') {
          remove = true;
          _ref1 = dropDown.find('#media .form-control:not(#opas_number)');
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            field = _ref1[_j];
            field = $(field);
            if (field.val() !== '') {
              remove = false;
            }
          }
          if (remove) {
            return $scope.new_item_creation = false;
          } else {
            return $scope.dummy_modal_open();
          }
        }
      };
      $scope.closeDropDown = function() {
        var active;
        active = findActive();
        if (active.hasClass('dummy')) {
          $scope.dummy_focusout_process(active);
        }
        dropDown.hide();
        return active.removeClass('active');
      };
      $scope.attachDropDown = function(li) {
        var hasParent;
        li = $(li);
        hasParent = dropDown.hasClass('inited');
        dropDown.show().insertAfter(lastOfLine(li));
        if (!hasParent) {
          dropDown.addClass('inited');
          dropDown.find('a.done, .close').unbind('click').bind('click', function(e) {
            e.preventDefault();
            return $scope.closeDropDown();
          });
          dropDown.find('>.prev-ex').unbind('click').bind('click', function(e) {
            var active, prev;
            e.preventDefault();
            active = findActive();
            prev = active.prev('.exhibit');
            if (prev.attr('id') === 'drop_down' || prev.hasClass('dummy')) {
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
            if (next.attr('id') === 'drop_down' || next.hasClass('dummy')) {
              next = next.next();
            }
            if (next.length > 0) {
              return next.find('.opener .description').click();
            } else {
              return active.siblings('.exhibit').first().find('.opener').click();
            }
          });
          $('#story_quiz_enabled, #story_quiz_disabled').unbind('change').bind('change', function() {
            var elem, quiz;
            elem = $(this);
            quiz = dropDown.find('.form-wrap');
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
              return $scope.closeDropDown();
            }
          });
        }
      };
      $scope.open_dropdown = function(event, elem) {
        var clicked, delete_story, item_publish_settings, number, previous, _j, _len1, _ref1;
        clicked = $(event.target).parents('li');
        if (clicked.hasClass('active')) {
          $scope.closeDropDown();
          return false;
        }
        _ref1 = $scope.exhibits;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          exhibit = _ref1[_j];
          if (exhibit != null) {
            exhibit.active = false;
          }
        }
        elem.active = true;
        $scope.element_switch = true;
        $scope.active_exhibit = elem;
        previous = findActive();
        if (previous.hasClass('dummy')) {
          $scope.dummy_focusout_process(previous);
        }
        previous.removeClass('active');
        clicked.addClass('active');
        if (!isSameLine(clicked, previous)) {
          $scope.attachDropDown(clicked);
          setTimeout(function() {
            return $.scrollTo(clicked, 500);
          }, 100);
        }
        item_publish_settings = dropDown.find('.item_publish_settings');
        delete_story = dropDown.find('.delete_story');
        if (clicked.hasClass('dummy')) {
          number = clicked.data('number');
          $('#opas_number').val(number).blur();
          $('#name').focus();
          item_publish_settings.hide();
          return delete_story.addClass('no_margin');
        } else {
          item_publish_settings.show();
          return delete_story.removeClass('no_margin');
        }
      };
      $scope.museum_type_filter = '';
      $scope.grid = function() {
        var collection, tileListMargin, tileSpace, tileWidth;
        collection = $('.exhibits>li.exhibit');
        tileListMargin = 60;
        tileWidth = collection.first().width();
        tileSpace = 40;
        return tileGrid(collection, tileWidth, tileSpace, tileListMargin);
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
        return $scope.museum_list_prepare();
      }, 200);
      $(window).resize(function() {
        return setTimeout(function() {
          return $scope.museum_list_prepare();
        }, 100);
      });
      $scope.new_item_creation = false;
      $scope.all_selected = false;
      get_number = function() {
        return ++$scope.exhibits[$scope.exhibits.length - 1].number + 1 || 100;
      };
      get_index = function() {
        return ++$scope.exhibits.length;
      };
      get_lang = function() {
        return $scope.current_museum.language;
      };
      get_state = function(lang) {
        if (lang === $scope.current_museum.language) {
          return 'passcode';
        } else {
          return 'dummy';
        }
      };
      get_name = function(lang) {
        if (lang === $scope.current_museum.language) {
          return 'Экспонат_' + lang;
        } else {
          return '';
        }
      };
      $scope.create_new_item = function() {
        var e, i, lang, _j;
        if ($scope.new_item_creation !== true) {
          $scope.new_exhibit = {
            content_provider: content_provider_id,
            type: 'exhibit',
            distance: 20,
            duration: 20,
            status: 'draft',
            route: '',
            category: '',
            parent: museum_id,
            name: '',
            number: get_number(),
            qr_code: {
              url: '',
              print_link: ''
            },
            stories: {}
          };
          $scope.new_exhibit.images = [
            {
              image: "http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg",
              parent: "52472b44774dd1e650000069",
              thumb: "http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg"
            }
          ];
          for (lang in $scope.current_museum.stories) {
            $scope.new_exhibit.stories[lang] = {
              playback_algorithm: 'generic',
              content_provider: content_provider_id,
              story_type: 'story',
              status: 'passcode',
              language: lang,
              name: '',
              short_description: '',
              long_description: '',
              story_set: "52472b44774dd1e650000069"
            };
            $scope.new_exhibit.stories[lang].quiz = {
              story: "52472b44774dd1e650000069",
              question: '',
              comment: '',
              status: 'passcode',
              answers: []
            };
            for (i = _j = 0; _j <= 3; i = ++_j) {
              $scope.new_exhibit.stories[lang].quiz.answers.push({
                quiz: "52472b44774dd1e650000069",
                content: '',
                correct: false
              });
            }
          }
          $scope.new_item_creation = true;
          e = {};
          e.target = $('li.exhibit.dummy > .opener.draft');
          $scope.open_dropdown(e, $scope.new_exhibit);
          $scope.grid();
          return $scope.exhibits.splice($scope.exhibits.length - 1, 1);
        }
      };
      $scope.modal_options = {
        current_language: {
          name: 'Russian',
          language: 'ru'
        },
        languages: $scope.current_museum.stories
      };
      $scope.check_selected = function() {
        var count, _j, _len1, _ref1;
        count = 0;
        $scope.select_all_enabled = false;
        _ref1 = $scope.exhibits;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          exhibit = _ref1[_j];
          if (exhibit.selected === true) {
            $scope.select_all_enabled = true;
            count += 1;
          }
        }
        if (count === $scope.exhibits.length) {
          return $scope.all_selected = true;
        }
      };
      $scope.select_all_exhibits = function() {
        var sign, _j, _len1, _ref1;
        sign = !$scope.all_selected;
        _ref1 = $scope.exhibits;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          exhibit = _ref1[_j];
          exhibit.selected = sign;
        }
        $scope.all_selected = !$scope.all_selected;
        return $scope.select_all_enabled = sign;
      };
      $scope.delete_modal_open = function() {
        var ModalDeleteInstance;
        ModalDeleteInstance = $modal.open({
          templateUrl: "myModalContent.html",
          controller: ModalDeleteInstanceCtrl,
          resolve: {
            modal_options: function() {
              return $scope.modal_options;
            }
          }
        });
        return ModalDeleteInstance.result.then((function(selected) {
          var item, st_index, story, _j, _len1, _ref1, _ref2, _results, _results1;
          $scope.selected = selected;
          if (Object.keys($scope.active_exhibit.stories).length === selected.length) {
            $scope.closeDropDown();
            _ref1 = $scope.exhibits;
            _results = [];
            for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
              exhibit = _ref1[index];
              if (exhibit._id === $scope.active_exhibit._id) {
                $scope.exhibits.splice(index, 1);
                $scope.grid();
                $http["delete"]("" + $scope.backend_url + "/story_set/" + $scope.active_exhibit._id + "/").success(function(data) {
                  console.log(data);
                  return $scope.active_exhibit = $scope.exhibits[0];
                }).error(function() {
                  return console.log('error');
                });
                break;
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          } else {
            _ref2 = $scope.active_exhibit.stories;
            _results1 = [];
            for (st_index in _ref2) {
              story = _ref2[st_index];
              _results1.push((function() {
                var _k, _len2, _results2;
                _results2 = [];
                for (_k = 0, _len2 = selected.length; _k < _len2; _k++) {
                  item = selected[_k];
                  if (item === st_index) {
                    story = $scope.active_exhibit.stories[st_index];
                    story.status = 'dummy';
                    story.name = '';
                    story.short_description = '';
                    story.long_description = '';
                    story.quiz.question = '';
                    story.quiz.comment = '';
                    story.quiz.status = '';
                    story.quiz.answers[0].content = '';
                    story.quiz.answers[0].correct = true;
                    story.quiz.answers[1].content = '';
                    story.quiz.answers[1].correct = false;
                    story.quiz.answers[2].content = '';
                    story.quiz.answers[2].correct = false;
                    story.quiz.answers[3].content = '';
                    story.quiz.answers[3].correct = false;
                    _results2.push($scope.update_story(story));
                  } else {
                    _results2.push(void 0);
                  }
                }
                return _results2;
              })());
            }
            return _results1;
          }
        }), function() {
          return console.log("Modal dismissed at: " + new Date());
        });
      };
      $scope.dummy_modal_open = function() {
        var ModalDummyInstance;
        ModalDummyInstance = $modal.open({
          templateUrl: "myDummyModalContent.html",
          controller: ModalDummyInstanceCtrl,
          resolve: {
            modal_options: function() {
              return {
                exhibit: $scope.active_exhibit
              };
            }
          }
        });
        return ModalDummyInstance.result.then((function(result_string) {
          $scope.new_item_creation = false;
          $scope.item_deletion = true;
          if (result_string === 'save_as') {
            $scope.new_exhibit.stories[$scope.current_museum.language].name = "item_" + $scope.new_exhibit.number;
            $scope.new_exhibit.stories[$scope.current_museum.language].publish_state = "passcode";
            $scope.new_exhibit.active = false;
            $scope.exhibits.push($scope.new_exhibit);
          } else {
            $scope.closeDropDown();
            $scope.new_exhibit.active = false;
            $scope.active_exhibit = $scope.exhibits[0];
          }
          return $scope.item_deletion = false;
        }), function() {
          return console.log("Modal dismissed at: " + new Date());
        });
      };
      $scope.show_museum_edit = function(event) {
        var elem;
        elem = $(event.target);
        $('.navigation .museum_edit, .page .museum_edit_guaranter').slideToggle(1000, "easeOutQuint");
        elem.find('i').toggleClass("icon-chevron-down icon-chevron-up");
        $scope.museum_edit_dropdown_opened = !$scope.museum_edit_dropdown_opened;
        return false;
      };
      $scope.museum_edit_dropdown_close = function() {
        return setTimeout(function() {
          return $('.actions_bar .museum_edit_opener').click();
        }, 10);
      };
      $scope.update_story = function(story) {
        return $http.put("" + $scope.backend_url + "/story/" + story._id, story).success(function(data) {
          return $http.put("" + $scope.backend_url + "/quiz/" + story.quiz._id, story.quiz).success(function(data) {
            var answer, _j, _len1, _ref1, _results;
            _ref1 = story.quiz.answers;
            _results = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              answer = _ref1[_j];
              _results.push($scope.put_answers(answer));
            }
            return _results;
          }).error(function() {
            return console.log('error');
          });
        }).error(function() {
          return console.log('error');
        });
      };
      $scope.put_answers = function(answer) {
        return $http.put("" + $scope.backend_url + "/quiz_answer/" + answer._id, answer).success(function(data) {
          return console.log('done');
        }).error(function() {
          return console.log('error');
        });
      };
      $scope.museum_edit_dropdown_close = function() {
        return setTimeout(function() {
          return $('.actions_bar .museum_edit_opener').click();
        }, 10);
      };
      $scope.post_stories = function(story) {
        return $http.post("" + $scope.backend_url + "/story/", story).success(function(data) {
          story._id = data._id;
          story.quiz.story = data._id;
          return $http.post("" + $scope.backend_url + "/quiz/", story.quiz).success(function(data) {
            var answer, _j, _len1, _ref1, _results;
            story.quiz._id = data.id;
            _ref1 = story.quiz.answers;
            _results = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              answer = _ref1[_j];
              answer.quiz = data._id;
              _results.push($scope.post_answers(answer));
            }
            return _results;
          }).error(function() {
            return console.log('error');
          });
        }).error(function() {
          return console.log('error');
        });
      };
      $scope.post_answers = function(answer) {
        return $http.post("" + $scope.backend_url + "/quiz_answer/", answer).success(function(data) {
          return answer._id = data._id;
        }).error(function() {
          return console.log('error');
        });
      };
      $scope.$on('save_new_exhibit', function() {
        console.log('saving!');
        $http.post("" + $scope.backend_url + "/story_set/", $scope.new_exhibit).success(function(data) {
          var lang, media, story, _ref1, _results;
          $scope.exhibits.push($scope.new_exhibit);
          media = $scope.new_exhibit.images[0];
          media.parent = data._id;
          $http.post("" + $scope.backend_url + "/media/", media).success(function(data) {
            return media._id = media._id;
          }).error(function() {
            return console.log('error');
          });
          _ref1 = $scope.new_exhibit.stories;
          _results = [];
          for (lang in _ref1) {
            story = _ref1[lang];
            story.publish_state = 'passcode';
            story.story_set = data._id;
            _results.push($scope.post_stories(story));
          }
          return _results;
        }).error(function() {
          return console.log('fail');
        });
        return $scope.new_item_creation = false;
      });
      $scope.$on('changes_to_save', function(event, child_scope) {
        return $http.put("" + $scope.backend_url + "/" + child_scope.field_type + "/" + child_scope.item._id, child_scope.item).success(function(data) {
          child_scope.satus = 'done';
          return console.log(data);
        }).error(function() {
          return console.log('fail');
        });
      });
      $scope.$on('quiz_changes_to_save', function(event, child_scope, correct_item) {
        var sign, sub_item, _j, _len1, _ref1, _results;
        _ref1 = child_scope.collection;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          sub_item = _ref1[_j];
          sign = sub_item._id === correct_item._id ? true : false;
          sub_item.correct = sign;
          sub_item.correct_saved = sign;
          _results.push($http.put("" + $scope.backend_url + "/" + child_scope.field_type + "/" + sub_item._id, sub_item).success(function(data) {
            return console.log(data);
          }).error(function() {
            return console.log('fail');
          }));
        }
        return _results;
      });
      return $scope.populate_localstorage = function() {
        var i, lang, _j, _k, _len1, _ref1, _results;
        _ref1 = $scope.exhibits;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          exhibit = _ref1[_j];
          for (lang in $scope.current_museum.stories) {
            if (exhibit.stories[lang] == null) {
              exhibit.stories[lang] = {
                language: lang,
                name: '',
                description: '',
                audio: '',
                publish_state: 'dummy',
                quiz: {
                  question: '',
                  description: '',
                  state: '',
                  answers: [
                    {
                      title: '',
                      correct: false,
                      id: 0
                    }, {
                      title: '',
                      correct: true,
                      id: 1
                    }, {
                      title: '',
                      correct: false,
                      id: 2
                    }, {
                      title: '',
                      correct: false,
                      id: 3
                    }
                  ]
                }
              };
            }
          }
        }
        _results = [];
        for (i = _k = 0; _k <= 22; i = ++_k) {
          exhibit = {
            index: $scope.exhibits[$scope.exhibits.length - 1].index + 1,
            name: 'Экспонат',
            number: $scope.exhibits[$scope.exhibits.length - 1].index + 1,
            image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
            thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
            description: '',
            qr_code: {
              url: '/img/qr_code.png',
              print_link: 'http://localhost:8000/img/qr_code.png'
            },
            images: [
              {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 1,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }, {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                id: 2,
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }
            ]
          };
          exhibit.stories = {};
          for (lang in $scope.current_museum.stories) {
            exhibit.stories[lang] = {
              language: lang.language,
              name: get_name(lang),
              description: 'test description',
              audio: '',
              publish_state: get_state(lang),
              quiz: {
                question: 'are you sure?',
                description: 'can you tell me?',
                state: 'limited',
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
            };
          }
          _results.push($scope.exhibits.push(exhibit));
        }
        return _results;
      };
    }
  ]).controller('DropDownController', [
    '$scope', '$http', '$filter', '$window', '$modal', 'storage', '$rootScope', function($scope, $http, $filter, $window, $modal, storage, $rootScope) {
      $scope.quiz_state = function(form, item) {
        $scope.mark_quiz_validity(form.$valid);
        if (form.$valid) {
          setTimeout(function() {
            $http.put("" + $scope.backend_url + "/quiz/" + item._id, item).success(function(data) {
              return console.log(data);
            }).error(function() {
              return console.log('fail');
            });
            return true;
          }, 50);
        } else {
          setTimeout(function() {
            return $("#story_quiz_disabled").click();
          }, 300);
        }
        return true;
      };
      $scope.mark_quiz_validity = function(valid) {
        var form;
        form = $('#quiz form');
        if (valid) {
          form.removeClass('has_error');
        } else {
          form.addClass('has_error');
        }
        return true;
      };
      $scope.$watch('$parent.active_exhibit.stories[$parent.current_museum.language].quiz', function(newValue, oldValue) {
        if (newValue.status === 'published') {
          if ($("#story_quiz_enabled").is(':checked')) {
            return setTimeout(function() {
              if (!$scope.quizform.$valid) {
                return setTimeout(function() {
                  return $("#story_quiz_disabled").click();
                }, 10);
              }
            }, 100);
          } else {
            return setTimeout(function() {
              return $("#story_quiz_enabled").click();
            }, 10);
          }
        } else {
          if (!$("#story_quiz_disabled").is(':checked')) {
            return setTimeout(function() {
              return $("#story_quiz_disabled").click();
            }, 10);
          }
        }
      }, true);
      $scope.$watch('$parent.active_exhibit.stories[$parent.current_museum.language].quiz.question', function(newValue, oldValue) {
        if ($scope.quizform != null) {
          if ($scope.quizform.$valid) {
            return $scope.mark_quiz_validity($scope.quizform.$valid);
          } else {
            return setTimeout(function() {
              $("#story_quiz_disabled").click();
              return $scope.mark_quiz_validity($scope.quizform.$valid);
            }, 10);
          }
        }
      });
      $scope.$watch('$parent.active_exhibit.stories[$parent.current_museum.language].name', function(newValue, oldValue) {
        var form;
        form = $('#media form');
        if (form.length > 0) {
          if ($scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].status === 'dummy') {
            if (newValue) {
              return $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].status = 'passcode';
            }
          } else {
            if (!$scope.$parent.new_item_creation) {
              if (!newValue) {
                $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].name = oldValue;
                $('.empty_name_error.name').show();
                return setTimeout(function() {
                  return $('.empty_name_error.name').hide();
                }, 1500);
              }
            }
          }
        }
      });
      $scope.$watch('$parent.element_switch', function(newValue, oldValue) {
        if (newValue !== oldValue) {
          return setTimeout(function() {
            return $scope.$parent.element_switch = false;
          }, 100);
        }
      });
      $scope.$watch('$parent.active_exhibit.number', function(newValue, oldValue) {
        var form;
        form = $('#media form');
        if (form.length > 0) {
          if (!($scope.$parent.new_item_creation || $scope.$parent.item_deletion)) {
            if (!newValue) {
              $scope.$parent.active_exhibit.number = oldValue;
              $('.empty_name_error.number').show();
              return setTimeout(function() {
                return $('.empty_name_error.number').hide();
              }, 1500);
            }
          }
        }
      });
      $scope.$watch(function() {
        return angular.toJson($scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].quiz.answers);
      }, function(newValue, oldValue) {
        if ($scope.quizform != null) {
          if ($scope.quizform.$valid) {
            return $scope.mark_quiz_validity($scope.quizform.$valid);
          } else {
            return setTimeout(function() {
              return $("#story_quiz_disabled").click();
            }, 10);
          }
        }
      }, true);
      $scope.$watch('$parent.active_exhibit.stories[$parent.current_museum.language]', function(newValue, oldValue) {
        if (newValue) {
          if (!$scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].qr_code) {
            return $http.get("" + $scope.$parent.backend_url + "/qr_code/" + $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language]._id).success(function(d) {
              return $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].qr_code = d;
            });
          }
        }
      }, true);
      $scope.upload_image = function(e) {
        var elem, parent;
        e.preventDefault();
        elem = $(e.target);
        parent = elem.parents('.images');
        if (parent.find('li:hidden').isEmpty()) {
          $.ajax({
            url: elem.attr('href'),
            async: false,
            success: function(response) {
              return console.log(response);
            }
          });
        }
        return parent.find('li:hidden :file').click();
      };
      $scope.delete_image = function(e) {
        var elem, parent;
        e.preventDefault();
        e.stopPropagation();
        elem = $(e.target);
        parent = elem.parents('#images, #maps');
        if (confirm(elem.data('confirm'))) {
          return $.ajax({
            url: elem.attr('href'),
            type: elem.data('method'),
            data: {
              authentity_token: $('meta[name=csrf-token]').attr('content')
            },
            success: function() {
              var fadeTime;
              fadeTime = 200;
              if (parent.attr('id').match(/images/)) {
                return elem.parents('li').fadeOut(fadeTime, function() {
                  elem.remove();
                  return storySetImage.trigger('image:deleted');
                });
              } else {
                return elem.parents('li').fadeOut(fadeTime, function() {
                  return elem.remove();
                });
              }
            }
          });
        }
      };
      $scope.change_image = function(e) {
        var elem, form;
        elem = $(e.target);
        form = elem.parents('form');
        if (!elem.hasClass('disabled')) {
          return form.find(':file').trigger('click');
        }
      };
      return true;
    }
  ]).controller('MuseumEditController', [
    '$scope', '$http', '$filter', '$window', '$modal', 'storage', function($scope, $http, $filter, $window, $modal, storage) {
      $scope.museum_quiz_state = function(form) {
        $scope.mark_quiz_validity(form.$valid);
        if (!form.$valid) {
          setTimeout(function() {
            return $("#museum_story_quiz_disabled").click();
          }, 300);
        }
        return true;
      };
      $scope.mark_quiz_validity = function(valid) {
        var form;
        form = $('#museum_quiz form');
        if (valid) {
          form.removeClass('has_error');
        } else {
          form.addClass('has_error');
        }
        return true;
      };
      $scope.$watch('$parent.current_museum.stories[$parent.current_museum.language].quiz', function(newValue, oldValue) {
        if (newValue.state === 'limited') {
          if (!$("#museum_story_quiz_disabled").is(':checked')) {
            return setTimeout(function() {
              return $("#museum_story_quiz_disabled").click();
            }, 10);
          }
        } else if (newValue.state === 'published') {
          if ($("#museum_story_quiz_enabled").is(':checked')) {
            return setTimeout(function() {
              if (!$scope.museumQuizform.$valid) {
                return setTimeout(function() {
                  return $("#museum_story_quiz_disabled").click();
                }, 10);
              }
            }, 100);
          } else {
            return setTimeout(function() {
              return $("#museum_story_quiz_enabled").click();
            }, 10);
          }
        }
      }, true);
      $scope.$watch('$parent.current_museum.stories[$parent.current_museum.language].quiz.question', function(newValue, oldValue) {
        if ($scope.museumQuizform != null) {
          if ($scope.museumQuizform.$valid) {
            return $scope.mark_quiz_validity($scope.museumQuizform.$valid);
          } else {
            return setTimeout(function() {
              $("#story_quiz_disabled").click();
              return $scope.mark_quiz_validity($scope.museumQuizform.$valid);
            }, 10);
          }
        }
      });
      $scope.$watch(function() {
        return angular.toJson($scope.$parent.current_museum.stories[$scope.$parent.current_museum.language].quiz.answers);
      }, function(newValue, oldValue) {
        if ($scope.museumQuizform != null) {
          if ($scope.museumQuizform.$valid) {
            return $scope.mark_quiz_validity($scope.museumQuizform.$valid);
          } else {
            return setTimeout(function() {
              return $("#museum_#story_quiz_disabled").click();
            }, 10);
          }
        }
      }, true);
      return true;
    }
  ]);

  this.ModalDeleteInstanceCtrl = function($scope, $modalInstance, modal_options) {
    $scope.modal_options = modal_options;
    $scope.only_one = $scope.modal_options.languages.length === 1;
    $scope.ok = function() {
      var language, value, _ref;
      $scope.selected = [];
      _ref = $scope.modal_options.languages;
      for (language in _ref) {
        value = _ref[language];
        if (value.checked === true) {
          $scope.selected.push(language);
        }
      }
      return $modalInstance.close($scope.selected);
    };
    $scope.cancel = function() {
      return $modalInstance.dismiss();
    };
    $scope.mark_all = function() {
      var language, value, _ref, _results;
      _ref = $scope.modal_options.languages;
      _results = [];
      for (language in _ref) {
        value = _ref[language];
        _results.push(value.checked = true);
      }
      return _results;
    };
    $scope.mark_default_only = function() {
      var language, value, _ref, _results;
      _ref = $scope.modal_options.languages;
      _results = [];
      for (language in _ref) {
        value = _ref[language];
        value.checked = false;
        if ($scope.modal_options.current_language.language === language) {
          _results.push(value.checked = true);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    return $scope.mark_default_only();
  };

  this.ModalDummyInstanceCtrl = function($scope, $modalInstance, modal_options) {
    $scope.exhibit = modal_options.exhibit;
    $scope.discard = function() {
      return $modalInstance.close('discard');
    };
    return $scope.save_as = function() {
      return $modalInstance.close("save_as");
    };
  };

}).call(this);
