root = exports ? this
root.Picplum = root.Picplum || {}

# jQuery dependency for now. 
$ = jQuery


# Init Picplum library with options
Picplum.init = (app_id, opts = {}) ->
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

  Picplum.log 'PicplumJS Init()'
  Picplum.PickerUI.init()
  true

# Log Library
Picplum.log = (msg) ->
  console.log(msg) if Picplum.debug

# Picplum Photo Resource and methods
# ----------------------------------------

Picplum.Photo = 
  selected_count: ->
    size = 0
    Picplum.log Picplum.selected_photos
    size++ for key of Picplum.selected_photos when Picplum.selected_photos.hasOwnProperty(key)
    size

  # Select a photo and ad to selected photos collection. 
  select: (thumb_url, url) ->
    new_id = @uniqueId()
    Picplum.selected_photos[new_id] =
      thumb_url: thumb_url
      url: url
    Picplum.log 'New Photo selected'
    Picplum.log Picplum.selected_photos[new_id]
    new_id

  # Remove photo from selected photo collection. 
  deselect: (id) ->
    delete Picplum.selected_photos[id] 
    Picplum.log 'Photo de-selected => '+id
    id 

  # Generate a uuid for selected photo
  idCounter: 0
  uniqueId: (prefix = 'c') ->
    id = Picplum.Photo.idCounter++
    prefix + id


Picplum.PickerUI =
  init: ->
    Picplum.log('Picker UI Init')
    @print_bar()
    @photos_grid()

  print_bar: ->
    el = $(Picplum.settings.print_bar_class)
    el.html """
      <button class='btn #{Picplum.settings.print_all_btn_class.replace('.', '')}' type='button'>Print All Photos</button>
      <button style="display: none;" class='btn #{Picplum.settings.print_selected_btn_class.replace('.', '')}' type='button'>Print Selected</button>
      <span style="display: none;" class='#{Picplum.settings.selected_count_class.replace('.', '')}'></span>
            """

  photos_grid: ->
    Picplum.log('Picker UI Init: Photos Grid')
    el = $(Picplum.settings.img_class)
    el.on 'click', ->
      selected = $(@).data('puid')
      if selected
        Picplum.Photo.deselect selected        
        $(@).removeData('puid')
        $(@).css
          border: 0
          margin: 0
      else
        puid = Picplum.Photo.select $(@).attr('src'), $(@).data('highres')
        $(@).data('puid', puid)
        $(@).css
          'box-sizing': 'content-box'
          border: '4px solid black'
          margin: '-4px 0 0 -4px'
      Picplum.PickerUI.selected_ui()

  selected_ui: ->
    el = $(Picplum.settings.selected_count_class)
    count = Picplum.Photo.selected_count()
    Picplum.log count
    if count > 0
      el.html "<b>#{count}</b> photos selected for print"
      el.show()
      $(Picplum.settings.print_selected_btn_class).show()
    else
      el.hide()
      $(Picplum.settings.print_selected_btn_class).hide()

###
Initialize Library
Picplum.init(APP_ID, KEY,
{
img_class: 'photo', 
print_bar_class: 'print_bar', 
print_selected_btn_class: 'print_selected_btn',
print_all_btn_class: 'print_all_btn',
selected_count_class: 'selected_count',
insert_btns: true, 
insert_count: true, 
on_print: function(resp, data) {}
}) 

2. Done. 

JS API Low Level

Initialize Library
Picplum.init(APP_ID, KEY) 

Select Photo
photo_obj = Picplum.Photo.select(
thumb_url: 
full_img_url:
)

Remove Photo
Picplum.Photo.remove(photo_obj)

Create Partner Page
Picplum.Page.create({

error: function(resp) {}, 
success: function(resp, data) {}
})
Open Page
Picplum.Page.open()


###