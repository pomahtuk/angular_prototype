(function() {
  "use strict";
  var acceptableExtensions, fileSizeMb, isSameLine, lastOfLine, tileGrid;

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

  fileSizeMb = 50;

  acceptableExtensions = gon.acceptable_extensions;

  this.correctExtension = function(object) {
    var extension;
    extension = object.files[0].name.split('.').pop().toLowerCase();
    return $.inArray(extension, acceptableExtensions[object.fileInput.context.dataset.accept]) !== -1;
  };

  this.correctFileSize = function(object) {
    return object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024;
  };

  this.initFileUpload = function(e, object, options) {
    if (object == null) {
      object = null;
    }
    if (options == null) {
      options = {};
    }
    console.log('inited');
    return (object || $('.fileupload')).each(function() {
      var $this, button, cancel, container, form, progress, upload;
      upload = null;
      $this = $(this);
      form = $this.parent('form');
      container = form.parent();
      button = form.find('a.btn.browse');
      cancel = form.find('a.btn.cancel');
      progress = options.progress || form.find('.progress');
      cancel.unbind('click');
      cancel.bind('click', function(e) {
        e.preventDefault();
        if (upload) {
          return upload.abort();
        }
      });
      return $this.fileupload({
        add: function(e, data) {
          if (correctExtension(data)) {
            if (correctFileSize(data)) {
              button.addClass('disabled');
              cancel.removeClass('hide');
              progress.removeClass('hide');
              data.form.find('.help-tooltip').remove();
              return data.submit();
            } else {
              return Message.error(t('message.errors.media_content.file_size', {
                file_size: fileSizeMb
              }));
            }
          } else {
            return Message.error(t('message.errors.media_content.file_type'));
          }
        },
        beforeSend: function(jqXHR) {
          progress.find('.bar').width('0%');
          return upload = jqXHR;
        },
        success: function(result) {
          container.replaceWith(result).hide().fadeIn(function() {
            return $('a.thumb').trigger('image:uploaded');
          });
          $('#edit_story_form').trigger('form:loaded');
          return Message.notice(t('message.media_content.uploaded'));
        },
        complete: function() {
          cancel.addClass('hide');
          progress.addClass('hide');
          return button.removeClass('disabled');
        },
        error: function(result, status, errorThrown) {
          var response, responseText;
          $this.val('');
          if (errorThrown === 'abort') {
            return Message.notice(t('message.media_content.canceled'));
          } else {
            if (result.status === 422) {
              response = jQuery.parseJSON(result.responseText);
              responseText = response.link[0];
              return Message.error(responseText);
            } else {
              return Message.error(t('message.errors.media_content.try_again'));
            }
          }
        },
        progressall: function(e, data) {
          var percentage;
          percentage = parseInt(data.loaded / data.total * 100, 10);
          return progress.find('.bar').width(percentage + '%');
        }
      });
    });
  };

  this.checkAudioFiles = function() {
    return $('#audio_form[data-audio-check-url]').each(function() {
      var $this, url;
      $this = $(this);
      url = $this.data('audio-check-url');
      return $.ajax({
        url: url,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
          return $.each(response, function(key, item) {
            var audio, audioElement, btn, canPlay;
            btn = $('.btn.' + key);
            if (item.exist) {
              audio = $this.find('.audio-upload-form').find('audio.' + key);
              audio.empty();
              $('<source>').attr('src', item.file).appendTo(audio);
              audioElement = audio.get(0);
              if (audioElement) {
                audioElement.pause();
                audioElement.load();
                canPlay = !!audioElement.canPlayType && audioElement.canPlayType(item.content_type) !== '';
                console.log(canPlay + ' - ' + item.content_type);
              }
              $('.play.' + key).find('i').removeClass('icon-pause').addClass('icon-play');
              if (canPlay) {
                return btn.removeClass('disabled hide');
              } else {
                return btn.addClass('disabled').removeClass('hide');
              }
            } else {
              return btn.addClass('disabled');
            }
          });
        },
        error: function() {
          return Message.notice(t('message.media_content.not_processed_yet'));
        }
      });
    });
  };

  angular.module("Museum.controllers", []).controller('IndexController', [
    '$scope', '$http', '$filter', '$window', '$modal', 'storage', function($scope, $http, $filter, $window, $modal, storage) {
      var dropDown, exhibit, findActive, get_index, get_lang, get_number, _i, _len, _ref;
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
                audio: '',
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
          name: 'Museum of modern art',
          stories: [
            {
              name: 'English',
              language: 'en'
            }, {
              name: 'Spanish',
              language: 'es'
            }, {
              name: 'Russian',
              language: 'ru'
            }
          ],
          new_story_link: '/1/1/1/'
        }
      });
      dropDown = $('#drop_down').removeClass('hidden').hide();
      _ref = $scope.exhibits;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        exhibit = _ref[_i];
        exhibit.active = false;
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
          dummy_focusout_process(active);
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
              return $scope.closeDropDown();
            }
          });
        }
      };
      $scope.open_dropdown = function(event, elem) {
        var clicked, close, delete_story, done, item_publish_settings, number, previous, _j, _len1, _ref1;
        clicked = $(event.target).parents('li');
        if (clicked.hasClass('active')) {
          $scope.closeDropDown();
          return false;
        }
        _ref1 = $scope.exhibits;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          exhibit = _ref1[_j];
          exhibit.active = false;
        }
        elem.active = true;
        $scope.active_exhibit = elem;
        previous = findActive();
        if (previous.hasClass('dummy')) {
          dummy_focusout_process(previous);
        }
        previous.removeClass('active');
        clicked.addClass('active');
        dropDown.find('h2').text(clicked.find('h4').text());
        if (!isSameLine(clicked, previous)) {
          $scope.attachDropDown(clicked);
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
        $scope.museum_list_prepare();
        return initFileUpload();
      }, 200);
      $scope.active_exhibit = $scope.exhibits[0];
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
      $scope.new_item_creation = false;
      get_number = function() {
        return ++$scope.exhibits[$scope.exhibits.length - 1].number + 1;
      };
      get_index = function() {
        return $scope.exhibits.length;
      };
      get_lang = function() {
        return $scope.current_museum.language;
      };
      $scope.create_new_item = function() {
        var e;
        if ($scope.new_item_creation !== true) {
          $scope.new_exhibit = {
            name: '',
            number: get_number(),
            index: get_index(),
            image: '/img/img-bg.png',
            thumb: '/img/img-bg.png',
            publish_state: 'draft',
            description: '',
            qr_code: {
              url: '',
              print_link: ''
            },
            images: [
              {
                image: '/img/img-bg.png',
                thumb: '/img/img-bg.png'
              }
            ]
          };
          $scope.new_exhibit.stories = {};
          $scope.new_exhibit.stories[$scope.current_museum.language] = {
            name: '',
            description: '',
            audio: '',
            quiz: {
              question: '',
              description: '',
              answers: [
                {
                  title: '',
                  correct: true,
                  id: 0
                }, {
                  title: '',
                  correct: false,
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
          $scope.new_item_creation = true;
          e = {};
          e.target = $('li.exhibit.dummy > .opener.draft');
          return $scope.open_dropdown(e, $scope.new_exhibit);
        }
      };
      $scope.modal_options = {
        current_language: {
          name: 'Russian',
          language: 'ru'
        },
        languages: $scope.current_museum.stories
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
          var item, st_index, story, _j, _len1, _ref1, _results;
          $scope.selected = selected;
          console.log(selected);
          _ref1 = $scope.active_exhibit.stories;
          _results = [];
          for (st_index = _j = 0, _len1 = _ref1.length; _j < _len1; st_index = ++_j) {
            story = _ref1[st_index];
            _results.push((function() {
              var _k, _len2, _results1;
              _results1 = [];
              for (_k = 0, _len2 = selected.length; _k < _len2; _k++) {
                item = selected[_k];
                if (story.language === item) {
                  if ($scope.active_exhibit.stories.length === 1) {
                    $scope.closeDropDown();
                    $scope.exhibits.splice($scope.active_exhibit.index, 1);
                    _results1.push($scope.active_exhibit = $scope.exhibits[0]);
                  } else {
                    _results1.push($scope.active_exhibit.stories[st_index] = {
                      language: get_lang(),
                      name: '',
                      description: '',
                      audio: '',
                      quiz: {
                        question: '',
                        description: '',
                        answers: [
                          {
                            title: '',
                            correct: true,
                            id: 0
                          }, {
                            title: '',
                            correct: false,
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
                    });
                  }
                } else {
                  _results1.push(void 0);
                }
              }
              return _results1;
            })());
          }
          return _results;
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
          if (result_string === 'save_as') {
            $scope.new_exhibit.publish_state = 'passcode';
            $scope.new_exhibit.name = "item_" + $scope.new_exhibit.number;
            $scope.new_exhibit.active = false;
            return $scope.exhibits.push($scope.new_exhibit);
          }
        }), function() {
          return console.log("Modal dismissed at: " + new Date());
        });
      };
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
      $scope.upload_image = function(e) {
        var elem, parent;
        console.log(e);
        e.preventDefault();
        elem = $(e.target);
        parent = elem.parents('#images, #maps');
        if (parent.find('li:hidden').isEmpty()) {
          $.ajax({
            url: elem.attr('href'),
            async: false,
            success: function(response) {
              var node;
              node = $(response).hide();
              parent.find('li.new').before(node);
              return initFileUpload(e, node.find('.fileupload'), {
                progress: elem.find('.progress')
              });
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
      $scope.$on('save_dummy', function() {
        $scope.new_exhibit.publish_state = 'passcode';
        $scope.exhibits.push($scope.new_exhibit);
        return $scope.new_item_creation = false;
      });
      return $scope.populate_localstorage = function() {
        var i, lang, _j, _k, _l, _len1, _len2, _len3, _m, _ref1, _ref2, _ref3, _results;
        _ref1 = $scope.exhibits;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          exhibit = _ref1[_j];
          _ref2 = $scope.current_museum.stories;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            lang = _ref2[_k];
            console.log(lang);
            if (exhibit.stories[lang.language] == null) {
              exhibit.stories[lang.language] = {
                language: lang.language,
                name: 'Экспонат_' + lang.language,
                description: 'test description',
                audio: '',
                publish_state: 'all',
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
              };
            }
            console.log(exhibit.stories[lang.language]);
          }
        }
        _results = [];
        for (i = _l = 0; _l <= 5; i = ++_l) {
          exhibit = {
            index: $scope.exhibits[$scope.exhibits.length - 1].index + 1,
            name: 'Экспонат',
            number: $scope.exhibits[$scope.exhibits.length - 1].index + 1,
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
            ]
          };
          exhibit.stories = {};
          _ref3 = $scope.current_museum.stories;
          for (_m = 0, _len3 = _ref3.length; _m < _len3; _m++) {
            lang = _ref3[_m];
            exhibit.stories[lang.language] = {
              language: lang.language,
              name: 'Экспонат_' + lang.language,
              description: 'test description',
              audio: '',
              publish_state: 'all',
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
            };
          }
          _results.push($scope.exhibits.push(exhibit));
        }
        return _results;
      };
    }
  ]);

  this.ModalDeleteInstanceCtrl = function($scope, $modalInstance, modal_options) {
    $scope.modal_options = modal_options;
    $scope.only_one = $scope.modal_options.languages.length === 1;
    $scope.ok = function() {
      var language, _i, _len, _ref;
      $scope.selected = [];
      _ref = $scope.modal_options.languages;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        language = _ref[_i];
        if (language.checked === true) {
          $scope.selected.push(language.language);
        }
      }
      return $modalInstance.close($scope.selected);
    };
    $scope.cancel = function() {
      return $modalInstance.dismiss();
    };
    $scope.mark_all = function() {
      var language, _i, _len, _ref, _results;
      _ref = $scope.modal_options.languages;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        language = _ref[_i];
        _results.push(language.checked = true);
      }
      return _results;
    };
    $scope.mark_default_only = function() {
      var language, _i, _len, _ref, _results;
      _ref = $scope.modal_options.languages;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        language = _ref[_i];
        language.checked = false;
        if ($scope.modal_options.current_language.language === language.language) {
          _results.push(language.checked = true);
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
