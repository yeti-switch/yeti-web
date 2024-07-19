$(document).ready(function(){
    if ($('.index_as_table table, .index_as_list table').length && $('#block_available_columns').length) {

        $( "#block_available_columns" ).dialog({
            autoOpen: false,
            dialogClass: 'active_admin_dialog',
            buttons: {
                'Show': function(){
                    var $select = $(this).closest('#block_available_columns').find('select'),
                        selected_fields = $select.val();
                    $(this).parent().find('.ui-dialog-buttonset').text('Loading...');
                    $.getJSON(this.href, {index_table_visible_columns: selected_fields}, function() {
                        window.location.reload();
                    });
                },
                'Cancel': function(){
                    $(this).dialog('close');
                }
            }
        });

        $("#toggle_block_available_columns").click(function() {
            $("#block_available_columns").dialog( "open" );
        });

        $('#reset_visible_columns').click(function(){
            $.getJSON(this.href, {index_table_visible_columns: ''}, function () {
                window.location.reload();
            });
        });

    }
});
