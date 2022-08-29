$(document).ready(function () {

    $active_calls_sorter = function(sort) {
        var $table = $('#index_table_active_calls');
        $table.tablesorter({
            headers: { 0: { sorter: false }, 1: { sorter: false }},
            widgets: ['zebra', 'columns'],
            sortList: sort
        });
        // The tablesorter lib breaks activeadmin toggle_all logic,
        // because it changes table thead DOM after actvieadmin checkboxToggler() initialized.
        // In order to fix it we need to reinitialize checkboxToggler again.
        $table.checkboxToggler();
    };
    $active_calls_sorter([]);

    if ($("#active_calls_dynamic_page").length > 0) {
         setInterval(function(){
            var active_calls_table =  $('#index_table_active_calls');
            var lastSortList = [];
            if(active_calls_table.length > 0) {
                lastSortList = active_calls_table[0].config.sortList;
            }
            params =  $('#new_q').serialize();

             var $div = $('<div>');

             $div.load('active_calls', params ,function(){

                 self = $(this);

                 content = $("#active_calls_dynamic_page ~ table", self);
                 if (content.length == 0){
                     content = $(".blank_slate_container", self );
                 }

                 content_footer  = $("#index_footer", self);
                 $("#index_footer").remove();
                 if(content_footer.length > 0){
                     $("#collection_selection").append(content_footer);
                 }


                 //if (content.length == 0){
                 //    content = $(".blank_slate_container", self );
                 //}
                // content = $("#active_calls_dynamic_page", self );


                 $("#active_calls_dynamic_page").next().replaceWith(content);
                     //.html(content.html());
                 //$(this).children(':first').unwrap();
                 $active_calls_sorter(lastSortList);
             });

            //$("#active_calls_dynamic_page").next().load('active_calls #index_table_active_calls', params ,function(){
            //    $(this).children(':first').unwrap();
            //    $active_calls_sorter(lastSortList);
            //});

        }, 15000);
     }
});

