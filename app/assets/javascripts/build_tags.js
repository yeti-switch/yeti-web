// Build chosen field for routing tag ids select on update batch action form

$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    var tagsChosen = $(form).find("select[name='routing_tag_ids']").attr({'name': 'routing_tag_ids[]', 'class': 'chosen', 'id': 'routing_tag_ids'});

    if (tagsChosen.length === 0) {
        return;
    }

    tagsChosen.prop('value', ''); // reset default value
    tagsChosen.prop('multiple', true);

    tagsChosen.chosen({no_results_text: "No results matched", width: '240px', search_contains: true, allow_single_deselect: true});
});
