###
    Picplum JS Library.  
    Documenation => https://www.picplum.com/developer/js
    Need help? => dev@picplum.com
###

root = exports ? this
root.Picplum = root.Picplum || {}

# jQuery dependency for now. 
$ = jQuery

# Picplum API Base
# Picplum.api_base = 'http://local.dev:3000/api/1'
Picplum.api_base = 'https://www.picplum.com/api/1'


# Init Picplum library with options
Picplum.init = (@app_id, opts = {}) ->
  options = 
    insert_btns: true 
    select_mode: true 
    insert_count: true 
    picplum_description: false
    img_class: '.photo'
    img_selected_class: 'selected_print'
    print_bar_class: '.print_bar'
    print_bar_select_mode_class: '.print_bar_select'
    or_span_class: '.picplum_checkout_or'
    select_mode_btn_class: '.select_mode_btn'
    select_mode_cancel_btn_class: '.btn-inverse'
    print_selected_btn_class: '.print_selected_btn'
    select_mode_btn_text: 'Order Prints'
    print_selected_btn_text: 'Checkout'
    print_all_btn_class: '.print_all_btn'
    selected_count_class: '.selected_count'
    photos_selected_text: ' selected for print.'
    click_to_select_text: "Click on each photo you want to print. They'll be shipped and mailed to you."
    picplum_loading_status_text: "You will now be redirected to Picplum.com to complete your order."
    apply_styles: true
    debug: false


  # Merge init options with defaults into settings
  Picplum.settings = $.extend options, opts
  Picplum.debug = Picplum.settings.debug
  Picplum.selected_photos = {}
  console.log "PicplumJS Init(#{@app_id})" if Picplum.debug
  Picplum.PickerUI.init()
  true


# Picplum Photo Resource and methods
# ----------------------------------------

Picplum.Photo = 
  selected_count: ->
    size = 0
    console.log Picplum.selected_photos if Picplum.debug
    size++ for key of Picplum.selected_photos when Picplum.selected_photos.hasOwnProperty(key)
    size

  # Select a photo and add to selected photos collection. 
  select: (thumb_url, url, tw = 0, th = 0, w = 0, h = 0) ->
    new_id = @uniqueId()
    Picplum.selected_photos[new_id] =
      thumb_url: thumb_url
      url: url
      ratio: 1

    Picplum.selected_photos[new_id]['width'] = w if w > 0
    Picplum.selected_photos[new_id]['height'] = h if h > 0
    Picplum.selected_photos[new_id]['thumb_width'] = tw if tw > 0
    Picplum.selected_photos[new_id]['thumb_height'] = th if th > 0
    Picplum.selected_photos[new_id]['ratio'] = tw/th if tw > 0 and th > 0

    console.log 'Photo selected: '+new_id if Picplum.debug
    new_id

  # Remove photo from selected photo collection. 
  deselect: (id) ->
    delete Picplum.selected_photos[id] 
    console.log 'Photo de-selected: '+id if Picplum.debug
    id 

  # remove all print_selected classes on images and delete photo collection
  deselect_all: ->
    Picplum.selected_photos = {}
    $(Picplum.settings.img_class).removeClass(Picplum.settings.img_selected_class).removeData 'puid'

  # Generate a uuid for selected photo
  idCounter: 0
  uniqueId: (prefix = 'c') ->
    id = Picplum.Photo.idCounter++
    prefix + id

# Picplum Partner Page
Picplum.Page =
  show_picplum_status: ->
    Picplum.PickerUI.select_mode_ui()
    $(Picplum.settings.print_bar_class).addClass(Picplum.settings.print_bar_select_mode_class.replace('.','')).children().hide()
    Picplum.PickerUI.status Picplum.settings.picplum_loading_status_text
    $('.picplum_status').show()

  create: ->
    @show_picplum_status()
    @send_data()
  
  send_data: ->
    req = $.ajax
      type: "POST",
      url: Picplum.api_base+'/pages'
      dataType: "json"
      xhrFields:
        withCredentials: true
      data:
        app_id: Picplum.app_id
        images: Picplum.selected_photos
        ref_url: window.location.href
      error: ->
        Picplum.PickerUI.status '', false
      success: (data) =>
        Picplum.PickerUI.status '', false
        console.info "Images Created"
        url = data.url
        @open(url)

  open: (url = '') ->    
    # Open Page
    window.open(url, '_blank')
    window.focus()
    # window.location = url
    false


Picplum.PickerUI =
  select_mode: false
  init: ->
    console.log('Picker UI Init') if Picplum.debug
    @print_bar()
    @bind_btns()
    $('.picplum_description').show() if !!Picplum.settings.picplum_description 

  # Insert Print bar with buttons and selected state
  print_bar: ->
    el = $(Picplum.settings.print_bar_class)
    el.html """

      <div class="picplum_description" style="display: none;">Printing powered by <a href="https://www.picplum.com" title="Picplum.com - The easiest way to send photo prints." target="_blank">Picplum.com</a></div>
      <button style="display: none;" class='btn #{Picplum.settings.select_mode_btn_class.replace('.', '')}' type='button'>#{Picplum.settings.select_mode_btn_text}</button>
      <span class="#{Picplum.settings.or_span_class.replace('.', '')}" style="display: none;">or</span>
      <button style="display: none;" class='btn #{Picplum.settings.print_selected_btn_class.replace('.', '')}' type='button'>#{Picplum.settings.print_selected_btn_text}</button>
      <span style="display: none;" class='#{Picplum.settings.selected_count_class.replace('.', '')}'>#{Picplum.settings.click_to_select_text}</span>
      <div class="picplum_status"><p></p></div><div style="clear:both;"></div>

            """

  # Bind to print bar buttons
  bind_btns: ->
    self = @

    # Print All Button
    $(Picplum.settings.print_all_btn_class).on 'click', =>
      @select_all()
      Picplum.Page.create()

    $(document).on 'click', "#{Picplum.settings.img_class}.select_mode", ->
      self.select(@)
      self.selected_ui()
      false
    
    $(Picplum.settings.select_mode_btn_class).show().on 'click', => @select_mode_ui() if Picplum.settings.select_mode
    $(Picplum.settings.print_selected_btn_class).on 'click', -> Picplum.Page.create()

  select_mode_ui: ->
    btn_el = $(Picplum.settings.select_mode_btn_class)
    print_bar_el = $(Picplum.settings.print_bar_class)

    $(Picplum.settings.selected_count_class).show().text Picplum.settings.click_to_select_text
    @selected_ui()  if Picplum.Photo.selected_count() > 0

    if @select_mode
      print_bar_el.removeClass  Picplum.settings.print_bar_select_mode_class.replace('.','')
      btn_el.removeClass        Picplum.settings.select_mode_cancel_btn_class.replace('.','')
      btn_el.text               Picplum.settings.select_mode_btn_text #Picplum.settings.print_selected_btn_text
      $(Picplum.settings.or_span_class).hide()
      $(Picplum.settings.print_selected_btn_class).hide()
      $(Picplum.settings.selected_count_class).hide()
      Picplum.Photo.deselect_all()
      @select_mode = false
    else
      print_bar_el.addClass     Picplum.settings.print_bar_select_mode_class.replace('.','')
      btn_el.addClass           Picplum.settings.select_mode_cancel_btn_class.replace('.','')
      btn_el.text 'Cancel'
      @select_mode = true

    @load_selection()

  load_selection: ->
    self = @
    $(Picplum.settings.img_class).each ->
      $(@).toggleClass 'select_mode', self.select_mode
      $(@).addClass(Picplum.settings.img_selected_class) if self.select_mode and $(@).data('puid')

  # Selected photos state
  selected_ui: ->
    el = $(Picplum.settings.selected_count_class)
    count = Picplum.Photo.selected_count()
    if count > 0
      p = if count == 1 then 'photo' else 'photos'
      el.html "<strong>#{count}</strong> #{p}" + Picplum.settings.photos_selected_text
      el.show()
      $(Picplum.settings.print_selected_btn_class).show()
      $(Picplum.settings.or_span_class).show()
    else
      el.hide()
      $(Picplum.settings.print_selected_btn_class).hide()
      $(Picplum.settings.or_span_class).hide()
      $(Picplum.settings.selected_count_class).show().text Picplum.settings.click_to_select_text

  # Select an image
  select: (img, force = true) ->
    el = $(img)
    selected = el.data('puid')
    if selected
      Picplum.Photo.deselect selected        
      el.removeData('puid')
      .removeClass(Picplum.settings.img_selected_class)
    else
      thumb = if el.data('thumb') then el.data('thumb') else el.attr('src')
      tw = el[0].naturalWidth
      th = el[0].naturalHeight
      puid = Picplum.Photo.select thumb, el.data('highres'), tw, th
      el.data('puid', puid)
      .addClass(Picplum.settings.img_selected_class)

  # Select all images
  select_all: ->
    self = @
    $(Picplum.settings.img_class).each -> self.select(@)

  status: (msg = '', show = true) ->
    $(Picplum.settings.print_bar_class+' .picplum_status').toggle(show).find('p').text msg
