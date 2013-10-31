(function() {
  "use strict";
  var isSameLine, lastOfLine, tileGrid;

  Array.prototype.unique = function() {
    var a, i, j, l;
    a = [];
    l = this.length;
    i = 0;
    while (i < l) {
      j = i + 1;
      while (j < l) {
        if (this[i] === this[j]) {
          j = ++i;
        }
        j++;
      }
      a.push(this[i]);
      i++;
    }
    return a;
  };

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
      "video": ["mp4", "m4v", "avi", "ogv"]
    },
    "development": false
  };

  angular.module("Museum.controllers", []).controller('IndexController', [
    '$scope', '$http', '$filter', '$window', '$modal', '$routeParams', '$location', 'ngProgress', 'storySetValidation', 'errorProcessing', function($scope, $http, $filter, $window, $modal, $routeParams, $location, ngProgress, storySetValidation, errorProcessing) {
      var content_provider_id, dropDown, findActive, get_lang, get_name, get_number, get_state, museum_id;
      window.sc = $scope;
      console.log($routeParams, $location);
      $scope.exhibit_search = '';
      $scope.criteriaMatch = function(criteria) {
        return function(item) {
          var in_string, number_is, result;
          if (item.stories[$scope.current_museum.language] != null) {
            if (item.stories[$scope.current_museum.language].name) {
              in_string = item.stories[$scope.current_museum.language].name.toLowerCase().indexOf(criteria.toLowerCase()) > -1;
              number_is = parseInt(item.number, 10) === (parseInt(criteria, 10));
              result = in_string || criteria === '' || number_is;
              console.log(result, number_is, criteria === '', in_string);
              if (result) {
                $scope.grid();
              }
              return result;
            } else {
              return true;
            }
          } else {
            return true;
          }
        };
      };
      $scope.statusMatch = function() {
        return function(item) {
          if (item.stories[$scope.current_museum.language] != null) {
            if (item.stories[$scope.current_museum.language].status && $scope.exhibits_visibility_filter) {
              if (item.stories[$scope.current_museum.language].status === $scope.exhibits_visibility_filter) {
                return true;
              } else {
                return false;
              }
            } else {
              return true;
            }
          } else {
            return true;
          }
        };
      };
      $scope.museum_change_progress = true;
      ngProgress.color('#fd6e3b');
      museum_id = $location.$$path != null ? $location.$$path.split('/')[1] : "526e1baa0439f8b01a000002";
      content_provider_id = $routeParams.content_provider_id != null ? $routeParams.content_provider_id : "526e1baa0439f8b01a000001";
      $scope.backend_url = "http://prototype.izi.travel/api";
      $scope.sort_field = 'number';
      $scope.sort_direction = 1;
      $scope.sort_text = 'Sort 0-9';
      $scope.ajax_progress = true;
      $scope.story_subtab = 'video';
      $scope.story_tab = 'main';
      $scope.museum_tab = 'main';
      $scope.museum_subtab = 'video';
      $scope.reload_exhibits = function(sort_field, sort_direction) {
        if (sort_field == null) {
          sort_field = $scope.sort_field;
        }
        if (sort_direction == null) {
          sort_direction = $scope.sort_direction;
        }
        return $http.get("" + $scope.backend_url + "/provider/" + content_provider_id + "/museums/" + museum_id + "/exhibits/" + sort_field + "/" + sort_direction).success(function(data) {
          var exhibit, exhibits, image, item, story, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
          exhibits = [];
          $scope.modal_translations = {};
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            if (item != null) {
              exhibit = item.exhibit;
              exhibit.images = [];
              exhibit.cover = {};
              _ref = item.images;
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                image = _ref[_j];
                exhibit.images.push(image);
                if (image.cover === true) {
                  exhibit.cover = image;
                }
              }
              exhibit.stories = {};
              _ref1 = item.stories;
              for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                story = _ref1[_k];
                story.story.quiz = story.quiz.quiz;
                story.story.audio = story.audio;
                story.story.video = story.video;
                story.story.quiz.answers = story.quiz.answers;
                exhibit.stories[story.story.language] = story.story;
                $scope.modal_translations[story.story.language] = {
                  name: $scope.translations[story.story.language]
                };
              }
              exhibits.push(exhibit);
            }
          }
          ngProgress.complete();
          console.log('anim completed');
          $scope.active_exhibit = exhibits[0];
          $scope.exhibits = exhibits;
          $scope.ajax_progress = false;
          if (exhibits.length === 0) {
            $scope.active_exhibit = {
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
            };
          }
          return $scope.museum_change_progress = false;
        });
      };
      $scope.reload_museums = function() {
        ngProgress.start();
        console.log('anim started');
        return $http.get("" + $scope.backend_url + "/provider/" + content_provider_id + "/museums").success(function(data) {
          var found, image, item, museum, story, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
          $scope.museums = [];
          found = false;
          $scope.langs = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            museum = item.exhibit;
            museum.def_lang = "ru";
            if (museum.language == null) {
              museum.language = "ru";
            }
            museum.package_status = "process";
            museum.stories = {};
            museum.images = [];
            museum.cover = {};
            _ref = item.images;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              image = _ref[_j];
              museum.images.push(image);
              if (image.cover === true) {
                museum.cover = image;
              }
            }
            _ref1 = item.stories;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              story = _ref1[_k];
              story.story.city = "Saint-Petersburg";
              story.story.quiz = story.quiz.quiz;
              story.story.audio = story.audio;
              story.story.video = story.video;
              story.story.quiz.answers = story.quiz.answers;
              museum.stories[story.story.language] = story.story;
              $scope.langs.push(story.story.language);
            }
            $scope.museums.push(museum);
            museum.active = false;
            if (museum._id === museum_id) {
              museum.active = true;
              $scope.current_museum = museum;
              found = true;
            }
          }
          if (!found) {
            $scope.current_museum = $scope.museums[0];
            $scope.current_museum.def_lang = "ru";
            if (museum.language == null) {
              $scope.current_museum.language = "ru";
            }
            museum_id = $scope.current_museum._id;
          }
          $scope.form_translations();
          return $scope.reload_exhibits();
        });
      };
      $scope.reload_museum = function() {
        return $http.get("" + $scope.backend_url + "/provider/" + content_provider_id + "/museums/" + museum_id).success(function(data) {
          var museum, story, _i, _len, _ref;
          museum = data.exhibit;
          museum.def_lang = "ru";
          museum.language = "ru";
          museum.stories = {};
          _ref = data.stories;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            story = _ref[_i];
            story.story.quiz = story.quiz.quiz;
            story.story.quiz.answers = story.quiz.answers;
            story.story.images = story.images;
            story.story.audio = story.audio;
            museum.stories[story.story.language] = story.story;
          }
          return $scope.current_museum = museum;
        });
      };
      $scope.reload_museums();
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
        es: 'Spanish',
        ge: 'German',
        fi: 'Finnish',
        sw: 'Sweedish',
        it: 'Italian',
        fr: 'French',
        kg: 'Klingon'
      };
      $scope.modal_translations = {
        ru: {
          name: 'Russian'
        },
        en: {
          name: 'English'
        },
        es: {
          name: 'Spanish'
        },
        ge: {
          name: 'German'
        },
        fi: {
          name: 'Finnish'
        },
        sw: {
          name: 'Sweedish'
        },
        it: {
          name: 'Italian'
        },
        fr: {
          name: 'French'
        },
        kg: {
          name: 'Klingon'
        }
      };
      $scope.exhibits = [
        {
          index: 0,
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
          number: '1',
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
          publish_state: 'all',
          long_description: '',
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
              long_description: 'test description',
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
            },
            en: {
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
              long_description: 'test description',
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
            },
            es: {
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
              long_description: 'test description',
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
        }
      ];
      $scope.active_exhibit = $scope.exhibits[0];
      $scope.current_museum = {
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
            long_description: '',
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
            long_description: '',
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
            long_description: '',
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
      };
      $scope.element_switch = true;
      $scope.forbid_switch = false;
      $scope.create_new_language = false;
      $scope.form_translations = function() {
        var lang, _i, _len, _ref, _results;
        $scope.langs = $scope.langs.unique();
        $scope.modal_translations = {};
        _ref = $scope.langs;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          lang = _ref[_i];
          _results.push($scope.modal_translations[lang] = {
            name: $scope.translations[lang]
          });
        }
        return _results;
      };
      dropDown = $('#drop_down').removeClass('hidden').hide();
      findActive = function() {
        return $('ul.exhibits li.exhibit.active');
      };
      $scope.dummy_focusout_process = function(active) {
        var field, remove, _i, _len, _ref;
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
            return $scope.new_item_creation = false;
          } else {
            return $scope.dummy_modal_open();
          }
        }
      };
      $scope.closeDropDown = function() {
        var active;
        console.log('closing');
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
        var clicked, delete_story, exhibit, item_publish_settings, number, previous, _i, _len, _ref;
        clicked = $(event.target).parents('li');
        $scope.element_switch = true;
        if ($scope.forbid_switch === true) {
          event.stopPropagation();
          return false;
        }
        if (clicked.hasClass('active') && !$scope.new_item_creation) {
          $scope.closeDropDown();
          return false;
        }
        if ($scope.new_item_creation) {
          $scope.story_tab = 'main';
          if (findActive().length > 0) {
            $scope.closeDropDown();
          }
        }
        _ref = $scope.exhibits;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          exhibit = _ref[_i];
          if (exhibit != null) {
            exhibit.active = false;
          }
        }
        elem.active = true;
        setTimeout(function() {
          return $scope.element_switch = false;
        }, 500);
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
      $scope.modal_options = {
        current_language: {
          name: $scope.translations[$scope.current_museum.language],
          language: $scope.current_museum.language
        },
        languages: $scope.modal_translations,
        exhibits: $scope.exhibits,
        deletion_password: '123456'
      };
      get_number = function() {
        var res;
        res = 0;
        if ($scope.exhibits[$scope.exhibits.length - 1]) {
          res = parseInt($scope.exhibits[$scope.exhibits.length - 1].number, 10) + 1;
        } else {
          res = 1;
        }
        return res;
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
      $scope.create_dummy_story = function(id) {
        var dummy_story, i, _i;
        dummy_story = {
          playback_algorithm: 'generic',
          content_provider: content_provider_id,
          story_type: 'story',
          status: 'draft',
          language: 'dummy',
          name: '',
          short_description: '',
          long_description: '',
          story_set: id
        };
        dummy_story.quiz = {
          story: "",
          question: '',
          comment: '',
          status: 'passcode',
          answers: []
        };
        for (i = _i = 0; _i <= 3; i = ++_i) {
          dummy_story.quiz.answers.push({
            quiz: "",
            content: '',
            correct: false
          });
        }
        dummy_story.quiz.answers[0].correct = true;
        return dummy_story;
      };
      $scope.new_museum_language = function() {
        var ModalMuseumInstance, dummy_story;
        $scope.create_new_language = true;
        dummy_story = $scope.create_dummy_story($scope.current_museum._id);
        dummy_story.quiz.answers[0].correct = true;
        $scope.dummy_museum = angular.copy($scope.current_museum);
        $scope.dummy_museum.stories.dummy = dummy_story;
        $scope.dummy_museum.stories.dummy.status = 'passcode';
        $scope.dummy_museum.language = 'dummy';
        $scope.modal_options = {
          museum: $scope.dummy_museum,
          translations: $scope.translations
        };
        ModalMuseumInstance = $modal.open({
          templateUrl: "myMuseumModalContent.html",
          controller: ModalMuseumInstanceCtrl,
          resolve: {
            modal_options: function() {
              return $scope.modal_options;
            }
          }
        });
        ModalMuseumInstance.result.then((function(result_string) {
          var lang, story;
          switch (result_string) {
            case 'save':
              true;
              console.log($scope.dummy_museum);
              lang = $scope.dummy_museum.language;
              $scope.dummy_museum.stories[lang] = $scope.dummy_museum.stories.dummy;
              $scope.dummy_museum.stories[lang].language = lang;
              story = $scope.dummy_museum.stories[lang];
              story.story_set = $scope.current_museum._id;
              return $scope.post_stories(story, 'uncommon', function(saved_story) {
                var exhibit, sub_story, _i, _len, _ref;
                saved_story.quiz = story.quiz;
                _ref = $scope.exhibits;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  exhibit = _ref[_i];
                  exhibit.stories[lang] = angular.copy(story);
                  exhibit.stories[lang].language = lang;
                  exhibit.stories[lang].name = "";
                  exhibit.stories[lang].status = 'draft';
                  exhibit.stories[lang].story_set = exhibit._id;
                  sub_story = angular.copy(exhibit.stories[lang]);
                  $scope.post_stories(sub_story, 'uncommon');
                }
                $scope.current_museum.stories[lang] = saved_story;
                $scope.modal_translations[lang] = {
                  name: $scope.translations[lang]
                };
                $scope.current_museum.language = lang;
                return $scope.create_new_language = false;
              });
            case 'discard':
              return true;
          }
        }), function() {
          return console.log("Modal dismissed at: " + new Date());
        });
        return true;
      };
      $scope.create_new_item = function() {
        var e, i, lang, number, _i;
        if ($scope.new_item_creation !== true) {
          number = get_number();
          $scope.new_exhibit = {
            content_provider: content_provider_id,
            number: number,
            type: 'exhibit',
            distance: 20,
            duration: 20,
            status: 'draft',
            route: '',
            category: '',
            parent: museum_id,
            name: '',
            qr_code: {
              url: '',
              print_link: ''
            },
            stories: {}
          };
          $scope.new_exhibit.images = [];
          for (lang in $scope.current_museum.stories) {
            $scope.new_exhibit.stories[lang] = {
              playback_algorithm: 'generic',
              content_provider: content_provider_id,
              story_type: 'story',
              status: 'draft',
              language: lang,
              name: '',
              short_description: '',
              long_description: '',
              story_set: ""
            };
            $scope.new_exhibit.stories[lang].quiz = {
              story: "",
              question: '',
              comment: '',
              status: 'passcode',
              answers: []
            };
            for (i = _i = 0; _i <= 3; i = ++_i) {
              $scope.new_exhibit.stories[lang].quiz.answers.push({
                quiz: "",
                content: '',
                correct: false
              });
            }
            $scope.new_exhibit.stories[lang].quiz.answers[0].correct = true;
          }
          $scope.new_item_creation = true;
          $scope.story_tab = 'main';
          e = {};
          e.target = $('li.exhibit.dummy > .opener.draft');
          console.log($('li.exhibit.dummy'));
          $scope.open_dropdown(e, $scope.new_exhibit);
          return $scope.grid();
        }
      };
      $scope.check_selected = function() {
        var count, exhibit, _i, _len, _ref;
        count = 0;
        $scope.select_all_enabled = false;
        _ref = $scope.exhibits;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          exhibit = _ref[_i];
          if (exhibit.selected === true) {
            $scope.select_all_enabled = true;
            count += 1;
          }
        }
        if (count === $scope.exhibits.length) {
          return $scope.all_selected = true;
        }
      };
      $scope.select_all_exhibits = function(option) {
        var exhibit, sign, _i, _len, _ref;
        if (option != null) {
          switch (option) {
            case 'select':
              sign = true;
              break;
            case 'cancel':
              sign = false;
          }
        } else {
          sign = !$scope.all_selected;
        }
        _ref = $scope.exhibits;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          exhibit = _ref[_i];
          exhibit.selected = sign;
        }
        $scope.all_selected = !$scope.all_selected;
        return $scope.select_all_enabled = sign;
      };
      $scope.delete_modal_open = function() {
        var ModalDeleteInstance;
        if (!$scope.new_item_creation) {
          $scope.modal_options = {
            current_language: {
              name: $scope.translations[$scope.current_museum.language],
              language: $scope.current_museum.language
            },
            languages: $scope.modal_translations,
            exhibits: $scope.exhibits,
            deletion_password: '123456'
          };
          ModalDeleteInstance = $modal.open({
            templateUrl: "myModalContent.html",
            controller: ModalDeleteInstanceCtrl,
            resolve: {
              modal_options: function() {
                return $scope.modal_options;
              }
            }
          });
          return ModalDeleteInstance.result.then((function(result) {
            return $scope.delete_exhibit($scope.active_exhibit, result.selected);
          }), function() {
            return console.log("Modal dismissed at: " + new Date());
          });
        } else {
          return true;
        }
      };
      $scope.delete_museum_modal_open = function() {
        var museumDeleteInstance;
        if (!$scope.new_item_creation) {
          $scope.modal_options = {
            current_language: {
              name: $scope.translations[$scope.current_museum.language],
              language: $scope.current_museum.language
            },
            languages: $scope.modal_translations,
            exhibits: $scope.exhibits,
            deletion_password: '123456'
          };
          museumDeleteInstance = $modal.open({
            templateUrl: "museumDelete.html",
            controller: museumDeleteCtrl,
            resolve: {
              modal_options: function() {
                return $scope.modal_options;
              }
            }
          });
          return museumDeleteInstance.result.then((function(selected) {
            var exhibit, lang, museum, _i, _j, _len, _len1, _ref, _ref1;
            lang = $scope.current_museum.language;
            if (selected === 'lang') {
              delete $scope.modal_translations[lang];
              $scope.current_museum.language = $scope.current_museum.def_lang;
              _ref = $scope.exhibits;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                exhibit = _ref[_i];
                $scope.delete_story(exhibit.stories, lang, function(stories, lang) {
                  delete stories[lang];
                  return true;
                });
              }
              return $scope.delete_story($scope.current_museum.stories, lang, function(stories, lang) {
                delete stories[lang];
                return true;
              });
            } else {
              console.log('deleting museum story or whole museum');
              museum = $scope.current_museum;
              _ref1 = $scope.exhibits;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                exhibit = _ref1[_j];
                $scope.delete_story_set(exhibit);
              }
              return $scope.delete_story_set(museum);
            }
          }), function() {
            return console.log("Modal dismissed at: " + new Date());
          });
        } else {
          return true;
        }
      };
      $scope.delete_exhibit = function(target_exhibit, languages) {
        var exhibit, index, item, st_index, story, _i, _len, _ref, _ref1, _results, _results1;
        if (languages.length >= Object.keys(target_exhibit.stories).length) {
          $scope.closeDropDown();
          _ref = $scope.exhibits;
          _results = [];
          for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
            exhibit = _ref[index];
            if (exhibit._id === target_exhibit._id) {
              $scope.exhibits.splice(index, 1);
              $scope.grid();
              if (target_exhibit._id === $scope.active_exhibit._id) {
                $scope.active_exhibit = $scope.exhibits[0];
              }
              $scope.delete_story_set(target_exhibit);
              break;
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        } else {
          console.log(target_exhibit._id);
          _ref1 = target_exhibit.stories;
          _results1 = [];
          for (st_index in _ref1) {
            story = _ref1[st_index];
            _results1.push((function() {
              var _j, _len1, _results2;
              _results2 = [];
              for (_j = 0, _len1 = languages.length; _j < _len1; _j++) {
                item = languages[_j];
                if (item === st_index) {
                  target_exhibit.selected = false;
                  story = target_exhibit.stories[st_index];
                  story.status = 'draft';
                  story.name = '';
                  story.short_description = '';
                  story.long_description = '';
                  story.quiz.question = '';
                  story.quiz.comment = '';
                  story.quiz.status = '';
                  if (!story.quiz.answers) {
                    story.quiz.answers = [];
                  }
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
        var elem, museum_anim_in_progress;
        elem = $(event.target);
        if (!museum_anim_in_progress) {
          museum_anim_in_progress = true;
          elem.find('i').toggleClass("icon-chevron-down icon-chevron-up");
          $('.navigation .museum_edit').slideToggle(1000, "easeOutQuint");
          $scope.museum_edit_dropdown_opened = !$scope.museum_edit_dropdown_opened;
        }
        return false;
      };
      $scope.museum_edit_dropdown_close = function() {
        var e;
        e = {
          target: $('.museum_edit_opener')
        };
        if ($scope.museum_edit_dropdown_opened) {
          return $scope.show_museum_edit(e);
        }
      };
      $scope.update_story = function(story) {
        return $http.put("" + $scope.backend_url + "/story/" + story._id, story).success(function(data) {
          return $http.put("" + $scope.backend_url + "/quiz/" + story.quiz._id, story.quiz).success(function(data) {
            var answer, _i, _len, _ref, _results;
            _ref = story.quiz.answers;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              answer = _ref[_i];
              _results.push($scope.put_answers(answer));
            }
            return _results;
          }).error(function() {
            return errorProcessing.addError('Failed to update a quiz for story');
          });
        }).error(function() {
          return errorProcessing.addError('Failed update a story');
        });
      };
      $scope.put_answers = function(answer) {
        return $http.put("" + $scope.backend_url + "/quiz_answer/" + answer._id, answer).success(function(data) {
          return console.log('done');
        }).error(function() {
          return errorProcessing.addError('Failed to save quiz answer');
        });
      };
      $scope.post_stories = function(original_story, type, callback) {
        var story;
        if (type == null) {
          type = 'common';
        }
        story = type === 'common' ? original_story : angular.copy(original_story);
        return $http.post("" + $scope.backend_url + "/story/", story).success(function(data) {
          story._id = data._id;
          story.quiz.story = data._id;
          if (callback != null) {
            callback(data);
          }
          return $http.post("" + $scope.backend_url + "/quiz/", story.quiz).success(function(data) {
            var answer, _i, _len, _ref, _results;
            story.quiz._id = data.id;
            _ref = story.quiz.answers;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              answer = _ref[_i];
              answer.quiz = data._id;
              _results.push($scope.post_answers(answer));
            }
            return _results;
          }).error(function() {
            return errorProcessing.addError('Failed to save quiz for new story');
          });
        }).error(function() {
          return errorProcessing.addError('Failed to save new story');
        });
      };
      $scope.post_answers = function(answer) {
        return $http.post("" + $scope.backend_url + "/quiz_answer/", answer).success(function(data) {
          return answer._id = data._id;
        }).error(function() {
          return errorProcessing.addError('Failed to save quiz answer');
        });
      };
      $scope.mass_switch_pub = function(value) {
        var exhibit, validation_item, _i, _len, _ref, _results;
        _ref = $scope.exhibits;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          exhibit = _ref[_i];
          if (exhibit.selected === true && exhibit.stories[$scope.current_museum.language].status !== 'dummy') {
            validation_item = {};
            validation_item.item = exhibit.stories[$scope.current_museum.language];
            validation_item.root = exhibit;
            validation_item.field_type = 'story';
            validation_item.item.status = value;
            _results.push(storySetValidation.checkValidity(validation_item));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      $scope.delete_selected_exhibits = function() {
        var ModalDeleteInstance;
        $scope.modal_options = {
          current_language: {
            name: $scope.translations[$scope.current_museum.language],
            language: $scope.current_museum.language
          },
          languages: $scope.modal_translations,
          exhibits: $scope.exhibits,
          deletion_password: '123456'
        };
        ModalDeleteInstance = $modal.open({
          templateUrl: "myModalContent.html",
          controller: ModalDeleteInstanceCtrl,
          resolve: {
            modal_options: function() {
              return $scope.modal_options;
            }
          }
        });
        return ModalDeleteInstance.result.then((function(result) {
          var exhibit, _i, _len, _ref, _results;
          console.log(result.ids_to_delete);
          _ref = result.ids_to_delete;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            exhibit = _ref[_i];
            if (exhibit.selected === true) {
              exhibit.selected = false;
              _results.push($scope.delete_exhibit(exhibit, result.selected));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }), function() {
          return console.log("Modal dismissed at: " + new Date());
        });
      };
      $scope.delete_story = function(stories, lang, callback) {
        return $http["delete"]("" + $scope.backend_url + "/story/" + stories[lang]._id).success(function(data) {
          console.log(data);
          if (callback != null) {
            return callback(stories, lang);
          }
        }).error(function() {
          return errorProcessing.addError('Failed to delete story in languane: ' + $scope.translations[lang]);
        });
      };
      $scope.delete_story_set = function(target_exhibit) {
        return $http["delete"]("" + $scope.backend_url + "/story_set/" + target_exhibit._id + "/").success(function(data) {
          return console.log(data);
        }).error(function() {
          return errorProcessing.addError('Failed to delete exhibit with number' + target_exhibit.number);
        });
      };
      $scope.$watch('current_museum.language', function(newValue, oldValue) {
        console.log(newValue);
        if (newValue) {
          if (newValue !== 'dummy') {
            console.log('not dummy');
            if ($scope.current_museum._id) {
              return $http.put("" + $scope.backend_url + "/story_set/" + $scope.current_museum._id, $scope.current_museum).success(function(data) {
                console.log(data);
                return $scope.last_save_time = new Date();
              }).error(function(error) {
                return errorProcessing.addError('Failed to save museum language');
              });
            }
          } else {
            console.log('dummy');
            $scope.modal_options.current_language = {
              name: $scope.translations[$scope.current_museum.language],
              language: $scope.current_museum.language
            };
            return $scope.create_new_language = false;
          }
        }
      });
      $scope.$on('save_new_exhibit', function() {
        console.log('saving!');
        $scope.new_exhibit.stories[$scope.current_museum.language].status = 'passcode';
        $http.post("" + $scope.backend_url + "/story_set/", $scope.new_exhibit).success(function(data) {
          var lang, story, _ref;
          $scope.exhibits.push($scope.new_exhibit);
          $scope.new_exhibit._id = data._id;
          $scope.last_save_time = new Date();
          _ref = $scope.new_exhibit.stories;
          for (lang in _ref) {
            story = _ref[lang];
            story.publish_state = 'passcode';
            story.story_set = data._id;
            $scope.post_stories(story);
          }
          return dropDown.find('.item_publish_settings').show();
        }).error(function() {
          return errorProcessing.addError('Failed to save new exhibit');
        });
        $scope.new_item_creation = false;
        return $scope.$digest();
      });
      $scope.$on('changes_to_save', function(event, child_scope) {
        if (child_scope.item._id) {
          $http.put("" + $scope.backend_url + "/" + child_scope.field_type + "/" + child_scope.item._id, child_scope.item).success(function(data) {
            child_scope.satus = 'done';
            $scope.last_save_time = new Date();
            return console.log(data);
          }).error(function() {
            return errorProcessing.addError('Server error - Prototype error.');
          });
          return $scope.forbid_switch = false;
        }
      });
      $scope.$on('quiz_changes_to_save', function(event, child_scope, correct_item) {
        var sign, sub_item, _i, _len, _ref;
        _ref = child_scope.collection;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          sub_item = _ref[_i];
          sign = sub_item._id === correct_item._id ? true : false;
          sub_item.correct = sign;
          sub_item.correct_saved = sign;
          $http.put("" + $scope.backend_url + "/" + child_scope.field_type + "/" + sub_item._id, sub_item).success(function(data) {
            console.log(data);
            return $scope.last_save_time = new Date();
          }).error(function() {
            return errorProcessing.addError('Failed to update quiz');
          });
        }
        return $scope.forbid_switch = false;
      });
      $scope.$watch('current_museum.invalid', function(newValue, oldValue) {
        console.log(newValue != null, newValue);
        if ((newValue != null) && newValue) {
          setTimeout(function() {
            if (!$scope.museum_edit_dropdown_opened) {
              return $('.museum_edit_opener').click();
            }
          }, 10);
        }
        return true;
      });
      $scope.$watch(function() {
        return $location.path();
      }, function(newValue, oldValue) {
        var museum, _i, _len, _ref;
        if ((newValue != null) && newValue !== oldValue) {
          $scope.closeDropDown();
          $('.museum_navigation_menu').slideUp(300);
          ngProgress.complete();
          ngProgress.start();
          console.log('anim started');
          $scope.museum_change_progress = true;
          museum_id = newValue.split('/')[1];
          _ref = $scope.museums;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            museum = _ref[_i];
            if (museum._id === museum_id) {
              museum.active = true;
              $scope.current_museum = museum;
            } else {
              museum.active = false;
            }
          }
          return $scope.reload_exhibits();
        }
      });
      return $scope.$watch('museum_change_progress', function(newValue, oldValue) {
        if (newValue != null) {
          if (newValue) {
            $('.page-wrapper .page').fadeOut(300);
            return $('.page-preloader').fadeIn(300);
          } else {
            $('.page-wrapper .page').fadeIn(300);
            return $('.page-preloader').fadeOut(300);
          }
        }
      });
    }
  ]).controller('MuseumEditController', [
    '$scope', '$http', '$filter', '$window', '$modal', 'storage', function($scope, $http, $filter, $window, $modal, storage) {
      setTimeout(function() {
        $scope.$parent.museumQuizform = $scope.museumQuizform;
        return $scope = $scope.$parent;
      }, 100);
      $scope.$watch('current_museum.stories[current_museum.language].quiz', function(newValue, oldValue) {
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
      $scope.$watch('current_museum.stories[current_museum.language].quiz.question', function(newValue, oldValue) {
        if ($scope.museumQuizform != null) {
          if ($scope.museumQuizform.$valid) {
            return $scope.mark_quiz_validity($scope.museumQuizform.$valid);
          } else {
            return setTimeout(function() {
              $("#museum_story_quiz_disabled").click();
              return $scope.mark_quiz_validity($scope.museumQuizform.$valid);
            }, 10);
          }
        }
      });
      $scope.$watch(function() {
        return angular.toJson($scope.current_museum.stories[$scope.current_museum.language].quiz.answers);
      }, function(newValue, oldValue) {
        if ($scope.museumQuizform != null) {
          if ($scope.museumQuizform.$valid) {
            return $scope.mark_quiz_validity($scope.museumQuizform.$valid);
          } else {
            return setTimeout(function() {
              return $("#museum_story_quiz_disabled").click();
            }, 10);
          }
        }
      }, true);
      return true;
    }
  ]);

  this.ModalDeleteInstanceCtrl = function($scope, $modalInstance, modal_options) {
    $scope.modal_options = modal_options;
    $scope.deletion_password = '';
    console.log($scope.modal_options.languages);
    $scope.only_one = Object.keys($scope.modal_options.languages).length === 1;
    $scope.password_input_shown = false;
    $scope.ok = function() {
      var exhibit, language, result, value, _i, _len, _ref, _ref1;
      $scope.selected = [];
      $scope.ids_to_delete = [];
      _ref = $scope.modal_options.languages;
      for (language in _ref) {
        value = _ref[language];
        if (value.checked === true) {
          $scope.selected.push(language);
        }
      }
      _ref1 = modal_options.exhibits;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        exhibit = _ref1[_i];
        if (exhibit.selected === true) {
          $scope.ids_to_delete.push(exhibit);
        }
      }
      result = {
        ids_to_delete: $scope.ids_to_delete,
        selected: $scope.selected
      };
      if ($scope.ids_to_delete.length <= 1) {
        return $modalInstance.close(result);
      } else {
        $scope.password_input_shown = true;
        if ($scope.deletion_password === modal_options.deletion_password) {
          return $modalInstance.close(result);
        }
      }
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

  this.museumDeleteCtrl = function($scope, $modalInstance, modal_options) {
    $scope.modal_options = modal_options;
    $scope.deletion_password = '';
    $scope.variant = {
      checked: 'lang'
    };
    $scope.ok = function() {
      if ($scope.deletion_password === modal_options.deletion_password) {
        return $modalInstance.close($scope.variant.checked);
      }
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss();
    };
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

  this.ModalMuseumInstanceCtrl = function($scope, $modalInstance, modal_options) {
    $scope.museum = modal_options.museum;
    $scope.translations = modal_options.translations;
    $scope.discard = function() {
      return $modalInstance.close('discard');
    };
    return $scope.save_as = function() {
      return $modalInstance.close("save", $scope.museum);
    };
  };

}).call(this);
