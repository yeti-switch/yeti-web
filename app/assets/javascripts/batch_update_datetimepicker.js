// Build date time picker for datetime fields on update batch action form

// modal dialog pulls focus back into itself, so picker popup must be whitelisted,
// same as jquery ui does it for its own datepicker
var dialogAllowInteraction = $.ui.dialog.prototype._allowInteraction;
$.ui.dialog.prototype._allowInteraction = function (event) {
    return dialogAllowInteraction.call(this, event) || !!$(event.target).closest('.xdsoft_datetimepicker').length;
};

// dialog is built after the page is loaded, so inputs of BatchUpdateForm::Base#form_data_datetime
// are not picked up by active_admin_datetimepicker itself. setupDateTimePicker is a global
// defined by that gem in app/assets/javascripts/active_admin_datetimepicker.js
$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    setupDateTimePicker(form);
});
