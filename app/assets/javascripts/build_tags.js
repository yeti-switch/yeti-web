// Build tom-select field for routing tag ids select on update batch action form

$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    var tagsSelect = $(form).find("select[name='routing_tag_ids']").prop({
        'name': 'routing_tag_ids[]',
        'class': 'tom-select',
        'id': 'batch_update_routing_tag_ids',
        'value': null, // reset default value
        'multiple': true
    });
    var tagsCheckbox = $('#mass_update_dialog_routing_tag_ids');

    if (tagsSelect.length === 0) {
        return;
    }

    var hidden = $('<input>', {
        'type': 'hidden',
        'id': 'hidden_routing_tag_ids',
        'name': 'routing_tag_ids',
        'value': '',
        'disabled': true
    }).appendTo(form);

    var ts = new TomSelect(tagsSelect[0], {
        plugins: ['remove_button', 'clear_button'],
        render: {
            no_results: function() {
                return '<div class="no-results">No results matched</div>';
            }
        }
    });

    tagsSelect.on('change', function() {
        ts.getValue().length === 0 ? hidden.prop('disabled', false) : hidden.prop('disabled', true);
    });

    tagsCheckbox.change(function () {
        if (tagsCheckbox.is(':checked') && ts.getValue().length === 0) {
            hidden.prop('disabled', false);
        } else {
            hidden.prop('disabled', true);
        }
    });
});
