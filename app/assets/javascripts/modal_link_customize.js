// Customises a modal-link dialog after it opens (modal_link.js builds the form
// generically from data-inputs). Two optional data attributes on the .modal-link:
//
//   data-values='{"field":"current"}' - seed each field with a current value.
//     For an "edit current value" dialog an empty field is a footgun (submitting
//     blanks the value); checkboxes are toggled, everything else gets .val().
//
//   data-labels='{"field":"Nice Label"}' - override the auto-generated label
//     (the builder capitalises the field name, e.g. "regenerate_pdf" -> ugly).
$(document).ready(function () {
  $('body').on('modal-link:after_open', function (event, title, form, link) {
    var values = link.data('values');
    if (values) {
      $.each(values, function (name, value) {
        var field = form.find('[name="' + name + '"]');
        if (field.is(':checkbox')) {
          field.prop('checked', !!value);
        } else {
          field.val(value);
        }
      });
    }

    var labels = link.data('labels');
    if (labels) {
      $.each(labels, function (name, text) {
        form.find('[name="' + name + '"]').closest('li').find('label').text(text);
      });
    }
  });
});
