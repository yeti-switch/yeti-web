// Build chosen field for routing tag ids select on update batch action form

$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    var tagsChosen = $(form).find("select[name='routing_tag_ids']").prop({
        'name': 'routing_tag_ids[]', 
        'class': 'chosen', 
        'id': 'batch_update_routing_tag_ids',
        'value': null, // reset default value
        'multiple': true
    });
    var tagsCheckbox = $('#mass_update_dialog_routing_tag_ids');

    if (tagsChosen.length === 0) {
        return;
    }

    var hidden = $('<input>', {
        'type': 'hidden',
        'id': 'hidden_routing_tag_ids',
        'name': 'routing_tag_ids',
        'value': '',
        'disabled': true
    }).appendTo(form);

    tagsChosen.chosen({no_results_text: "No results matched", width: '240px', search_contains: true, allow_single_deselect: true});

    tagsChosen.change(function() {
        tagsChosen.val().length === 0 ? hidden.prop('disabled', false) : hidden.prop('disabled', true);
    });

    tagsCheckbox.change(function () {
        if (tagsCheckbox.is(':checked') && tagsChosen.val().length === 0) {
            hidden.prop('disabled', false);
        } else {
            hidden.prop('disabled', true);
        }
    });
});
