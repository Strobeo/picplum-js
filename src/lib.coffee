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
    insert_count: true 
    img_class: '.photo'
    img_selected_class: 'selected_print'
    print_bar_class: '.print_bar'
    print_selected_btn_class: '.print_selected_btn'
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
  select: (thumb_url, url) ->
    new_id = @uniqueId()
    Picplum.selected_photos[new_id] =
      thumb_url: thumb_url
      url: url
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
  init: ->
    console.log('Picker UI Init') if Picplum.debug
    @print_bar()
    @photos_grid()
    @bind_btns()

  # Insert Print bar with buttons and selected state
  print_bar: ->
    el = $(Picplum.settings.print_bar_class)
    el.html """
      <button class='btn #{Picplum.settings.print_all_btn_class.replace('.', '')}' type='button'>Print All Photos</button>
      <button style="display: none;" class='btn #{Picplum.settings.print_selected_btn_class.replace('.', '')}' type='button'>Print Selected</button>
      <span style="display: none;" class='#{Picplum.settings.selected_count_class.replace('.', '')}'></span>
      <a href='http://local.dev:3000' class='btn open_picplum' style="display: none">Open Picplum</a>
      <div class="picplum_status">This is the current status</div>
            """

  # Insert image overlay UI for print and bindings
  photos_grid: ->
    self = @
    console.log('Picker UI Init: Photos Grid') if Picplum.debug
    el = $(Picplum.settings.img_class)
    el.on 'click', ->
      self.select(@)
      self.selected_ui()

  # Bind to print bar buttons
  bind_btns: ->
    $(Picplum.settings.print_all_btn_class).on 'click', =>
      @select_all()
      Picplum.Page.create()

    $(Picplum.settings.print_selected_btn_class).on 'click', -> Picplum.Page.create()

    $('.open_picplum').click -> 
      window.open($(@).attr('href'))
      console.log('opne link') if Picplum.debug


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
  select: (img) ->
    el = $(img)
    selected = el.data('puid')
    if selected
      Picplum.Photo.deselect selected        
      el.removeData('puid')
      .removeClass(Picplum.settings.img_selected_class)
    else
      puid = Picplum.Photo.select el.attr('src'), el.data('highres')
      el.data('puid', puid)
      .addClass(Picplum.settings.img_selected_class)

  # Select all images
  select_all: ->
    self = @
    $(Picplum.settings.img_class).each -> self.select(@)

  status: (msg = '', show = true) ->
    $(Picplum.settings.print_bar_class+' .picplum_status').toggle(show).html(msg)



