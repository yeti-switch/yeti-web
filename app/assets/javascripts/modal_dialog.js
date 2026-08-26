// ActiveAdmin 4 removed `ActiveAdmin.modal_dialog`, the jQuery UI modal that
// app/assets/javascripts/modal_link.js drives (`.modal-link` action items in
// lib/resource_dsl/acts_as_import_preview.rb and app/admin/billing/invoices.rb).
// Without it every such link threw `ReferenceError: ActiveAdmin is not defined`
// on click, so the import "Apply unique columns" / "Create new ones" flows and
// the invoice regenerate action were dead.
//
// This is ActiveAdmin 3.2.5's app/javascript/active_admin/lib/modal-dialog.js,
// ported to sprockets and exposed as a plain global rather than an ES export.
// Everything it depends on is still bundled by yeti_admin.js: jQuery UI's dialog
// widget and jquery.serialize-object.
//
// Deliberately NOT re-exposed as `ActiveAdmin.modal_dialog` — ActiveAdmin 4
// defines its own `ActiveAdmin` JS namespace, and shadowing it to restore one
// removed helper invites a collision that would be painful to debug.
//
// The `active_admin_dialog` dialogClass is part of the contract: it is what
// capybara_active_admin's `modal_dialog_selector` targets, and what the yeti
// stylesheets hook for dark mode.
(function ($) {
  'use strict';

  var INPUT_TYPES = /^(datepicker|checkbox|text|number)$/;

  function optionsHtml(opts) {
    return opts.map(function (v) {
      var $elem = $('<option></option>');
      if (Array.isArray(v)) {
        $elem.text(v[0]).val(v[1]);
      } else {
        $elem.text(v);
      }
      return $elem.wrap('<div></div>').parent().html();
    }).join('');
  }

  // @param message [String] dialog title.
  // @param inputs [Object] name -> type, where type is one of datepicker,
  //   checkbox, text, number, textarea, or an array of <option> values (which
  //   renders a <select>; array entries may be [text, value] pairs).
  // @param callback [Function] receives the serialized form object on OK.
  function ModalDialog(message, inputs, callback) {
    var html = '<form id="dialog_confirm" title="' + message + '"><ul>';

    for (var name in inputs) {
      if (!Object.prototype.hasOwnProperty.call(inputs, name)) { continue; }

      var type = inputs[name];
      var wrapper;
      var opts = null;

      if (INPUT_TYPES.test(type)) {
        wrapper = 'input';
      } else if (type === 'textarea') {
        wrapper = 'textarea';
      } else if (Array.isArray(type)) {
        wrapper = 'select';
        opts = type;
        type = '';
      } else {
        throw new Error('Unsupported input type: {' + name + ': ' + type + '}');
      }

      var klass = type === 'datepicker' ? type : '';

      html += '<li>' +
        '<label>' + name.charAt(0).toUpperCase() + name.slice(1) + '</label>' +
        '<' + wrapper + ' name="' + name + '" class="' + klass + '" type="' + type + '">' +
          (opts ? optionsHtml(opts) : '') +
        '</' + wrapper + '>' +
      '</li>';
    }

    html += '</ul></form>';

    var form = $(html).appendTo('body');
    $('body').trigger('modal_dialog:before_open', [form]);

    form.dialog({
      modal: true,
      open: function () {
        $('body').trigger('modal_dialog:after_open', [form]);
      },
      dialogClass: 'active_admin_dialog',
      buttons: {
        OK: function () {
          callback($(this).serializeObject());
          $(this).dialog('close');
        },
        Cancel: function () {
          $(this).dialog('close').remove();
        }
      }
    });
  }

  window.ModalDialog = ModalDialog;
}(jQuery));
