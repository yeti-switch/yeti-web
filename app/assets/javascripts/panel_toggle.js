$(document).ready(function() {
    var title = $('.toggle.panel h3').wrapInner("<span class='sidebar_title'></span>");
    title.find('span.sidebar_title').on('click', function (e) {
        $(e.target).parent().next('.panel_contents').slideToggle("fast");
        return false;
    });
});