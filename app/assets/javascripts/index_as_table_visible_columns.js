$(document).ready(function(){
    // ActiveAdmin 4 renamed the index wrapper class from `index_as_table` to
    // `index-as-table` (see lib/active_admin/views/index_as_table.rb). While this
    // guard still named the AA3 class it never matched, so neither the "Visible
    // columns" dialog nor the reset link was ever bound — both were dead.
    // `index_as_list` is gone in AA4 and unused here, so it is dropped.
    if ($('.index-as-table table').length && $('#block_available_columns').length) {

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
