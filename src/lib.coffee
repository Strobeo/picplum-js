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
Picplum.api_base = 'http://local.dev:3000/api/1'
# Picplum.api_base = 'https://www.picplum.com/api/1'


# Init Picplum library with options
Picplum.init = (@app_id, opts = {}) ->
  options = 
    insert_btns: true 
    select_mode: true 
    insert_count: true 
    img_class: '.photo'
    img_selected_class: 'selected_print'
    print_bar_class: '.print_bar'
    select_mode_btn_class: '.select_mode_btn'
    print_selected_btn_class: '.print_selected_btn'
    print_selected_btn_text: 'Select Photos for Print'
    print_all_btn_class: '.print_all_btn'
    selected_count_class: '.selected_count'
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

  # Select a photo and ad to selected photos collection. 
  select: (thumb_url, url, tw = 0, th = 0, w = 0, h = 0) ->
    new_id = @uniqueId()
    Picplum.selected_photos[new_id] =
      thumb_url: thumb_url
      url: url
    Picplum.selected_photos[new_id]['width'] = w if w > 0
    Picplum.selected_photos[new_id]['height'] = h if h > 0
    Picplum.selected_photos[new_id]['thumb_width'] = tw if tw > 0
    Picplum.selected_photos[new_id]['thumb_height'] = th if th > 0

    console.log 'Photo selected: '+new_id if Picplum.debug
    new_id

  # Remove photo from selected photo collection. 
  deselect: (id) ->
    delete Picplum.selected_photos[id] 
    console.log 'Photo de-selected: '+id if Picplum.debug
    id 

  # Generate a uuid for selected photo
  idCounter: 0
  uniqueId: (prefix = 'c') ->
    id = Picplum.Photo.idCounter++
    prefix + id

# Picplum Partner Page
Picplum.Page =
  create: ->
    Picplum.PickerUI.status 'Creating Print Page'
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
    $('.open_picplum').attr
      target: "_blank"
      title: "Print selected photos via Picplum.com"
      href: url 

    $(".open_picplum").trigger('click')
    window.location = url
    # false


Picplum.PickerUI =
  select_mode: false
  init: ->
    console.log('Picker UI Init') if Picplum.debug
    @print_bar()
    @bind_btns()

  # Insert Print bar with buttons and selected state
  print_bar: ->
    el = $(Picplum.settings.print_bar_class)
    el.html """
      <h5>Select and print photos via <a href="https://www.picplum.com" title="Picplum.com - Easiest way to send photo prints." target="_blank">Picplum.com</a></h5>
      <button style="display: none;" class='btn #{Picplum.settings.select_mode_btn_class.replace('.', '')}' type='button'>Select Photos for Print</button>
      <button style="display: none;" class='btn #{Picplum.settings.print_selected_btn_class.replace('.', '')}' type='button'>Print Selected</button>
      <span style="display: none;" class='#{Picplum.settings.selected_count_class.replace('.', '')}'></span>
      <a href='http://local.dev:3000' class='btn open_picplum' style="display: none">Open Picplum</a>
      <div class="picplum_status">This is the current status</div>
            """

  # Bind to print bar buttons
  bind_btns: ->
    self = @

    # Print All Button
    $(Picplum.settings.print_all_btn_class).on 'click', =>
      @select_all()
      Picplum.Page.create()

    $(document).on 'click', "#{Picplum.settings.img_class}.select_mode", ->
      console.log 'select'
      self.select(@)
      self.selected_ui()
      false
    
    $(Picplum.settings.select_mode_btn_class).show().on 'click', => @select_mode_ui() if Picplum.settings.select_mode


    $(Picplum.settings.print_selected_btn_class).on 'click', -> Picplum.Page.create()

    $('.open_picplum').click -> 
      window.open($(@).attr('href'))
      console.log('opne link') if Picplum.debug

  select_mode_ui: ->
    btn_el = $(Picplum.settings.select_mode_btn_class)
    if @select_mode
      btn_el.removeClass('btn-inverse')
      .text Picplum.settings.print_selected_btn_text
      @select_mode = false
    else
      btn_el.addClass('btn-inverse')
      .text 'Cancel'
      @select_mode = true
    @load_selection()

  select_mode_on: ->


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
      el.html "<b>#{count}</b> photos selected for print"
      el.show()
      $(Picplum.settings.print_selected_btn_class).show()
    else
      el.hide()
      $(Picplum.settings.print_selected_btn_class).hide()

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
    $(Picplum.settings.print_bar_class+' .picplum_status').toggle(show).html(msg)



