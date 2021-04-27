// Build chosen field for routing tag ids select on update batch action form

$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    var tagsChosen = $(form).find("select[name='routing_tag_ids']").attr({'name': 'routing_tag_ids[]', 'class': 'chosen', 'id': 'routing_tag_ids'});

    if (tagsChosen.length === 0) {
        return;
    }

    var hidden = $('<input>').attr({
        'type': 'hidden',
        'id': 'routing_tag_ids',
        'name': 'routing_tag_ids',
        'value': '',
        'disabled': true
    }).appendTo(form);

    tagsChosen.prop('value', ''); // reset default value
    tagsChosen.prop('multiple', true);

    tagsChosen.chosen({no_results_text: "No results matched", width: '240px', search_contains: true, allow_single_deselect: true});

    tagsChosen.change({hidden: hidden}, function(event){
        if ($(event.target).val() != ''){
            event.data.hidden.attr('disabled', true);
        }else{
            event.data.hidden.attr('disabled', false);
        }
    });
});

$(document).on('chosen:updated', function(event){
    if ($(event.target).prop('id') != 'routing_tag_ids') { return; }
    
    var tagChosen = $('select#routing_tag_ids.chosen');
    var disabled = tagChosen.attr('disabled') || false

    if (disabled) { 
        $("[name='routing_tag_ids']").prop('disabled', true); 
    }else if(!disabled && tagChosen.val() == ''){
        $("[name='routing_tag_ids']").prop('disabled', false); 
    }
});
