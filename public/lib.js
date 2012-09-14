// Generated by CoffeeScript 1.3.3

/*
    Picplum JS Library.  
    Documenation => https://www.picplum.com/developer/js
    Need help? => dev@picplum.com
*/


(function() {
  var $, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Picplum = root.Picplum || {};

  $ = jQuery;

  Picplum.api_base = 'https://www.picplum.com/api/1';

  Picplum.init = function(app_id, opts) {
    var options;
    this.app_id = app_id;
    if (opts == null) {
      opts = {};
    }
    options = {
      insert_btns: true,
      select_mode: true,
      insert_count: true,
      picplum_description: false,
      img_class: '.photo',
      img_selected_class: 'selected_print',
      print_bar_class: '.print_bar',
      print_bar_select_mode_class: '.print_bar_select',
      or_span_class: '.picplum_checkout_or',
      select_mode_btn_class: '.select_mode_btn',
      select_mode_cancel_btn_class: '.btn-inverse',
      print_selected_btn_class: '.print_selected_btn',
      select_mode_btn_text: 'Order Prints',
      print_selected_btn_text: 'Checkout',
      print_all_btn_class: '.print_all_btn',
      selected_count_class: '.selected_count',
      photos_selected_text: ' selected for print.',
      click_to_select_text: "Click on each photo you want to print. They'll be shipped and mailed to you.",
      picplum_loading_status_text: "You will now be redirected to Picplum.com to complete your order.",
      apply_styles: true,
      debug: false
    };
    Picplum.settings = $.extend(options, opts);
    Picplum.debug = Picplum.settings.debug;
    Picplum.selected_photos = {};
    if (Picplum.debug) {
      console.log("PicplumJS Init(" + this.app_id + ")");
    }
    Picplum.PickerUI.init();
    return true;
  };

  Picplum.Photo = {
    selected_count: function() {
      var key, size;
      size = 0;
      if (Picplum.debug) {
        console.log(Picplum.selected_photos);
      }
      for (key in Picplum.selected_photos) {
        if (Picplum.selected_photos.hasOwnProperty(key)) {
          size++;
        }
      }
      return size;
    },
    select: function(thumb_url, url, tw, th, w, h) {
      var new_id;
      if (tw == null) {
        tw = 0;
      }
      if (th == null) {
        th = 0;
      }
      if (w == null) {
        w = 0;
      }
      if (h == null) {
        h = 0;
      }
      new_id = this.uniqueId();
      Picplum.selected_photos[new_id] = {
        thumb_url: thumb_url,
        url: url,
        ratio: 1
      };
      if (w > 0) {
        Picplum.selected_photos[new_id]['width'] = w;
      }
      if (h > 0) {
        Picplum.selected_photos[new_id]['height'] = h;
      }
      if (tw > 0) {
        Picplum.selected_photos[new_id]['thumb_width'] = tw;
      }
      if (th > 0) {
        Picplum.selected_photos[new_id]['thumb_height'] = th;
      }
      if (tw > 0 && th > 0) {
        Picplum.selected_photos[new_id]['ratio'] = tw / th;
      }
      if (Picplum.debug) {
        console.log('Photo selected: ' + new_id);
      }
      return new_id;
    },
    deselect: function(id) {
      delete Picplum.selected_photos[id];
      if (Picplum.debug) {
        console.log('Photo de-selected: ' + id);
      }
      return id;
    },
    deselect_all: function() {
      Picplum.selected_photos = {};
      return $(Picplum.settings.img_class).removeClass(Picplum.settings.img_selected_class).removeData('puid');
    },
    idCounter: 0,
    uniqueId: function(prefix) {
      var id;
      if (prefix == null) {
        prefix = 'c';
      }
      id = Picplum.Photo.idCounter++;
      return prefix + id;
    }
  };

  Picplum.Page = {
    show_picplum_status: function() {
      Picplum.PickerUI.select_mode_ui();
      $(Picplum.settings.print_bar_class).addClass(Picplum.settings.print_bar_select_mode_class.replace('.', '')).children().hide();
      Picplum.PickerUI.status(Picplum.settings.picplum_loading_status_text);
      return $('.picplum_status').show();
    },
    create: function() {
      this.show_picplum_status();
      return this.send_data();
    },
    send_data: function() {
      var req,
        _this = this;
      return req = $.ajax({
        type: "POST",
        url: Picplum.api_base + '/pages',
        dataType: "json",
        xhrFields: {
          withCredentials: true
        },
        data: {
          app_id: Picplum.app_id,
          images: Picplum.selected_photos,
          ref_url: window.location.href
        },
        error: function() {
          return Picplum.PickerUI.status('', false);
        },
        success: function(data) {
          var url;
          Picplum.PickerUI.status('', false);
          console.info("Images Created");
          url = data.url;
          return _this.open(url);
        }
      });
    },
    open: function(url) {
      if (url == null) {
        url = '';
      }
      window.open(url, '_blank');
      window.focus();
      return false;
    }
  };

  Picplum.PickerUI = {
    select_mode: false,
    init: function() {
      if (Picplum.debug) {
        console.log('Picker UI Init');
      }
      this.print_bar();
      this.bind_btns();
      if (!!Picplum.settings.picplum_description) {
        return $('.picplum_description').show();
      }
    },
    print_bar: function() {
      var el;
      el = $(Picplum.settings.print_bar_class);
      return el.html("\n<div class=\"picplum_description\" style=\"display: none;\">Printing powered by <a href=\"https://www.picplum.com\" title=\"Picplum.com - The easiest way to send photo prints.\" target=\"_blank\">Picplum.com</a></div>\n<button style=\"display: none;\" class='btn " + (Picplum.settings.select_mode_btn_class.replace('.', '')) + "' type='button'>" + Picplum.settings.select_mode_btn_text + "</button>\n<span class=\"" + (Picplum.settings.or_span_class.replace('.', '')) + "\" style=\"display: none;\">or</span>\n<button style=\"display: none;\" class='btn " + (Picplum.settings.print_selected_btn_class.replace('.', '')) + "' type='button'>" + Picplum.settings.print_selected_btn_text + "</button>\n<span style=\"display: none;\" class='" + (Picplum.settings.selected_count_class.replace('.', '')) + "'>" + Picplum.settings.click_to_select_text + "</span>\n<div class=\"picplum_status\"><p></p></div><div style=\"clear:both;\"></div>\n");
    },
    bind_btns: function() {
      var self,
        _this = this;
      self = this;
      $(Picplum.settings.print_all_btn_class).on('click', function() {
        _this.select_all();
        return Picplum.Page.create();
      });
      $(document).on('click', "" + Picplum.settings.img_class + ".select_mode", function() {
        self.select(this);
        self.selected_ui();
        return false;
      });
      $(Picplum.settings.select_mode_btn_class).show().on('click', function() {
        if (Picplum.settings.select_mode) {
          return _this.select_mode_ui();
        }
      });
      return $(Picplum.settings.print_selected_btn_class).on('click', function() {
        return Picplum.Page.create();
      });
    },
    select_mode_ui: function() {
      var btn_el, print_bar_el;
      btn_el = $(Picplum.settings.select_mode_btn_class);
      print_bar_el = $(Picplum.settings.print_bar_class);
      $(Picplum.settings.selected_count_class).show().text(Picplum.settings.click_to_select_text);
      if (Picplum.Photo.selected_count() > 0) {
        this.selected_ui();
      }
      if (this.select_mode) {
        print_bar_el.removeClass(Picplum.settings.print_bar_select_mode_class.replace('.', ''));
        btn_el.removeClass(Picplum.settings.select_mode_cancel_btn_class.replace('.', ''));
        btn_el.text(Picplum.settings.select_mode_btn_text);
        $(Picplum.settings.or_span_class).hide();
        $(Picplum.settings.print_selected_btn_class).hide();
        $(Picplum.settings.selected_count_class).hide();
        Picplum.Photo.deselect_all();
        this.select_mode = false;
      } else {
        print_bar_el.addClass(Picplum.settings.print_bar_select_mode_class.replace('.', ''));
        btn_el.addClass(Picplum.settings.select_mode_cancel_btn_class.replace('.', ''));
        btn_el.text('Cancel');
        this.select_mode = true;
      }
      return this.load_selection();
    },
    load_selection: function() {
      var self;
      self = this;
      return $(Picplum.settings.img_class).each(function() {
        $(this).toggleClass('select_mode', self.select_mode);
        if (self.select_mode && $(this).data('puid')) {
          return $(this).addClass(Picplum.settings.img_selected_class);
        }
      });
    },
    selected_ui: function() {
      var count, el, p;
      el = $(Picplum.settings.selected_count_class);
      count = Picplum.Photo.selected_count();
      if (count > 0) {
        p = count === 1 ? 'photo' : 'photos';
        el.html(("<strong>" + count + "</strong> " + p) + Picplum.settings.photos_selected_text);
        el.show();
        $(Picplum.settings.print_selected_btn_class).show();
        return $(Picplum.settings.or_span_class).show();
      } else {
        el.hide();
        $(Picplum.settings.print_selected_btn_class).hide();
        $(Picplum.settings.or_span_class).hide();
        return $(Picplum.settings.selected_count_class).show().text(Picplum.settings.click_to_select_text);
      }
    },
    select: function(img, force) {
      var el, puid, selected, th, thumb, tw;
      if (force == null) {
        force = true;
      }
      el = $(img);
      selected = el.data('puid');
      if (selected) {
        Picplum.Photo.deselect(selected);
        return el.removeData('puid').removeClass(Picplum.settings.img_selected_class);
      } else {
        thumb = el.data('thumb') ? el.data('thumb') : el.attr('src');
        tw = el[0].naturalWidth;
        th = el[0].naturalHeight;
        puid = Picplum.Photo.select(thumb, el.data('highres'), tw, th);
        return el.data('puid', puid).addClass(Picplum.settings.img_selected_class);
      }
    },
    select_all: function() {
      var self;
      self = this;
      return $(Picplum.settings.img_class).each(function() {
        return self.select(this);
      });
    },
    status: function(msg, show) {
      if (msg == null) {
        msg = '';
      }
      if (show == null) {
        show = true;
      }
      return $(Picplum.settings.print_bar_class + ' .picplum_status').toggle(show).find('p').text(msg);
    }
  };

}).call(this);
