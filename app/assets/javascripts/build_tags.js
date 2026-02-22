// Build tom-select field for routing tag ids select on update batch action form

$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    var tagsSelect = $(form).find("select[name='routing_tag_ids']").prop({
        'name': 'routing_tag_ids[]',
        'class': 'tom-select',
        'id': 'batch_update_routing_tag_ids',
        'value': null, // reset default value
        'multiple': true
    }).attr('data-allow-empty-option', true);
    var tagsCheckbox = $('#mass_update_dialog_routing_tag_ids');

    if (tagsSelect.length === 0) {
        return;
    }

    // add extra space to display tom select dropdown
    tagsSelect.parent('li').css({ paddingBottom: '80px' })

    // tom-select consider [''] as nothing selected, but in this case it's [ANY_TAG] so we must add workaround
    var onlyAnyTagHiddenField = $('<input>', {
        'type': 'hidden',
        'id': 'hidden_routing_tag_ids',
        'name': 'routing_tag_ids[]',
        'value': '',
        'disabled': true
    }).appendTo(form);

    var EmptyHiddenField = $('<input>', {
        'type': 'hidden',
        'id': 'hidden_routing_tag_ids',
        'name': 'routing_tag_ids',
        'value': '',
        'disabled': true
    }).appendTo(form);

    initTomSelect(form);
    var ts = tagsSelect[0].tomselect;

    // js array comparison is broken
    // [''] === [''] #=> false
    // [''] == [''] #=> false

    const handleRoutingTagIdsChange = () => {
        const onlyAnyTagSelected = ts.getValue().length === 1 && ts.getValue()[0] === '';
        const isEmpty = ts.getValue().length === 0;

        if (onlyAnyTagSelected) {
            onlyAnyTagHiddenField.prop('disabled', false)
            EmptyHiddenField.prop('disabled', true)
        } else if (isEmpty) {
            onlyAnyTagHiddenField.prop('disabled', true)
            EmptyHiddenField.prop('disabled', false)
        } else {
            onlyAnyTagHiddenField.prop('disabled', true)
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
            onlyAnyTagHiddenField.prop('disabled', true)
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
