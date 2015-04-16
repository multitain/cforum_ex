/* -*- coding: utf-8 -*- */
/* global cforum, t */

cforum.markdown_buttons = {
  tab: {
    name: 'cmdTab',
    toggle: false,
    title: "Tabulator",
    icon: 'fa fa-indent',
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("\t");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  hellip: {
    name: 'cmdHellips',
    toggle: false,
    title: "… (Horizontal Ellipsis)",
    btnText: "…",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("…");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  mdash: {
    name: 'cmdMdash',
    toggle: false,
    title: "– (em dash)",
    btnText: "–",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("–");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  almostEqualTo: {
    name: 'cmdAlmostEqualTo',
    toggle: false,
    title: "≈ (almost equal to)",
    btnText: "≈",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("≈");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  unequal: {
    name: 'cmdUnequal',
    toggle: false,
    title: "≠ (unequal)",
    btnText: "≠",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("≠");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  times: {
    name: 'cmdTimes',
    toggle: false,
    title: "× (times)",
    btnText: "×",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("×");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  arrowRight: {
    name: 'cmdArrowRight',
    toggle: false,
    title: "→ (arrow right)",
    btnText: "→",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("→");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  arrowUp: {
    name: 'cmdArrowUp',
    toggle: false,
    title: "↑ (arrow up)",
    btnText: "↑",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("↑");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  blackUpPointingTriangle: {
    name: 'cmdBlackUpPointingTriangle',
    toggle: false,
    title: "▲ (Black up pointing triangle)",
    btnText: "▲",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("▲");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  rightwardsDoubleArrow: {
    name: 'cmdRightwardsDoubleArrow',
    toggle: false,
    title: "⇒ (Rightwards double arrow)",
    btnText: "⇒",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("⇒");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  trademark: {
    name: 'cmdTrademark',
    toggle: false,
    title: "™ (trademark)",
    btnText: "™",
    callback: function(e) {
      var cursor, selected = e.getSelection();

      e.replaceSelection("™");
      cursor = selected.start;

      e.setSelection(cursor + 1, cursor + 1);
    }
  },

  doublePunctuationMarks: {
    name: 'cmdDoublePunctuationMarks',
    title: "„“ (double punctuation marks)",
    btnText: "„“",
    callback: function(e) {
      var chunk = "", cursor, selected = e.getSelection(), content = e.getContent();

      if(selected.length !== 0) {
        chunk = selected.text;
      }

      if(content.substr(selected.start-1,1) === '„' && content.substr(selected.end,1) === '“' ) {
        e.setSelection(selected.start - 1,selected.end + 1);
        e.replaceSelection(chunk);
        cursor = selected.start - 1;
      }
      else {
        e.replaceSelection("„" + chunk + "“");
        cursor = selected.start + 1;
      }

      e.setSelection(cursor, cursor + chunk.length);
    }
  },

  singlePunctuationMarks: {
    name: 'cmdSingleePunctuationMarks',
    title: "‚‘ (single punctuation marks)",
    btnText: "‚‘",
    callback: function(e) {
      var chunk = "", cursor, selected = e.getSelection(), content = e.getContent();

      if(selected.length !== 0) {
        chunk = selected.text;
      }

      if(content.substr(selected.start-1,1) === '‚' && content.substr(selected.end,1) === '‘' ) {
        e.setSelection(selected.start - 1,selected.end + 1);
        e.replaceSelection(chunk);
        cursor = selected.start - 1;
      }
      else {
        e.replaceSelection("‚" + chunk + "‘");
        cursor = selected.start + 1;
      }

      e.setSelection(cursor, cursor + chunk.length);
    }
  },

  l10n: function() {
    for(var button in cforum.markdown_buttons) {
      if(button != 'l10n') {
        cforum.markdown_buttons[button].title = t("buttons." + button + ".title");
        cforum.markdown_buttons[button].text = t("buttons." + button + ".text");
      }
    }
  }
};


/* eof */
