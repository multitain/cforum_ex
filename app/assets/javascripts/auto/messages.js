/* -*- coding: utf-8 -*- */
/* global cforum, t, uconf, MathJax, Mustache */

cforum.messages = {
  initMarkdown: function(elem_id) {
    var elem = $("#" + elem_id);

    if(elem.length) {
      cforum.markdown_buttons.l10n();

      elem.markdown({autofocus: false, savable: false, iconlibrary: 'fa',
                     language: 'de', hiddenButtons: 'cmdPreview',
                     disabledButtons: 'cmdPreview', resize: 'both',
                     additionalButtons: [
                       {
                         name: 'groupCustom',
                         data: [
                           cforum.markdown_buttons.noMarkdown,
                           cforum.markdown_buttons.tab,
                           cforum.markdown_buttons.hellip,
                           cforum.markdown_buttons.mdash,
                           cforum.markdown_buttons.almostEqualTo,
                           cforum.markdown_buttons.unequal,
                           cforum.markdown_buttons.times,
                           cforum.markdown_buttons.arrowRight,
                           cforum.markdown_buttons.arrowUp,
                           cforum.markdown_buttons.blackUpPointingTriangle,
                           cforum.markdown_buttons.rightwardsDoubleArrow,
                           cforum.markdown_buttons.trademark,
                           cforum.markdown_buttons.doublePunctuationMarks,
                           cforum.markdown_buttons.singlePunctuationMarks
                         ]
                       }
                     ]});

      var usg = $('#forum-usage');
      if(usg.length > 0) {
        elem.prev().append(usg);
      }
    }
  },

  maxLen: function(text) {
    var newlines = 0;

    for(var i = 0; i < text.length; ++i) {
      if(text.charAt(i) == "\n") {
        newlines++;

        if(newlines >= 3 && i >= 100) {
          return text.substr(0, i);
        }
      }

      if(i > 300) {
        return text.substr(0, i);
      }
    }

    return null;
  },

  initQuotes: function() {
    if(uconf('fold_quotes') != 'yes') {
      return;
    }

    $(".posting-content blockquote").each(function() {
      var $this = $(this);
      var txt = cforum.messages.maxLen($this.text());

      if(txt) {
        $this.css('display', 'none');
        $this.before('<blockquote class="show-quotes"><br>\n<span class="unfold">' + t('unfold_quote') + '</span></blockquote>');
        $this.prev().prepend(document.createTextNode(txt));
      }
    });

    $(".posting-content").click(function(ev) {
      var trg = $(ev.target);
      if(trg.hasClass('unfold')) {
        trg.parent().next().fadeIn('fast');
        trg.parent().remove();
      }
    });
  },

  show: function() {
    if(uconf('fold_read_nested') == 'yes' && !cforum.viewAll) {
      var nodes = $(".thread-nested:not(.archived) .message.visited:not(.active)").parent();
      nodes.addClass('folded');

      if(nodes.length > 0) {
        $('body').append('<div id="unfold-all">Alle ausklappen</div>');
        $("#unfold-all").on('click', function() {
          $('.posting-nested.folded').removeClass('folded');
          $(this).remove();
        });
      }

      $(".thread-nested").on('click', function(ev) {
        var trg = $(ev.target);

        if(!trg.is(".posting-nested")) {
          trg = trg.closest('.posting-nested');
        }

        if(trg.hasClass('folded')) {
          ev.preventDefault();
          trg.removeClass('folded');

          if($(".posting-nested.folded").length <= 0) {
            $("#unfold-all").remove();
          }
        }
      });
    }

    if($('body').hasClass('nested-view') && history.pushState) {
      $('.root a').on('click', function(event) {
        var $this = $(this);

        if($this.attr('href').match(/\/\w+\/\d+\/\w+\/\d+\/[^\/]+\/(\d+)#m\d+/)) {
          var mid = RegExp.$1;

          if(document.location.href.match(/\/\w+\/\d+\/\w+\/\d+\/[^\/]+\/(\d+)#m\d+/)) {
            var old_mid = RegExp.$1;

            if(old_mid != mid) {
              console.log(old_mid, mid);
              var new_url = document.location.href.replace(/\d+#m\d+/, mid + "#m" + mid);
              event.preventDefault();
              history.pushState(mid, "", new_url);
              $("html,body").scrollTop($("#m" + mid).offset().top);

              if(uconf('fold_read_nested') == 'yes' && !cforum.viewAll) {
                $("#m" + old_mid).closest('.posting-nested').addClass('folded');
                $("#m" + mid).closest('.posting-nested').removeClass('folded');
              }
            }
          }
        }
      });
    }
  },

  init: function() {
    var action = $('body').attr('data-action');
    cforum.tags.initTags();
    cforum.messages.initQuotes();

    if(action != 'create' && action != 'update') {
      cforum.messages.initCursor();
    }

    cforum.messages.initMarkdown("message_input");
    cforum.messages.initUpload();
    cforum.messages.initPreview("message_input", "message_problematic_site");
    cforum.messages.initMaxLengthWarnings();
    $("#message_input").mentions();
  },

  new: function() {
    if(cforum.messages.quotedMessage) {
      $(".form-actions").append("<button class=\"cf-btn quote-message\">" + t('add_quote') + "</button>");
      $('.form-actions .quote-message').on('click', cforum.messages.quoteMessage);
    }
  },

  quoteMessage: function(ev) {
    ev.preventDefault();
    $("#message_input").val($("#message_input").val() + cforum.messages.quotedMessage);
    $(".form-actions .quote-message").fadeOut('fast', function() { $(this).remove(); });
  },

  initCursor: function() {
    var content = $("#message_input");
    var subj = $("#message_subject");
    var author = $("#message_author");

    cforum.cf_threads.setCursor(author, subj, content);
  },

  initUpload: function() {
    if($("#message_input").length > 0 && window.Dropzone) {
      $("#message_input").after('<div class="image-upload">' + t('upload.image_area') + '</div>');
      $(".image-upload").dropzone({
        createImageThumbnails: false,
        maxFilesize: cforum.imageMaxSize || 2, // default to 2mb
        filesizeBase: 1024,
        url: cforum.baseUrl + 'images.json',
        clickable: true,
        acceptedFiles: 'image/*',
        previewTemplate : '<div style="display:none"></div>',

        dictDefaultMessage: t('upload.dictDefaultMessage'),
        dictFallbackMessage: t("upload.dictFallbackMessage"),
        dictFallbackText: t("upload.dictFallbackText"),
        dictFileTooBig: t('upload.dictFileTooBig'),
        dictInvalidFileType: t("upload.dictInvalidFileType"),
        dictResponseError: t("upload.dictResponseError"),
        dictCancelUpload: t("upload.dictCancelUpload"),
        dictCancelUploadConfirmation: t("upload.dictCancelUploadConfirmation"),
        dictRemoveFile: t("upload.dictRemoveFile"),
        dictMaxFilesExceeded: t("upload.dictMaxFilesExceeded"),

        fallback: function() { },
        init: function() {
          this.on("success", function(file, rsp) {
            var $msg = $("#message_input");
            var selection = $msg.getSelection();
            var md = '![' + t('upload.alternative_text') + '](' + cforum.basePath + 'images/' + rsp.path + ')';

            var imgup = $('.image-upload');
            imgup.removeClass('loading');
            imgup.html(t('upload.image_area'));

            $msg.replaceSelection(md);
            $msg.change();

            window.setTimeout(function() {
              $msg.focus();
              $msg.setSelection(selection.start + 2, selection.start + 17);
            }, 0);
          });

          this.on('error', function(file, response) {
            var msg;
            var imgup = $('.image-upload');

            if(typeof response == 'string') {
              msg = response;
            }
            else if(response.error) {
              msg = response.error;
            }
            else {
              msg = t('internal_error');
            }

            imgup.removeClass('loading');
            imgup.html(t('upload.image_area'));
            cforum.alert.error(msg);
          });

          this.on('sending', function(file, xhr, formData) {
            var imgup = $('.image-upload');
            imgup.addClass('loading');
            imgup.html("");

            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
          });
        }
      });
    }
  },

  previewTimeout: null,
  oldVal: null,
  oldUrl: null,
  initPreview: function(name, problematicUrlName) {
    if(uconf('live_preview') != 'yes') {
      return;
    }

    var frm = $("#" + name).closest("form");
    var btt = frm.find("[type=submit]");
    btt.on('mouseenter focus', function() { $(".thread-message.preview").addClass('active'); });
    btt.on('mouseleave blur', function() {
      if(frm.find("[type=submit]:hover").length <= 0 && !btt.is(":focus")) {
        $(".thread-message.preview").removeClass('active');
      }
    });

    cforum.messages.showPreview(name, problematicUrlName);
    $("input[name=preview]").remove();

    var f = function() {
      if(cforum.messages.previewTimeout) {
        window.clearTimeout(cforum.messages.previewTimeout);
        cforum.messages.previewTimeout = null;
      }

      cforum.messages.previewTimeout = window.setTimeout(function() {
        cforum.messages.showPreview(name, problematicUrlName);
      }, 500);
    };

    $("#" + name + ", #" + problematicUrlName).on('keyup change', f);
  },
  showPreview: function(name, problematicUrlName) {
    var val = $("#" + name).val();
    var problematicUrl = $("#" + problematicUrlName).val();

    if(cforum.messages.oldVal != val || cforum.messages.oldUrl != problematicUrl) {
      cforum.messages.oldVal = val;
      cforum.messages.oldUrl = problematicUrl;

      if(problematicUrl) {
        var elem = $(".thread-message.preview").find(".problematic-site");
        if(elem.length <= 0) {
          $("#on-the-fly-preview").before("<p class=\"problematic-site\"></p>");
          elem = $(".thread-message.preview").find(".problematic-site");
        }
        elem.html("<a href=\"" + Mustache.escapeHtml(problematicUrl) + "\">" + t("problematic_site") + "</a>");
      }
      else {
        $(".thread-message.preview").find(".problematic-site").remove();
      }

      $.post(cforum.baseUrl + 'preview',
             {content: val}).
        done(function(data) {
          $("#on-the-fly-preview").html(data);

          if(typeof window.MathJax !== 'undefined') {
            MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
          }
        });
    }
  },

  initMaxLengthWarnings: function() {
    var minput = $("#message_input");
    var maxLen = minput.attr('maxlength');

    if(!minput.length) {
      return;
    }

    minput.before("<span class=\"message-character-count\"></span>");
    var mcount = $(".message-character-count");

    var checkLength = function() {
      // we need to work on \015\012 line endings because HTTP defines
      // this as the correct line endings; Safari and Chrome, on the
      // other hand, work with natural line endings when getting the
      // value but with \015\012 when checking for maxlength firefox,
      // on the other hand, is consistent (it uses natural line
      // endings for both) but totally insane…
      var val = minput.val().replace(/\015\012|\012|\015/g, "\015\012");
      var len = val.length;

      mcount.text(len + " / " + maxLen);

      if(len >= maxLen) {
        minput.addClass('length-error').removeClass('length-warning');
        mcount.addClass('length-error').removeClass('length-warning');
      }
      else if(len >= maxLen - 300) {
        minput.addClass('length-warning').removeClass('length-error');
        mcount.addClass('length-warning').removeClass('length-error');
      }
      else {
        minput.removeClass('length-warning').removeClass('length-error');
        mcount.removeClass('length-warning').removeClass('length-error');
      }
    };

    checkLength();
    minput.on('keyup', checkLength);
  }
};

/* eof */
