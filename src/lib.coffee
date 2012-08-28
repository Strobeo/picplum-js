root = exports ? this
root.Picplum = root.Picplum || {}

# jQuery dependency for now. 
$ = jQuery

# Picplum API Base
Picplum.api_base = 'http://local.dev:3000/api/1'
# Picplum.api_base = 'https://api.picplum.com/1'

# XHR request method
# Picplum.easyXDM = easyXDM.noConflict "Picplum"
# Picplum.xhr = new Picplum.easyXDM.Rpc 
#   remote: Picplum.api_base
#   ,
#     remote:
#       request: {}

# Init Picplum library with options
Picplum.init = (@app_id, opts = {}) ->
  options = 
    insert_btns: true 
    insert_count: true 
    img_class: '.photo'
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
  console.log "PicplumJS Init(#{@app_id})"
  Picplum.PickerUI.init()
  true


# Picplum Photo Resource and methods
# ----------------------------------------

Picplum.Photo = 
  selected_count: ->
    size = 0
    console.log Picplum.selected_photos
    size++ for key of Picplum.selected_photos when Picplum.selected_photos.hasOwnProperty(key)
    size

  # Select a photo and ad to selected photos collection. 
  select: (thumb_url, url) ->
    new_id = @uniqueId()
    Picplum.selected_photos[new_id] =
      thumb_url: thumb_url
      url: url
    console.log 'Photo selected: '+new_id
    new_id

  # Remove photo from selected photo collection. 
  deselect: (id) ->
    delete Picplum.selected_photos[id] 
    console.log 'Photo de-selected: '+id
    id 

  # Generate a uuid for selected photo
  idCounter: 0
  uniqueId: (prefix = 'c') ->
    id = Picplum.Photo.idCounter++
    prefix + id

# Picplum Partner Page
Picplum.Page =
  create: ->
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
    
    req.done (data) ->
      @url = data.url
      @open()

  open: ->



Picplum.PickerUI =
  init: ->
    console.log('Picker UI Init')
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
            """
  # Insert image overlay UI for print and bindings
  photos_grid: ->
    self = @
    console.log('Picker UI Init: Photos Grid')
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
      el.css
        border: 0
        margin: 0
    else
      puid = Picplum.Photo.select el.attr('src'), el.data('highres')
      el.data('puid', puid)
      el.css
        'box-sizing': 'content-box'
        border: '4px solid black'
        margin: '-4px 0 0 -4px'

  # Select all images
  select_all: ->
    self = @
    $(Picplum.settings.img_class).each -> self.select(@)



