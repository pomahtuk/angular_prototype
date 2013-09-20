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
          statuses: {},
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
                statuses: {},
                answers: [
                  {
                    title: 'yes',
                    correct: true,
                    statuses: {}
                  }, {
                    title: 'may be',
                    correct: false,
                    statuses: {}
                  }, {
                    title: 'who cares?',
                    correct: false,
                    statuses: {}
                  }, {
                    title: 'nope',
                    correct: false,
                    statuses: {}
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
          statuses: {},
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
                    correct: true
                  }, {
                    title: 'may be',
                    correct: false
                  }, {
                    title: 'who cares?',
                    correct: false
                  }, {
                    title: 'nope',
                    correct: false
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
          statuses: {},
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
                    correct: true
                  }, {
                    title: 'may be',
                    correct: false
                  }, {
                    title: 'who cares?',
                    correct: false
                  }, {
                    title: 'nope',
                    correct: false
                  }
                ]
              }
            }
          ]
        }
      ];
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
      $scope.toggle_filters = function(elem) {
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
      return $scope.open_exhibit_dropdown = function(elem) {
        var exhibit, _i, _len, _ref;
        if (elem.active) {
          elem.active = false;
          return $scope.active_exhibit = null;
        } else {
          _ref = $scope.exhibits;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            exhibit = _ref[_i];
            exhibit.active = false;
          }
          elem.active = true;
          return sharedProperties.setProperty('exhibit', elem);
        }
      };
    }
  ]).controller('EditItemController', [
    '$scope', '$http', '$filter', 'sharedProperties', function($scope, $http, $filter, sharedProperties) {
      $scope.exhibit = sharedProperties.getProperty('exhibit');
      return $scope.$on('exhibitChange', function() {
        $scope.exhibit = sharedProperties.getProperty('exhibit');
        return console.log($scope.exhibit);
      });
    }
  ]);

}).call(this);
