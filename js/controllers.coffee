"use strict"

$.fn.refresh = -> $(this.selector)
$.fn.isEmpty = -> @length == 0

lastOfLine = (elem) ->
  elem = $(elem)
  top  = elem.offset().top
  pred = ->
    top < $(@).offset().top

  $.merge(elem, elem.nextUntil(pred)).last()

isSameLine = (x, y) ->
  x.length > 0 && y.length > 0 && x.offset().top == y.offset().top

tileGrid = (collection, tileWidth, tileSpace, tileListMargin) ->
  windowWidth = $(window).innerWidth()
  tileRealWidth = tileWidth + tileSpace
  windowRealWidth = windowWidth - tileListMargin * 2 + tileSpace

  lineSize = Math.floor(windowRealWidth / tileRealWidth)
  diff = windowWidth - (lineSize * tileRealWidth - tileSpace)
  marginLeft = Math.floor(diff / 2)

  collection.css 'margin-right': 0, 'margin-left': tileSpace
  collection.each (i) ->
    return if i % lineSize != 0
    $(@).css 'margin-left': marginLeft

@gon = {"google_api_key":"AIzaSyCPyGutBfuX48M72FKpF4X_CxxPadq6r4w","acceptable_extensions":{"audio":["mp3","ogg","aac","wav","amr","3ga","m4a","wma","mp4","mp2","flac"],"image":["jpg","jpeg","gif","png","tiff","bmp"],"video":["mp4","m4v"]},"development":false}

fileSizeMb = 50
acceptableExtensions = gon.acceptable_extensions

@correctExtension = (object) ->
  extension = object.files[0].name.split('.').pop().toLowerCase()
  $.inArray(extension, acceptableExtensions[object.fileInput.context.dataset.accept]) != -1

@correctFileSize = (object) ->
  object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024

@initFileUpload = (e, object = null, options={}) ->
  console.log 'inited'
  (object || $('.fileupload')).each ->
    upload = null
    $this = $ this
    form = $this.parent('form')
    container = form.parent()
    button = form.find('a.btn.browse')
    cancel = form.find('a.btn.cancel')
    progress = options.progress || form.find('.progress')

    cancel.unbind 'click'
    cancel.bind 'click', (e) ->
      e.preventDefault()
      upload.abort() if upload

    $this.fileupload
      add: (e, data) ->
        if correctExtension(data)
          if correctFileSize(data)
            button.addClass 'disabled'
            cancel.removeClass 'hide'
            progress.removeClass 'hide'
            data.form.find('.help-tooltip').remove()
            data.submit()
          else
            Message.error t('message.errors.media_content.file_size', file_size: fileSizeMb)
        else
          Message.error t('message.errors.media_content.file_type')
      beforeSend: (jqXHR) ->
        progress.find('.bar').width('0%')
        upload = jqXHR
      success: (result) ->
        container.replaceWith(result).hide().fadeIn ->
          $('a.thumb').trigger 'image:uploaded'
        $('#edit_story_form').trigger 'form:loaded'
        Message.notice t('message.media_content.uploaded')
      complete: ->
        cancel.addClass 'hide'
        progress.addClass 'hide'
        button.removeClass 'disabled'
      error: (result, status, errorThrown) ->
        $this.val ''
        if errorThrown == 'abort'
          Message.notice t('message.media_content.canceled')
        else
          if result.status == 422
            response = jQuery.parseJSON(result.responseText)
            responseText = response.link[0]
            Message.error responseText
          else
            Message.error t('message.errors.media_content.try_again')
      progressall: (e, data) ->
        percentage = parseInt(data.loaded / data.total * 100, 10)
        progress.find('.bar').width(percentage + '%')

# load media urls and check that url exist
@checkAudioFiles = ->
  $('#audio_form[data-audio-check-url]').each ->
    $this = $(this)
    url = $this.data 'audio-check-url'

    $.ajax
      url: url
      type: 'GET'
      dataType: 'json'
      success: (response) ->
        $.each response, (key, item) ->
          btn = $('.btn.' + key)

          if item.exist
            audio = $this.find('.audio-upload-form').find('audio.' + key)
            audio.empty()
            $('<source>').attr('src', item.file).appendTo audio
            audioElement = audio.get(0)

            if audioElement
              audioElement.pause()
              audioElement.load()
              canPlay = !!audioElement.canPlayType && audioElement.canPlayType(item.content_type) != ''
              console.log canPlay + ' - ' + item.content_type

            $('.play.' + key).find('i').removeClass('icon-pause').addClass 'icon-play'
            if canPlay
              btn.removeClass 'disabled hide'
            else
              btn.addClass('disabled').removeClass('hide')
          else
            btn.addClass 'disabled'
      error: ->
        Message.notice t('message.media_content.not_processed_yet')

#
# App controllers
#
angular.module("Museum.controllers", [])
# Main controller
.controller('IndexController', [ '$scope', '$http', '$filter', '$window', '$modal', 'storage', ($scope, $http, $filter, $window, $modal, storage ) ->
  
  window.sc = $scope

  # Restangular.one('provider', '524692c10cff62683f000001').one('museums', '524692c10cff62683f000002').all('exhibits').getList().then (data) ->
  $http.get('http://192.168.216.128:3000/provider/524692c10cff62683f000001/museums/524692c10cff62683f000002/exhibits').success (data) ->
    exhibits = []
    for item in data
      exhibit = item.exhibit
      exhibit.images = item.images
      exhibit.stories = {}
      for story in item.stories
        story.story.quiz = story.quiz.quiz
        story.story.quiz.answers = story.quiz.answers
        exhibit.stories[story.story.language] = story.story
      exhibits.push exhibit
    $scope.exhibits = exhibits
    $scope.active_exhibit =  $scope.exhibits[0]

  $scope.museums = [
    {
      name: 'Imperial Peace Museum'
      packege_status: 'generated'
      city: 'London'
      image: '/img/museum.jpg'
      type: 'museum'
    }
    {
      name: 'Imperial War Museum'
      packege_status: 'generated'
      city: 'Tokio'
      image: '/img/museum.jpg'
      type: 'museum'
    }
    {
      name: 'Imperial Peace Exhibitin'
      packege_status: 'generated'
      city: 'Moscow'
      image: '/img/museum.jpg'
      type: 'museum'
    }
    {
      name: 'Imperial War Exhibitin'
      packege_status: 'generated'
      city: 'Berlin'
      image: '/img/museum.jpg'
      type: 'museum'
    }
    {
      name: 'Republican Peace Museum'
      packege_status: 'process'
      city: 'Tokio'
      image: '/img/museum.jpg'
      type: 'tour'
    }
    {
      name: 'Republican Peace Exhibitin'
      packege_status: 'process'
      city: 'London'
      image: '/img/museum.jpg'
      type: 'tour'
    }
    {
      name: 'Republican War Museum'
      packege_status: 'process'
      city: 'Berlin'
      image: '/img/museum.jpg'
      type: 'tour'
    }
    {
      name: 'Republican War Exhibitin'
      packege_status: 'process'
      city: 'London'
      image: '/img/museum.jpg'
      type: 'museum'
    }
  ]

  $scope.user = {
    mail: 'pman89@yandex.ru'
    providers: [
      {
        name: 'IZI.travel Test Provider'
      }
      {
        name: 'IZI.travel Second Provider'
      }
    ]
  }

  $scope.provider = {
    name: 'content_1'
    id: '1'
    passcode: 'passcode'
    passcode_edit_link: '/1/pass/edit/'
  }

  $scope.translations = {
    ru: 'Russian'
    en: 'English'
    es: 'Spanish'
  }

  storage.bind $scope, 'exhibits', {
      defaultValue: [
        {
          index: 0
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
          number: '1'
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          publish_state: 'all'
          description: ''
          qr_code: {
            url: '/img/qr_code.png'
            print_link: 'http://localhost:8000/img/qr_code.png'
          }
          images: [
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              id: 1
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              id: 2
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ]
          stories: {
            ru: {
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
              description: 'test description'
              publish_state: 'all'
              audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg'
              quiz: {
                question: 'are you sure?'
                description: 'can you tell me?'
                state: 'published'
                answers: [
                  {
                    title: 'yes'
                    correct: false
                    id: 0
                  }
                  {
                    title: 'may be'
                    correct: true
                    id: 1
                  }
                  {
                    title: 'who cares?'
                    correct: false
                    id: 2
                  }
                  {
                    title: 'nope'
                    correct: false
                    id: 3
                  }
                ]
              }
            }
          }
        }
        {
          index: 1
          name: 'двунадесятыми праздниками'
          number: '2'
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          publish_state: 'all'
          description: ''
          qr_code: {
            url: '/img/qr_code.png'
            print_link: 'http://localhost:8000/img/qr_code.png'
          }
          images: [
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              id: 1
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              id: 2
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ]
          stories: {
            ru: {
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
              description: 'test description'
              audio: ''
              publish_state: 'all'
              quiz: {
                question: 'are you sure?'
                description: 'can you tell me?'
                state: 'published'
                answers: [
                  {
                    title: 'yes'
                    correct: false
                    id: 0
                  }
                  {
                    title: 'may be'
                    correct: true
                    id: 1
                  }
                  {
                    title: 'who cares?'
                    correct: false
                    id: 2
                  }
                  {
                    title: 'nope'
                    correct: false
                    id: 3
                  }
                ]
              }
            }
          }
        }
        {
          index: 2
          name: 'Владимирская, с двунадесятыми'
          number: '3'
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          statsu: 'draft'
          publish_state: 'all'
          description: ''
          qr_code: {
            url: '/img/qr_code.png'
            print_link: 'http://localhost:8000/img/qr_code.png'
          }
          images: [
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              id: 1
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
            {
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              id: 2
              edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            }
          ]
          stories: {
            ru: {
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
              description: 'test description'
              audio: ''
              publish_state: 'all'
              quiz: {
                question: 'are you sure?'
                description: 'can you tell me?'
                state: 'published'
                answers: [
                  {
                    title: 'yes'
                    correct: false
                    id: 0
                  }
                  {
                    title: 'may be'
                    correct: true
                    id: 1
                  }
                  {
                    title: 'who cares?'
                    correct: false
                    id: 2
                  }
                  {
                    title: 'nope'
                    correct: false
                    id: 3
                  }
                ]
              }
            }
          }
        }
      ]
  }

  storage.bind $scope, 'current_museum', {
    defaultValue: {
      language: 'ru'
      def_lang: 'ru'
      name: 'Museum of modern art'
      index: 2
      number: 3
      image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
      thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
      publish_state: 'all'
      description: ''
      qr_code: {
        url: '/img/qr_code.png'
        print_link: 'http://localhost:8000/img/qr_code.png'
      }
      images: [
        {
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          id: 1
          edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
        }
        {
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          id: 2
          edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
        }
      ]
      stories: {
        en: {
          name: 'English'
          language: 'en'
          publish_state: 'all'
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
            state: 'published'
            answers: [
              {
                title: 'yes'
                correct: false
                id: 0
              }
              {
                title: 'may be'
                correct: true
                id: 1
              }
              {
                title: 'who cares?'
                correct: false
                id: 2
              }
              {
                title: 'nope'
                correct: false
                id: 3
              }
            ]
          }
        }
        es: {
          name: 'Spanish'
          language: 'es'
          publish_state: 'all'
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
            state: 'published'
            answers: [
              {
                title: 'yes'
                correct: false
                id: 0
              }
              {
                title: 'may be'
                correct: true
                id: 1
              }
              {
                title: 'who cares?'
                correct: false
                id: 2
              }
              {
                title: 'nope'
                correct: false
                id: 3
              }
            ]
          }
        }
        ru: {
          name: 'Russian'
          language: 'ru'
          publish_state: 'all'
          audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg'
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
            state: 'published'
            answers: [
              {
                title: 'yes'
                correct: false
                id: 0
              }
              {
                title: 'may be'
                correct: true
                id: 1
              }
              {
                title: 'who cares?'
                correct: false
                id: 2
              }
              {
                title: 'nope'
                correct: false
                id: 3
              }
            ]
          }
        }
      }
      new_story_link: '/1/1/1/'
    }
  }

  dropDown   = $('#drop_down').removeClass('hidden').hide()

  # just prototype function - remove active class, if window was reloaded when dropdown was opened
  if $scope.exhibits?
    for exhibit, index in $scope.exhibits
      if exhibit?
        exhibit.active   = false
        exhibit.selected = false
      else
        $scope.exhibits.splice(index, 1)

    $scope.active_exhibit =  $scope.exhibits[0]

  findActive = -> $('ul.exhibits li.exhibit.active')

  $scope.dummy_focusout_process = (active) ->
    if dropDown.find('#name').val() is ''
      remove = true
      for field in dropDown.find('#media .form-control:not(#opas_number)')
        field = $ field
        if field.val() isnt ''
          remove = false
      if remove
        $scope.new_item_creation = false
      else
        $scope.dummy_modal_open()

  $scope.closeDropDown = ->
    active = findActive()
    if active.hasClass 'dummy'
      $scope.dummy_focusout_process(active)
    dropDown.hide()
    active.removeClass('active')

  $scope.attachDropDown = (li) ->
    li = $ li
    hasParent = dropDown.hasClass 'inited'
    dropDown.show().insertAfter(lastOfLine(li))

    unless hasParent

      dropDown.addClass 'inited'

      dropDown.find('a.done, .close').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        $scope.closeDropDown()

      dropDown.find('>.prev-ex').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        active = findActive()
        prev = active.prev('.exhibit')
        if prev.attr('id') == 'drop_down' || prev.hasClass 'dummy'
          prev = prev.prev()
        if prev.length > 0
          prev.find('.opener .description').click()
        else
          active.siblings('.exhibit').last().find('.opener').click()

      dropDown.find('>.next-ex').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        active = findActive()
        next = active.next()
        if next.attr('id') == 'drop_down'  || next.hasClass 'dummy'
          next = next.next()
        if next.length > 0
          next.find('.opener .description').click()
        else
          active.siblings('.exhibit').first().find('.opener').click()


      $('#story_quiz_enabled, #story_quiz_disabled').unbind('change').bind 'change', ->
        elem = $ @
        quiz = dropDown.find('.form-wrap')
        if elem.attr('id') is 'story_quiz_enabled'
          $('label[for=story_quiz_enabled]').text('Enabled')
          $('label[for=story_quiz_disabled]').text('Disable')
          true
        else
          $('label[for=story_quiz_disabled]').text('Disabled')
          $('label[for=story_quiz_enabled]').text('Enable')
          true

      dropDown.find('a.delete_story').unbind('click').bind 'click', (e) ->
        elem = $ @
        if elem.hasClass 'no_margin'
          e.preventDefault()
          e.stopPropagation()
          $scope.closeDropDown()

  $scope.open_dropdown = (event, elem) ->
    clicked = $(event.target).parents('li')
    if clicked.hasClass('active')
      $scope.closeDropDown()
      return false

    for exhibit in $scope.exhibits
      if exhibit?
        exhibit.active = false

    elem.active = true
    $scope.active_exhibit = elem

    previous = findActive()

    if previous.hasClass 'dummy'
      $scope.dummy_focusout_process previous

    previous.removeClass('active')
    clicked.addClass('active')

    unless isSameLine(clicked, previous)
      $scope.attachDropDown clicked
      setTimeout ->
        $.scrollTo(clicked, 500)
      , 100
   
    item_publish_settings = dropDown.find('.item_publish_settings')
    delete_story = dropDown.find('.delete_story')

    if clicked.hasClass 'dummy'
      number = clicked.data('number')
      $('#opas_number').val(number).blur()
      $('#name').focus()
      item_publish_settings.hide()
      delete_story.addClass('no_margin')
    else
      item_publish_settings.show()
      delete_story.removeClass('no_margin')

  $scope.museum_type_filter = ''

  $scope.grid = ->
    collection = $('.exhibits>li.exhibit')
    tileListMargin = 60
    tileWidth = collection.first().width()
    tileSpace = 40 # parseInt(collection.first().css('margin-left'), 10) + parseInt(collection.first().css('margin-right'), 10)
    # $('.exhibits').css 'text-align': 'left'
    tileGrid(collection, tileWidth, tileSpace, tileListMargin)
    $(window).resize(tileGrid.bind(@, collection, tileWidth, tileSpace, tileListMargin))

  $scope.museum_list_prepare = ->
    list        = $('ul.museum_list')
    count       = list.find('li').length
    width       = $('body').width()
    row_count = (count * 150 + 160) / width
    if row_count > 1
      $('.museum_filters').show()
      list.width(width-200)
    else
      $('.museum_filters').hide()
      list.width(width-100)

  # TODO: find angular hook on after render and refactior. Get rid of setTimeout
  setTimeout ->
    # $scope.grid()
    $scope.museum_list_prepare()
    initFileUpload()
  , 200

  angular.element($window).bind "resize", ->
    setTimeout ->
      # $scope.grid()
      $scope.museum_list_prepare()
    , 100

  $scope.new_item_creation = false

  $scope.all_selected = false

  get_number = ->
    ++$scope.exhibits[$scope.exhibits.length-1].number + 1

  get_index = ->
    ++$scope.exhibits.length

  get_lang = ->
    $scope.current_museum.language

  get_state = (lang) ->
    if lang is $scope.current_museum.language
      'passcode'
    else
      'dummy'

  get_name = (lang) ->
    if lang is $scope.current_museum.language
      'Экспонат_'+lang
    else
      ''

  $scope.create_new_item = () ->
    unless $scope.new_item_creation is true
      $scope.new_exhibit = {
        name: ''
        number: get_number()
        index: get_index()
        image: '/img/img-bg.png'
        thumb: '/img/img-bg.png'
        publish_state: 'draft'
        description: ''
        qr_code: {
          url: ''
          print_link: ''
        }
        images: [
          {
            image: '/img/img-bg.png'
            thumb: '/img/img-bg.png'
          }
        ]
        stories: {}
      }
      for lang of $scope.current_museum.stories
        $scope.new_exhibit.stories[lang] = {
          name: ''
          description: ''
          audio: ''
          publish_stat: 'passcode'
          quiz: {
            question: ''
            description: ''
            state: 'limited'
            answers: [
              {
                title: ''
                correct: true
                id: 0
              }
              {
                title: ''
                correct: false
                id: 1
              }
              {
                title: ''
                correct: false
                id: 2
              }
              {
                title: ''
                correct: false
                id: 3
              }
            ]
          }
        }
      $scope.new_item_creation = true
      e = {}
      e.target = $('li.exhibit.dummy > .opener.draft')
      $scope.open_dropdown(e, $scope.new_exhibit)

      #hack to tile grid when adding an item to new line
      $(window).resize()     

      # hack, cant find out what exactly happening and why new exhibit created before saving
      $scope.exhibits.splice $scope.exhibits.length-1, 1 

  $scope.modal_options = {
    current_language: 
      name: 'Russian'
      language: 'ru'
    languages: $scope.current_museum.stories
  }

  $scope.check_selected = ->
    count = 0
    $scope.select_all_enabled = false
    for exhibit in $scope.exhibits
      if exhibit.selected is true
        $scope.select_all_enabled = true
        count += 1
    if count is $scope.exhibits.length
       $scope.all_selected = true

  $scope.select_all_exhibits = ->
    sign = !$scope.all_selected
    for exhibit in $scope.exhibits
      exhibit.selected = sign
    $scope.all_selected = !$scope.all_selected
    $scope.select_all_enabled = sign

  $scope.delete_modal_open = ->
    ModalDeleteInstance = $modal.open(
      templateUrl: "myModalContent.html"
      controller: ModalDeleteInstanceCtrl
      resolve:
        modal_options: ->
          $scope.modal_options
    )
    ModalDeleteInstance.result.then ((selected) ->
      $scope.selected = selected
      if Object.keys($scope.active_exhibit.stories).length is selected.length || Object.keys($scope.active_exhibit.stories).length is 1
        $scope.closeDropDown()
        for exhibit, index in $scope.exhibits
          if exhibit.index is $scope.active_exhibit.index
            $scope.exhibits.splice index, 1
            $scope.active_exhibit = $scope.exhibits[0]
            break
      else
        for st_index, story of $scope.active_exhibit.stories
          for item in selected
            if item is st_index
              $scope.active_exhibit.stories[st_index] = {
                language: get_lang()
                name: ''
                description: ''
                audio: ''
                quiz: {
                  question: ''
                  description: ''
                  answers: [
                    {
                      title: ''
                      correct: true
                      id: 0
                    }
                    {
                      title: ''
                      correct: false
                      id: 1
                    }
                    {
                      title: ''
                      correct: false
                      id: 2
                    }
                    {
                      title: ''
                      correct: false
                      id: 3
                    }
                  ]
                }
              }
    ), ->
      console.log "Modal dismissed at: " + new Date()

  $scope.dummy_modal_open = ->
    ModalDummyInstance = $modal.open(
      templateUrl: "myDummyModalContent.html"
      controller: ModalDummyInstanceCtrl
      resolve:
        modal_options: ->
          {
            exhibit: $scope.active_exhibit
          }
    )
    ModalDummyInstance.result.then ((result_string) ->
      $scope.new_item_creation = false
      $scope.item_deletion     = true
      if result_string is 'save_as'
        $scope.new_exhibit.stories[$scope.current_museum.language].name = "item_#{$scope.new_exhibit.number}"
        $scope.new_exhibit.stories[$scope.current_museum.language].publish_state = "passcode"
        $scope.new_exhibit.active = false
        $scope.exhibits.push $scope.new_exhibit
      else
        $scope.closeDropDown()
        $scope.new_exhibit.active = false
        $scope.active_exhibit = $scope.exhibits[0]
      $scope.item_deletion  = false
    ), ->
      console.log "Modal dismissed at: " + new Date()

  $scope.show_museum_edit = (event) ->
    elem = $ event.target
    $('.navigation .museum_edit, .page .museum_edit_guaranter').slideToggle(1000, "easeOutQuint")
    elem.find('i').toggleClass "icon-chevron-down icon-chevron-up"
    $scope.museum_edit_dropdown_opened = !$scope.museum_edit_dropdown_opened
    false

  $scope.museum_edit_dropdown_close = () ->
    setTimeout ->
      $('.actions_bar .museum_edit_opener').click()
    , 10

  # only pototype function, backend neded
  $scope.$on 'save_new_exhibit', ->
    console.log 'saving!'
    $scope.new_exhibit.publish_state = 'passcode'
    for lang, story of $scope.new_exhibit.stories
      story.publish_state = 'passcode'
    $scope.exhibits.push $scope.new_exhibit
    $scope.new_item_creation = false

  $scope.$on 'changes_to_save', (event, child_scope) ->
    switch child_scope.field_type
      when 'story'
        $http.put("http://192.168.216.128:3000/story/#{child_scope.item._id}", child_scope.item).success (data) ->
          console.log data
          child_scope.satus = 'done'
        .error ->
          console.log 'fail'
      when 'exhibit'
        $http.put("http://192.168.216.128:3000/exhibit/#{child_scope.item._id}", child_scope.item).success (data) ->
          console.log data
          child_scope.satus = 'done'
        .error ->
          console.log 'fail'

  # only pototype function
  $scope.populate_localstorage = ->
    for exhibit in $scope.exhibits
      for lang of $scope.current_museum.stories
        unless exhibit.stories[lang]?
          exhibit.stories[lang] = {
            language: lang
            name: ''
            description: ''
            audio: ''
            publish_state: 'dummy'
            quiz: {
              question: ''
              description: ''
              state: ''
              answers: [
                {
                  title: ''
                  correct: false
                  id: 0
                }
                {
                  title: ''
                  correct: true
                  id: 1
                }
                {
                  title: ''
                  correct: false
                  id: 2
                }
                {
                  title: ''
                  correct: false
                  id: 3
                }
              ]
            }
          }
    for i in [0..22]
      exhibit = {
        index: $scope.exhibits[$scope.exhibits.length-1].index + 1
        name: 'Экспонат'
        number: $scope.exhibits[$scope.exhibits.length-1].index + 1
        image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
        thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
        description: ''
        qr_code: {
          url: '/img/qr_code.png'
          print_link: 'http://localhost:8000/img/qr_code.png'
        }
        images: [
          {
            image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
            thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            id: 1
            edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          }
          {
            image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
            thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            id: 2
            edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
          }
        ]
      }
      exhibit.stories = {}
      for lang of $scope.current_museum.stories
        exhibit.stories[lang] = {
          language: lang.language
          name: get_name(lang)
          description: 'test description'
          audio: ''
          publish_state: get_state(lang)
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
            state: 'limited'
            answers: [
              {
                title: 'yes'
                correct: false
                id: 0
              }
              {
                title: 'may be'
                correct: true
                id: 1
              }
              {
                title: 'who cares?'
                correct: false
                id: 2
              }
              {
                title: 'nope'
                correct: false
                id: 3
              }
            ]
          }
        }
      $scope.exhibits.push exhibit

])

.controller('DropDownController', [ '$scope', '$http', '$filter', '$window', '$modal', 'storage', '$rootScope', ($scope, $http, $filter, $window, $modal, storage, $rootScope) ->

  $scope.quiz_state = (form) ->
    $scope.mark_quiz_validity(form.$valid)
    unless form.$valid
      setTimeout ->
        $("#story_quiz_disabled").click()
      , 300      
    true

  $scope.mark_quiz_validity = (valid) ->
    form = $('#quiz form')
    if valid
      form.removeClass 'has_error'
    else
      form.addClass 'has_error'
    true

  $scope.$watch '$parent.active_exhibit.stories[$parent.current_museum.language].quiz', (newValue, oldValue) ->
    if newValue.state is 'limited'
      unless $("#story_quiz_disabled").is(':checked')
        setTimeout ->
          $("#story_quiz_disabled").click()
        , 10
    else if newValue.state is 'published'
      if $("#story_quiz_enabled").is(':checked')
        setTimeout ->
          unless $scope.quizform.$valid
            setTimeout ->
              $("#story_quiz_disabled").click()
            , 10
        , 100
      else
        setTimeout ->
          $("#story_quiz_enabled").click()
        , 10
  , true

  $scope.$watch '$parent.active_exhibit.stories[$parent.current_museum.language].quiz.question', (newValue, oldValue) ->
    if $scope.quizform?
      # console.log $scope.quizform
      if $scope.quizform.$valid
        $scope.mark_quiz_validity($scope.quizform.$valid)
      else
        setTimeout ->
          $("#story_quiz_disabled").click()
          $scope.mark_quiz_validity($scope.quizform.$valid)
        , 10

  $scope.$watch '$parent.active_exhibit.stories[$parent.current_museum.language].name', (newValue, oldValue) ->
    form = $('#media form')
    if form.length > 0
      if $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].publish_state is 'dummy'
        $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].publish_state = 'passcode' if newValue
      else
        unless  $scope.$parent.new_item_creation or $scope.$parent.item_deletion
          unless newValue 
            $scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].name = oldValue
            $('.empty_name_error.name').show()
            setTimeout ->
              $('.empty_name_error.name').hide()
            , 1500
        else
          if newValue and $scope.$parent.new_item_creation
            $rootScope.$broadcast 'save_new_exhibit'

  $scope.$watch '$parent.active_exhibit.number', (newValue, oldValue) ->
    form = $('#media form')
    if form.length > 0
      unless $scope.$parent.new_item_creation || $scope.$parent.item_deletion
        unless newValue 
          $scope.$parent.active_exhibit.number = oldValue
          $('.empty_name_error.number').show()
          setTimeout ->
            $('.empty_name_error.number').hide()
          , 1500

  $scope.$watch ->
    angular.toJson($scope.$parent.active_exhibit.stories[$scope.$parent.current_museum.language].quiz.answers)
  , (newValue, oldValue) ->
    if $scope.quizform?
      if $scope.quizform.$valid
        $scope.mark_quiz_validity($scope.quizform.$valid)
      else
        setTimeout ->
          $("#story_quiz_disabled").click()
        , 10

  , true

  $scope.upload_image = (e) ->
    e.preventDefault()
    elem = $ e.target
    parent = elem.parents('#images, #maps')

    if parent.find('li:hidden').isEmpty()
      $.ajax
        url: elem.attr('href')
        async: false
        success: (response) ->
          node = $(response).hide()
          parent.find('li.new').before node
          initFileUpload e, node.find('.fileupload'), { progress: elem.find('.progress') }
    parent.find('li:hidden :file').click()

  $scope.delete_image = (e) ->
    e.preventDefault()
    e.stopPropagation()
    elem = $ e.target
    parent = elem.parents('#images, #maps')

    if confirm(elem.data('confirm'))
      $.ajax
        url: elem.attr('href')
        type: elem.data('method')
        data:
          authentity_token: $('meta[name=csrf-token]').attr('content')
        success: ->
          fadeTime = 200
          if parent.attr('id').match(/images/)
            elem.parents('li').fadeOut fadeTime, ->
              elem.remove()
              storySetImage.trigger 'image:deleted'
          else
            elem.parents('li').fadeOut fadeTime, ->
              elem.remove()

  $scope.change_image = (e) ->
    elem = $ e.target
    form = elem.parents 'form'
    unless elem.hasClass('disabled')
      form.find(':file').trigger 'click'

  true

])

.controller('MuseumEditController', [ '$scope', '$http', '$filter', '$window', '$modal', 'storage', ($scope, $http, $filter, $window, $modal, storage) ->
  $scope.museum_quiz_state = (form) ->
    $scope.mark_quiz_validity(form.$valid)
    unless form.$valid
      setTimeout ->
        $("#museum_story_quiz_disabled").click()
      , 300      
    true

  $scope.mark_quiz_validity = (valid) ->
    form = $('#museum_quiz form')
    if valid
      form.removeClass 'has_error'
    else
      form.addClass 'has_error'
    true

  $scope.$watch '$parent.current_museum.stories[$parent.current_museum.language].quiz', (newValue, oldValue) ->
    if newValue.state is 'limited'
      unless $("#museum_story_quiz_disabled").is(':checked')
        setTimeout ->
          $("#museum_story_quiz_disabled").click()
        , 10
    else if newValue.state is 'published'
      if $("#museum_story_quiz_enabled").is(':checked')
        setTimeout ->
          unless $scope.museumQuizform.$valid
            setTimeout ->
              $("#museum_story_quiz_disabled").click()
            , 10
        , 100
      else
        setTimeout ->
          $("#museum_story_quiz_enabled").click()
        , 10
  , true

  $scope.$watch '$parent.current_museum.stories[$parent.current_museum.language].quiz.question', (newValue, oldValue) ->
    if $scope.museumQuizform?
      if $scope.museumQuizform.$valid
        $scope.mark_quiz_validity($scope.museumQuizform.$valid)
      else
        setTimeout ->
          $("#story_quiz_disabled").click()
          $scope.mark_quiz_validity($scope.museumQuizform.$valid)
        , 10

  $scope.$watch ->
    angular.toJson($scope.$parent.current_museum.stories[$scope.$parent.current_museum.language].quiz.answers)
  , (newValue, oldValue) ->
    if $scope.museumQuizform?
      if $scope.museumQuizform.$valid
        $scope.mark_quiz_validity($scope.museumQuizform.$valid)
      else
        setTimeout ->
          $("#museum_#story_quiz_disabled").click()
        , 10

  , true


  true
])

@ModalDeleteInstanceCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.modal_options = modal_options

  $scope.only_one = $scope.modal_options.languages.length is 1

  $scope.ok = ->
    $scope.selected = []
    for language, value of $scope.modal_options.languages
      $scope.selected.push language if value.checked is true
    $modalInstance.close $scope.selected

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.mark_all = ->
    for language, value of $scope.modal_options.languages
      value.checked = true

  $scope.mark_default_only = ->
    for language, value of $scope.modal_options.languages
      value.checked = false
      value.checked = true if $scope.modal_options.current_language.language is language

  $scope.mark_default_only()

@ModalDummyInstanceCtrl = ($scope, $modalInstance, modal_options) ->
  $scope.exhibit = modal_options.exhibit

  $scope.discard = ->
    $modalInstance.close 'discard'

  $scope.save_as = ->
    $modalInstance.close "save_as"