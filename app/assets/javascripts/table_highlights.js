//table rows/cells highlight
$(document).ready(function () {
    //make selectable even if there is no checkbox
    $("table.index_table tr td").click(function (e) {


        var self = $(this);
        var parent = self.closest('tr');
        if (parent.find('td.col-selectable').length == 0) {
            parent.toggleClass("selected");
        }


    })
});