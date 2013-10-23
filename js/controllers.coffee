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

@gon = {"google_api_key":"AIzaSyCPyGutBfuX48M72FKpF4X_CxxPadq6r4w","acceptable_extensions":{"audio":["mp3","ogg","aac","wav","amr","3ga","m4a","wma","mp4","mp2","flac"],"image":["jpg","jpeg","gif","png","tiff","bmp"],"video":["mp4","m4v","avi", "ogv"]},"development":false}

# #
# App controllers
#
angular.module("Museum.controllers", [])
# Main controller
.controller('IndexController', [ '$scope', '$http', '$filter', '$window', '$modal', '$routeParams', 'ngProgress', 'storySetValidation', 'errorProcessing', ($scope, $http, $filter, $window, $modal, $routeParams, ngProgress, storySetValidation, errorProcessing) ->
  
  window.sc = $scope

  $scope.exhibit_search = ''

  $scope.criteriaMatch = ( criteria ) ->
    ( item ) ->
      if item.stories[$scope.current_museum.language]?
        if item.stories[$scope.current_museum.language].name
          in_string = item.stories[$scope.current_museum.language].name.toLowerCase().indexOf(criteria.toLowerCase()) > -1
          $scope.grid()
          return in_string || criteria is ''
        else
          true
      else
        true

  museum_id = if $routeParams.museum_id?
    $routeParams.museum_id
  else
    "5260c63ceb6688e516000002"
    # "5266921cb7a2b93a7f000002"


  content_provider_id = if $routeParams.content_provider_id?
    $routeParams.content_provider_id
  else
    "5260c63ceb6688e516000001"
    # "5266921cb7a2b93a7f000001"

  $scope.backend_url = "http://192.168.158.128:3000"
  # $scope.backend_url = "http://prototype.izi.travel"

  $scope.sort_field     = 'number'
  $scope.sort_direction = 1
  $scope.sort_text      = 'Sort 0-9'
  $scope.ajax_progress  = true
  $scope.story_subtab   = 'video'

  $scope.reload_exhibits = (sort_field, sort_direction) ->
    # $http.get("#{$scope.backend_url}/provider/524c2a72856ee97345000001/museums/524c2a72856ee97345000002/exhibits").success (data) ->
    # ngProgress.color('#fd6e3b')
    # ngProgress.start()
    # console.log museum_id
    $http.get("#{$scope.backend_url}/provider/#{content_provider_id}/museums/#{museum_id}/exhibits/#{sort_field}/#{sort_direction}").success (data) ->
      exhibits = []
      $scope.modal_translations = {}
      # console.log data
      for item in data
        if item?
          exhibit = item.exhibit
          exhibit.images = item.images
          exhibit.stories = {}
          for story in item.stories
            story.story.quiz = story.quiz.quiz
            story.story.audio = story.audio
            story.story.video = story.video
            story.story.quiz.answers = story.quiz.answers
            exhibit.stories[story.story.language] = story.story
            $scope.modal_translations[story.story.language] = {name: $scope.translations[story.story.language]}
          exhibits.push exhibit
      ngProgress.complete()
      # console.log exhibits
      $scope.active_exhibit =  exhibits[0]
      $scope.exhibits = exhibits
      $scope.ajax_progress  = false
      if exhibits.length is 0
        $scope.active_exhibit = {
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

  $scope.reload_museums = (sort_field, sort_direction) ->
    ngProgress.color('#fd6e3b')
    ngProgress.start()
    $http.get("#{$scope.backend_url}/provider/#{content_provider_id}/museums").success (data) ->
      $scope.museums = []
      found = false
      for item in data
        museum = item.exhibit
        museum.def_lang = "ru"
        museum.language = "ru" unless museum.language
        museum.package_status = "process"
        museum.stories = {}
        museum.images = item.images
        for story in item.stories
          story.story.city = "Saint-Petersburg"
          story.story.quiz = story.quiz.quiz
          story.story.audio = story.audio
          story.story.video = story.video
          story.story.quiz.answers = story.quiz.answers
          museum.stories[story.story.language] = story.story
        $scope.museums.push museum
        if museum._id is museum_id
          $scope.current_museum = museum
          found = true
      unless found
        $scope.current_museum = $scope.museums[0]
        $scope.current_museum.def_lang = "ru"
        $scope.current_museum.language = "ru"
        museum_id = $scope.current_museum._id
      $scope.reload_exhibits $scope.sort_field, $scope.sort_direction

  $scope.reload_museum = () ->
    $http.get("#{$scope.backend_url}/provider/#{content_provider_id}/museums/#{museum_id}").success (data) ->
      museum = data.exhibit
      museum.def_lang = "ru"
      museum.language = "ru"
      museum.stories = {}
      for story in data.stories
        story.story.quiz = story.quiz.quiz
        story.story.quiz.answers = story.quiz.answers
        story.story.images = story.images
        story.story.audio = story.audio
        museum.stories[story.story.language] = story.story
      $scope.current_museum = museum

  $scope.reload_museums()

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
    ge: 'German'
    fi: 'Finnish'
    sw: 'Sweedish'
    it: 'Italian'
    fr: 'French'
    kg: 'Klingon'
  }

  $scope.modal_translations = {
    ru:
      name: 'Russian'
    en:
      name: 'English'
    es:
      name: 'Spanish'
    ge: 
      name: 'German'
    fi: 
      name: 'Finnish'
    sw: 
      name: 'Sweedish'
    it: 
      name: 'Italian'
    fr: 
      name: 'French'
    kg: 
      name: 'Klingon'
  }

  $scope.exhibits = [
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
        en: {
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
        es: {
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
  ]

  $scope.active_exhibit = $scope.exhibits[0]

  $scope.current_museum = {
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

  $scope.element_switch = true
  $scope.forbid_switch  = false
  $scope.create_new_language = false

  dropDown   = $('#drop_down').removeClass('hidden').hide()

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


      dropDown.find('a.delete_story').unbind('click').bind 'click', (e) ->
        elem = $ @
        if elem.hasClass 'no_margin'
          e.preventDefault()
          e.stopPropagation()
          $scope.closeDropDown()

  $scope.open_dropdown = (event, elem) ->
    clicked = $(event.target).parents('li')

    if $scope.forbid_switch is true
      event.stopPropagation()
      return false

    if clicked.hasClass('active')
      $scope.closeDropDown()
      return false

    if $scope.new_item_creation
      if findActive().length > 0
        $scope.closeDropDown()

    for exhibit in $scope.exhibits
      if exhibit?
        exhibit.active = false

    elem.active = true
    $scope.element_switch = true
    setTimeout ->
      $scope.element_switch = false
    , 200
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
    # $(window).resize(tileGrid.bind(@, collection, tileWidth, tileSpace, tileListMargin))

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
    $scope.museum_list_prepare()
  , 200

  $(window).resize ->
    setTimeout ->
      $scope.museum_list_prepare()
    , 100

  $scope.new_item_creation = false

  $scope.all_selected = false

  $scope.modal_options = {
    current_language: 
      name: $scope.translations[$scope.current_museum.language]
      language: $scope.current_museum.language
    languages: $scope.modal_translations
    exhibits: $scope.exhibits
    deletion_password: '123456'
  }

  get_number = ->
    res = 0
    if $scope.exhibits[$scope.exhibits.length-1]
      res = parseInt($scope.exhibits[$scope.exhibits.length-1].number, 10) + 1
    else
      res = 1
    return res

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

  $scope.create_dummy_story = (id) ->
    dummy_story = {
      playback_algorithm: 'generic'
      content_provider:   content_provider_id
      story_type:         'story'
      status:             'draft'
      language:           'dummy'
      name:               ''
      short_description:  ''
      long_description:   ''
      story_set:          id
    }
    dummy_story.quiz = {
      story:     ""
      question:  ''
      comment:   ''
      status:    'passcode'
      answers:   []
    }
    for i in [0..3]
      dummy_story.quiz.answers.push
        quiz:     ""
        content:  ''
        correct:  false

    dummy_story.quiz.answers[0].correct = true

    dummy_story

  $scope.new_museum_language = () ->
    $scope.create_new_language = true

    dummy_story = $scope.create_dummy_story $scope.current_museum._id

    dummy_story.quiz.answers[0].correct = true

    $scope.dummy_museum = angular.copy $scope.current_museum

    $scope.dummy_museum.stories.dummy = dummy_story
    # $scope.dummy_museum.stories.dummy.name = $scope.current_museum.stories[$scope.current_museum.def_lang].name
    $scope.dummy_museum.stories.dummy.status = 'passcode'

    # for exhibit in $scope.exhibits
    #   exhibit.stories.dummy = dummy_story

    $scope.dummy_museum.language = 'dummy'


    $scope.modal_options = {
      museum: $scope.dummy_museum
      translations: $scope.translations
    }

    ModalMuseumInstance = $modal.open(
      templateUrl: "myMuseumModalContent.html"
      controller: ModalMuseumInstanceCtrl
      resolve:
        modal_options: ->
          $scope.modal_options
    )
    ModalMuseumInstance.result.then ((result_string) ->
      switch result_string
        when 'save'
          true
          console.log $scope.dummy_museum

          lang = $scope.dummy_museum.language
          $scope.dummy_museum.stories[lang] = $scope.dummy_museum.stories.dummy
          $scope.dummy_museum.stories[lang].language = lang

          for exhibit in $scope.exhibits
            exhibit.stories[lang] = $scope.dummy_museum.stories[lang]
            exhibit.stories[lang].language = lang
            exhibit.stories[lang].name = ""
            exhibit.stories[lang].status = 'draft'
            exhibit.stories[lang].story_set = exhibit._id

            story = angular.copy exhibit.stories[lang]

            $scope.post_stories story

          $scope.current_museum.stories[lang] = $scope.dummy_museum.stories[lang]
          $scope.current_museum.language = lang

          story = angular.copy $scope.dummy_museum.stories[lang]
          story.story_set = $scope.current_museum._id

          $scope.post_stories story

          $scope.create_new_language = false

        when 'discard'
          true
    ), ->
      console.log "Modal dismissed at: " + new Date()


    true

  $scope.create_new_item = () ->
    unless $scope.new_item_creation is true
      number = get_number()
      $scope.new_exhibit = {
        content_provider: content_provider_id
        number:           number
        type:             'exhibit'
        distance:         20
        duration:         20
        status:           'draft'
        route:            ''
        category:         ''
        parent:           museum_id
        name:             ''
        qr_code: {
          url: ''
          print_link: ''
        }
        stories: {}
      }
      $scope.new_exhibit.images = []
      for lang of $scope.current_museum.stories
        $scope.new_exhibit.stories[lang] = {
          playback_algorithm: 'generic'
          content_provider:   content_provider_id
          story_type:         'story'
          status:             'draft'
          language:           lang
          name:               ''
          short_description:  ''
          long_description:   ''
          story_set:          ""
        }
        $scope.new_exhibit.stories[lang].quiz = {
          story:     ""
          question:  ''
          comment:   ''
          status:    'passcode'
          answers:   []
        }
        for i in [0..3]
          $scope.new_exhibit.stories[lang].quiz.answers.push
            quiz:     ""
            content:  ''
            correct:  false
        $scope.new_exhibit.stories[lang].quiz.answers[0].correct = true

      $scope.new_item_creation = true
      e = {}
      e.target = $('li.exhibit.dummy > .opener.draft')
      $scope.open_dropdown(e, $scope.new_exhibit)

      #hack to tile grid when adding an item to new line
      $scope.grid()    

  $scope.check_selected = ->
    count = 0
    $scope.select_all_enabled = false
    for exhibit in $scope.exhibits
      if exhibit.selected is true
        $scope.select_all_enabled = true
        count += 1
    if count is $scope.exhibits.length
       $scope.all_selected = true

  $scope.select_all_exhibits = (option) ->
    if option?
      switch option
        when 'select'
          sign = true
        when 'cancel'
          sign = false
    else
      sign = !$scope.all_selected
    for exhibit in $scope.exhibits
      exhibit.selected = sign
    $scope.all_selected = !$scope.all_selected
    $scope.select_all_enabled = sign

  $scope.delete_modal_open = ->
    unless $scope.new_item_creation
      ModalDeleteInstance = $modal.open(
        templateUrl: "myModalContent.html"
        controller: ModalDeleteInstanceCtrl
        resolve:
          modal_options: ->
            $scope.modal_options
      )
      ModalDeleteInstance.result.then ((selected) ->
        $scope.delete_exhibit $scope.active_exhibit, selected
      ), ->
        console.log "Modal dismissed at: " + new Date()
    else
      true

  $scope.delete_museum_modal_open = ->
    unless $scope.new_item_creation
      museumDeleteInstance = $modal.open(
        templateUrl: "museumDelete.html"
        controller: museumDeleteCtrl
        resolve:
          modal_options: ->
            $scope.modal_options
      )
      museumDeleteInstance.result.then ((selected) ->
        lang = $scope.current_museum.language
        if selected is 'lang'
          $scope.current_museum.language = $scope.current_museum.def_lang
          for exhibit in $scope.exhibits
            $scope.delete_story exhibit.stories, lang, (stories, lang) ->
              delete stories[lang]
              true
          $scope.delete_story $scope.current_museum.stories, lang, (stories, lang) ->
            delete stories[lang]
            true
        else
          console.log 'deleting museum story or whole museum'
          museum = $scope.current_museum

          # and now we need to switch museums

          for exhibit in $scope.exhibits
            $scope.delete_story_set exhibit
          $scope.delete_story_set museum

      ), ->
        console.log "Modal dismissed at: " + new Date()
    else
      true

  $scope.delete_exhibit = (target_exhibit, languages) ->
    # console.log Object.keys(target_exhibit.stories).length, languages
    if languages.length >= Object.keys(target_exhibit.stories).length
      $scope.closeDropDown()
      for exhibit, index in $scope.exhibits
        if exhibit._id is target_exhibit._id
          $scope.exhibits.splice index, 1
          $scope.grid()
          if target_exhibit._id is $scope.active_exhibit._id
            $scope.active_exhibit = $scope.exhibits[0]
          $scope.delete_story_set target_exhibit
          break
    else
      console.log target_exhibit._id
      for st_index, story of target_exhibit.stories
        for item in languages
          # console.log item, st_index
          if item is st_index
            target_exhibit.selected = false
            story = target_exhibit.stories[st_index]
            story.status = 'dummy'
            story.name = ''
            story.short_description = ''
            story.long_description = ''
            story.quiz.question = ''
            story.quiz.comment = ''
            story.quiz.status = ''
            story.quiz.answers = [] unless story.quiz.answers
            story.quiz.answers[0].content = ''
            story.quiz.answers[0].correct = true
            story.quiz.answers[1].content = ''
            story.quiz.answers[1].correct = false
            story.quiz.answers[2].content = ''
            story.quiz.answers[2].correct = false
            story.quiz.answers[3].content = ''
            story.quiz.answers[3].correct = false
            $scope.update_story(story)

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
    unless museum_anim_in_progress
      museum_anim_in_progress = true
      elem.find('i').toggleClass "icon-chevron-down icon-chevron-up"
      $('.navigation .museum_edit').slideToggle(1000, "easeOutQuint")
      $scope.museum_edit_dropdown_opened = !$scope.museum_edit_dropdown_opened
    false

  $scope.museum_edit_dropdown_close = () ->
    e = {
      target: $('.museum_edit_opener')
    }
    if $scope.museum_edit_dropdown_opened
      $scope.show_museum_edit(e)

  $scope.update_story = (story) ->
    $http.put("#{$scope.backend_url}/story/#{story._id}", story).success (data) ->
      $http.put("#{$scope.backend_url}/quiz/#{story.quiz._id}", story.quiz).success (data) ->
        for answer in story.quiz.answers
          $scope.put_answers answer
      .error ->
        errorProcessing.addError 'Failed to update a quiz for story'
    .error ->
      errorProcessing.addError 'Failed update a story'

  $scope.put_answers = (answer) ->
    $http.put("#{$scope.backend_url}/quiz_answer/#{answer._id}", answer).success (data) ->
      console.log 'done'
    .error ->
      errorProcessing.addError 'Failed to save quiz answer'

  $scope.post_stories = (original_story) ->

    story = angular.copy original_story

    $http.post("#{$scope.backend_url}/story/", story).success (data) ->
      story._id = data._id
      story.quiz.story = data._id
      $http.post("#{$scope.backend_url}/quiz/", story.quiz).success (data) ->
        story.quiz._id = data.id
        for answer in story.quiz.answers
          answer.quiz = data._id
          $scope.post_answers answer
      .error ->
       errorProcessing.addError 'Failed to save quiz for new story'
    .error ->
      errorProcessing.addError 'Failed to save new story'

  $scope.post_answers = (answer) ->
    $http.post("#{$scope.backend_url}/quiz_answer/", answer).success (data) ->
      console.log data
      answer._id = data._id
    .error ->
      errorProcessing.addError 'Failed to save quiz answer'

  $scope.mass_switch_pub = (value) ->
    for exhibit in $scope.exhibits
      if exhibit.selected is true && exhibit.stories[$scope.current_museum.language].status isnt 'dummy'
        validation_item = {}
        validation_item.item = exhibit.stories[$scope.current_museum.language]
        validation_item.root = exhibit
        validation_item.field_type = 'story'
        switch value
          when 'passcode'
            validation_item.item.status = 'passcode'
          when 'published'
            validation_item.item.status = 'published'
        storySetValidation.checkValidity validation_item
    # $scope.$digest()

  $scope.delete_selected_exhibits = () ->
    $scope.modal_options = {
      current_language: 
        name: $scope.translations[$scope.current_museum.language]
        language: $scope.current_museum.language
      languages: $scope.modal_translations
      exhibits: $scope.exhibits
      deletion_password: '123456'
    }
    ModalDeleteInstance = $modal.open(
      templateUrl: "myModalContent.html"
      controller: ModalDeleteInstanceCtrl
      resolve:
        modal_options: ->
          $scope.modal_options
    )

    ModalDeleteInstance.result.then ((selected, ids_to_delete) ->
      for exhibit in $scope.exhibits
        if exhibit.selected is true
          exhibit.selected = false
          $scope.delete_exhibit exhibit, selected
    ), ->
      console.log "Modal dismissed at: " + new Date()

  $scope.delete_story = (stories, lang, callback) ->
    $http.delete("#{$scope.backend_url}/story/#{stories[lang]._id}").success (data) ->
      console.log data
      callback(stories, lang) if callback?
    .error ->
      errorProcessing.addError 'Failed to delete story in languane: ' + $scope.translations[lang]

  $scope.delete_story_set = (target_exhibit) ->
    $http.delete("#{$scope.backend_url}/story_set/#{target_exhibit._id}/").success (data) ->
      console.log data
    .error ->
      errorProcessing.addError 'Failed to delete exhibit with number' + target_exhibit.number

  $scope.$watch 'current_museum.language', (newValue, oldValue) ->
    if newValue
      if newValue isnt 'dummy'
        if $scope.current_museum._id
          $scope.modal_options.current_language = 
            name: $scope.translations[$scope.current_museum.language]
            language: $scope.current_museum.language

          $scope.create_new_language = false
          $http.put("#{$scope.backend_url}/story_set/#{$scope.current_museum._id}", $scope.current_museum).success (data) ->
            console.log data
            $scope.last_save_time = new Date()
          .error (error) ->
            errorProcessing.addError 'Failed to save museum language'

  $scope.$on 'save_new_exhibit', ->
    console.log 'saving!'
    $scope.new_exhibit.stories[$scope.current_museum.language].status = 'passcode'
    $http.post("#{$scope.backend_url}/story_set/", $scope.new_exhibit).success (data) ->
      $scope.exhibits.push $scope.new_exhibit
      $scope.new_exhibit._id = data._id
      $scope.last_save_time = new Date()
      for lang, story of $scope.new_exhibit.stories
        story.publish_state = 'passcode'
        story.story_set = data._id
        $scope.post_stories story
      dropDown.find('.item_publish_settings').show()
      dropDown.find('.delete_story').removeClass 'no_margin'
    .error ->
      errorProcessing.addError 'Failed to save new exhibit'
    $scope.new_item_creation = false

  $scope.$on 'changes_to_save', (event, child_scope) ->
    $http.put("#{$scope.backend_url}/#{child_scope.field_type}/#{child_scope.item._id}", child_scope.item).success (data) ->
      child_scope.satus = 'done'
      $scope.last_save_time = new Date()
      console.log data
    .error ->
      errorProcessing.addError 'Server error - Prototype error.'
    $scope.forbid_switch  = false

  $scope.$on 'quiz_changes_to_save', (event, child_scope, correct_item) ->
    for sub_item in child_scope.collection
      sign = if sub_item._id is correct_item._id
        true
      else
        false
      sub_item.correct = sign
      sub_item.correct_saved = sign
      $http.put("#{$scope.backend_url}/#{child_scope.field_type}/#{sub_item._id}", sub_item).success (data) ->
        console.log data
        $scope.last_save_time = new Date()
      .error ->
        errorProcessing.addError 'Failed to update quiz'
    $scope.forbid_switch  = false

])

.controller('MuseumEditController', [ '$scope', '$http', '$filter', '$window', '$modal', 'storage', ($scope, $http, $filter, $window, $modal, storage) ->

  setTimeout ->
    $scope.$parent.museumQuizform = $scope.museumQuizform
    $scope = $scope.$parent
  , 100

  $scope.$watch 'current_museum.stories[current_museum.language].quiz', (newValue, oldValue) ->
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

  $scope.$watch 'current_museum.stories[current_museum.language].quiz.question', (newValue, oldValue) ->
    if $scope.museumQuizform?
      if $scope.museumQuizform.$valid
        $scope.mark_quiz_validity($scope.museumQuizform.$valid)
      else
        setTimeout ->
          $("#museum_story_quiz_disabled").click()
          $scope.mark_quiz_validity($scope.museumQuizform.$valid)
        , 10

  $scope.$watch ->
    angular.toJson($scope.current_museum.stories[$scope.current_museum.language].quiz.answers)
  , (newValue, oldValue) ->
    if $scope.museumQuizform?
      if $scope.museumQuizform.$valid
        $scope.mark_quiz_validity($scope.museumQuizform.$valid)
      else
        setTimeout ->
          $("#museum_story_quiz_disabled").click()
        , 10

  , true


  true
])

@ModalDeleteInstanceCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.modal_options = modal_options

  $scope.deletion_password = ''

  $scope.only_one = $scope.modal_options.languages.length is 1

  $scope.password_input_shown = false

  $scope.ok = ->
    $scope.selected = []
    $scope.ids_to_delete = []
    for language, value of $scope.modal_options.languages
      $scope.selected.push language if value.checked is true

    for exhibit in modal_options.exhibits
      if exhibit.selected is true
        $scope.ids_to_delete.push exhibit

    if $scope.ids_to_delete.length <= 1
      $modalInstance.close $scope.selected
    else
      $scope.password_input_shown = true
      if $scope.deletion_password is modal_options.deletion_password
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

@museumDeleteCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.modal_options = modal_options

  $scope.deletion_password = ''

  $scope.variant = {
    checked: 'lang'
  }

  $scope.ok = ->
    if $scope.deletion_password is modal_options.deletion_password
      $modalInstance.close $scope.variant.checked

  $scope.cancel = ->
    $modalInstance.dismiss()


@ModalDummyInstanceCtrl = ($scope, $modalInstance, modal_options) ->
  $scope.exhibit = modal_options.exhibit

  $scope.discard = ->
    $modalInstance.close 'discard'

  $scope.save_as = ->
    $modalInstance.close "save_as"

@ModalMuseumInstanceCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.museum = modal_options.museum

  $scope.translations = modal_options.translations

  $scope.discard = ->
    $modalInstance.close 'discard'

  $scope.save_as = ->
    $modalInstance.close "save", $scope.museum