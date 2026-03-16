// Build tom-select field for routing tag ids select on update batch action form

$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    var tagsSelect = $(form).find("select[name='routing_tag_ids']").attr({
        'name': 'routing_tag_ids[]',
        'class': 'tom-select',
        'id': 'batch_update_routing_tag_ids',
        'multiple': true,
        'data-allow-empty-option': true
    });
    var tagsCheckbox = $('#mass_update_dialog_routing_tag_ids');

    if (tagsSelect.length === 0) {
        return;
    }

    // add extra space to display tom select dropdown
    tagsSelect.parent('li').css({ paddingBottom: '80px' })

    var EmptyHiddenField = $('<input>', {
        'type': 'hidden',
        'id': 'hidden_routing_tag_ids',
        'name': 'routing_tag_ids',
        'value': '',
        'disabled': true
    }).appendTo(form);

    initTomSelect(form);
    var ts = tagsSelect[0].tomselect;
    ts.clear(); // reset default value

    const handleRoutingTagIdsChange = () => {
        const isEmpty = ts.getValue().length === 0;

        if (isEmpty) {
            EmptyHiddenField.prop('disabled', false)
        } else {
            EmptyHiddenField.prop('disabled', true)
        }
    }

    tagsSelect.on('change', function() {
        handleRoutingTagIdsChange()
    });

    tagsCheckbox.change(function () {
        if (tagsCheckbox.is(':checked')) {
            handleRoutingTagIdsChange();
        } else {
            EmptyHiddenField.prop('disabled', true)
        }

        // tom-select does not track changes of disabled attr of original select
        if (tagsCheckbox.is(':checked')) {
            tagsSelect[0].tomselect.enable()
        } else {
            tagsSelect[0].tomselect.disable()
        }
    });
});
