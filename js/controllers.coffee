"use strict"

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

#
# App controllers
#
angular.module("Museum.controllers", [])
# Main controller
.controller('IndexController', [ '$scope', '$http', '$filter', '$window', 'sharedProperties', ($scope, $http, $filter, $window, sharedProperties) ->
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

  $scope.current_museum = {
    language: 'ru'
    name: 'Museum of modern art'
    stories: [
      {
        name: 'Russian'
        language: 'ru'
      }
      {
        name: 'Spanish'
        language: 'es'
      }
      {
        name: 'English'
        language: 'en'
      }
    ]
    new_story_link: '/1/1/1/'
  }

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
        }
        {
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
        }
      ]
      stories: [
        {
          language: 'ru'
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
          description: 'test description'
          audio: ''
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
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
      ]
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
        }
        {
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
        }
      ]
      stories: [
        {
          language: 'ru'
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
          description: 'test description'
          audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg'
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
            answers: [
              {
                title: 'yes'
                correct: true
                id: 0
              }
              {
                title: 'may be'
                correct: false
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
      ]
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
        }
        {
          image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
          thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
        }
      ]
      stories: [
        {
          language: 'ru'
          name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
          description: 'test description'
          audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg'
          quiz: {
            question: 'are you sure?'
            description: 'can you tell me?'
            answers: [
              {
                title: 'yes'
                correct: true
                id: 0
              }
              {
                title: 'may be'
                correct: false
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
      ]
    }
  ]

  # $scope.new_exhibit = {
  #   name: 'newly created exhibit'
  #   number: '11'
  #   publish_state: 'draft'
  # }

  dropDown   = $('#drop_down').removeClass('hidden').hide()

  findActive = -> $('ul.exhibits li.exhibit.active')

  dummy_focusout_process = (active) ->
    if dropDown.find('#name').val() is ''
      remove = true
      for field in dropDown.find('#media .form-control:not(#opas_number)')
        field = $ field
        if field.val() isnt ''
          remove = false
      if remove
        $scope.new_item_creation = false
      else
        number = active.data('number')
        $('ul.exhibits').append modal_template(number)
        $('#dummyModal').modal { show: true, backdrop: 'static' }
        $('#dummyModal').find('.btn-default').click ->
          $scope.new_item_creation = false
          $('#dummyModal, .modal-backdrop').remove()
        $('#dummyModal').find('.btn-primary').click ->
          active.removeClass('dummy')
          dropDown.find('#name').val("item_#{number}")
          active.find('.opener').removeClass 'draft'
          $('#dummyModal, .modal-backdrop').remove()

  closeDropDown = ->
    active = findActive()
    if active.hasClass 'dummy'
      dummy_focusout_process(active)
    dropDown.hide()
    active.removeClass('active')

  attachDropDown = (li) ->
    li = $ li
    hasParent = dropDown.hasClass 'inited'
    dropDown.show().insertAfter(lastOfLine(li))

    unless hasParent

      dropDown.addClass 'inited'

      dropDown.find('a.done, .close').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        closeDropDown()

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

      dropDown.find('.label-content').unbind('click').bind 'click', (e) ->
        elem = $ @
        parent = elem.parents('.dropdown-menu').prev('.dropdown-toggle')
        if elem.hasClass 'everyone'
          parent.html "<div class='extra'><i class='icon-globe'></i></div> Published <span class='caret'></span>"
        else
          parent.html "<div class='extra'><i class='icon-user'></i></div> Publish <span class='caret'></span>"

      dropDown.find('#delete_story input[type=radio]').unbind('change').bind 'change', ->
        elem = $ @
        container = $('#delete_story')
        if elem.attr('id') is 'lang_selected'
          if elem.is(':checked')
            $('#delete_story .other_variants').slideDown(150)
        else
          $('#delete_story .other_variants').slideUp(150)

      $('#story_quiz_enabled, #story_quiz_disabled').unbind('change').bind 'change', ->
        elem = $ @
        quiz = dropDown.find('.form-wrap')
        console.log elem.val()
        if elem.attr('id') is 'story_quiz_enabled'
          $('label[for=story_quiz_enabled]').text('Enabled')
          $('label[for=story_quiz_disabled]').text('Disable')
          #should someway publish model
          true
        else
          $('label[for=story_quiz_disabled]').text('Disabled')
          $('label[for=story_quiz_enabled]').text('Enable')
          #should someway unpublish model
          true

      dropDown.find('a.delete_story').unbind('click').bind 'click', (e) ->
        elem = $ @
        if elem.hasClass 'no_margin'
          e.preventDefault()
          e.stopPropagation()
          closeDropDown()

  $scope.open_dropdown = (event, elem) ->

    clicked = $(event.target).parents('li')
    if clicked.hasClass('active')
      closeDropDown()
      return false

    for exhibit in $scope.exhibits
      exhibit.active = false
    elem.active = true
    $scope.exhibit_index = elem.index
    console.log $scope.exhibits[$scope.exhibit_index]
    sharedProperties.setProperty('exhibit', elem)

    previous = findActive()

    if previous.hasClass 'dummy'
      dummy_focusout_process previous

    previous.removeClass('active')
    clicked.addClass('active')

    dropDown.find('h2').text(clicked.find('h4').text())

    unless isSameLine(clicked, previous)
      attachDropDown clicked
      $('body').scrollTo(clicked, 500, 150)
   
    item_publish_settings = dropDown.find('.item_publish_settings')
    done = dropDown.find('.done')
    close = dropDown.find('.close')
    delete_story = dropDown.find('.delete_story')

    if clicked.hasClass 'dummy'
      number = clicked.data('number')
      $('#opas_number').val(number).blur()
      $('#name').focus()
      item_publish_settings.hide()
      done.hide()
      close.show()
      delete_story.addClass('no_margin')
    else
      item_publish_settings.show()
      done.show()
      close.hide()
      delete_story.removeClass('no_margin')

  $scope.museum_type_filter = ''

  $scope.grid = ->
    collection = $('.exhibits>li.exhibit')
    tileListMargin = 59
    tileWidth = collection.width()
    tileSpace = parseInt(collection.css('margin-left')) \
      + parseInt(collection.css('margin-right'))

    $('.exhibits').css 'text-align': 'left'
    tileGrid(collection, tileWidth, tileSpace, tileListMargin)
    $(window).resize(tileGrid.bind(@, collection, tileWidth, tileSpace, tileListMargin))

  $scope.museum_list_prepare = ->
    list  = $('ul.museum_list')
    count = list.find('li').length
    width = $('body').width()
    row_count = (count * 150 + 160) / width
    if row_count > 1
      $('.museum_filters').show()
      list.width(width-200)
    else
      $('.museum_filters').hide()
      list.width(width-100)

  # TODO: find angular hook on after render and refactior. Get rid of setTimeout
  setTimeout ->
    $scope.grid()
    $scope.museum_list_prepare()
  , 100

  # $scope.current_exhibit = $scope.exhibits[0]

  sharedProperties.setProperty('exhibit', $scope.exhibits[0])

  $scope.exhibit_index = 0

  angular.element($window).bind "resize", ->
    $scope.grid()
    $scope.museum_list_prepare()

  # TODO: refactor museums search behavior according to angular way
  $('.museum_navigation_menu .search').click ->
    elem = $ @
    elem.hide()
    elem.next().show().children().first().focus()

  $('.museum_navigation_menu .search_input input').blur ->
    elem   = $ @
    parent = elem.parents('.search_input')
    elem.animate {width: '150px'}, 150,  ->
      parent.hide()
      parent.prev().show()

  $('.museum_navigation_menu .search_input input').focus ->
    input = $ @
    width = $('body').width() - 700
    if width > 150
      input.animate {width: "#{width}px"}, 300

  $scope.new_item_creation = false

  get_number = ->
    Math.round Math.random() * 10 + 11

  get_lang = ->
    'ru'

  $scope.create_new_item = () ->
    unless $scope.new_item_creation is true
      $scope.new_exhibit = {
        name: ''
        number: get_number()
        image: ''
        thumb: ''
        publish_state: 'draft'
        description: ''
        qr_code: {
          url: ''
          print_link: ''
        }
        images: [
          {
            image: ''
            thumb: ''
          }
          {
            image: ''
            thumb: ''
          }
        ]
        stories: [
          {
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
        ]
      }
      $scope.new_item_creation = true
      e = {}
      e.target = $('li.exhibit.dummy > .opener.draft')
      $scope.open_dropdown(e, $scope.new_exhibit)

  # $('#create_new_item').click ->
  #   exhibits =  $('ul.exhibits')
  #   return false if exhibits.find('li.dummy').length > 0

  #   number = get_number()

  #   dummy_item = $ new_template(number)
  #   exhibits.append dummy_item

  #   assign_click()

  #   collection = $('.exhibits>li.exhibit')
  #   tileGrid(collection, tileWidth, tileSpace, tileListMargin)

  #   exhibits.find('li.dummy').find('.opener .description').click()
  #   dropDown.find('#name').blur ->
  #     elem = $ @
  #     if elem.val() isnt ''
  #       active = findActive()
  #       active.removeClass('dummy').find('.opener').removeClass 'draft'
  #       dropDown.find('.item_publish_settings').show()
  #       dropDown.find('.done').show()
  #       dropDown.find('.close').hide()
  #       dropDown.find('.delete_story').removeClass('no_margin')
  #   false

  $scope.toggle_menu = (elem) ->
    elem = $ elem.target
    museum_nav = $('.museum_navigation_menu')
    nav        = $('.navigation')

    if museum_nav.is(':visible')
      padding    = elem.data('last-padding')
      museum_nav.slideUp(300)
      nav.addClass 'navbar-fixed-top'
      $('body').css {'padding-top':"#{padding}"}
    else
      padding    = $('body').css('padding-top')
      elem.data('last-padding', padding)
      museum_nav.slideDown(300)
      nav.removeClass 'navbar-fixed-top'
      $('body').css {'padding-top':'0px'}

  $scope.toggle_filters = (elem) ->
    elem = $ elem.target
    filters_bar = $('.filters_bar')
    nav         = $('.navigation')
    if elem.hasClass 'active'
      filters_bar.css {overflow: 'hidden'}
      filters_bar.animate {height: "0px"}, 200  
      elem.removeClass 'active'
      if nav.hasClass 'navbar-fixed-top'
        $('body').animate {'padding-top': '-=44px'}, 200
    else
      filters_bar.animate {height: "44px"}, 200, ->
        filters_bar.css {overflow: 'visible'}
      if nav.hasClass 'navbar-fixed-top'
        $('body').animate {'padding-top': '+=44px'}, 200
      elem.addClass 'active'

])

# .controller('ModalInstanceCtrl', [ '$scope', '$modalInstance', 'items', ($scope, $modalInstance, items) ->
#   $scope.items = items
#   $scope.selected = item: $scope.items[0]
#   $scope.ok = ->
#     $modalInstance.close $scope.selected.item

#   $scope.cancel = ->
#     $modalInstance.dismiss "cancel"
# ])

# Controller for editing museum
.controller('EditItemController', [ '$scope', '$http', '$filter', 'sharedProperties', '$modal', '$log', ($scope, $http, $filter, sharedProperties, $modal, $log) ->
  # TODO server sync
  $scope.exhibit = sharedProperties.getProperty('exhibit')
  $scope.items = ["item1", "item2", "item3"]
  $scope.modal_open = ->
    modalInstance = $modal.open(
      templateUrl: "myModalContent.html"
      controller: ModalInstanceCtrl
      resolve:
        items: ->
          $scope.items
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.selected = selectedItem
    ), ->
      $log.info "Modal dismissed at: " + new Date()

  $scope.$on 'exhibitChange', ->
    # $.extend true, $scope.exhibit, sharedProperties.getProperty('exhibit')
    $scope.exhibit = sharedProperties.getProperty('exhibit')
])

@ModalInstanceCtrl = ($scope, $modalInstance, items) ->
  $scope.items = items
  $scope.selected = item: $scope.items[0]
  $scope.ok = ->
    $modalInstance.close $scope.selected.item

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"