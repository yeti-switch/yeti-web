$(document).ready(function() {
    var title = $('.toggle.panel h3').wrapInner("<span class='sidebar_title'></span>");
    title.css('cursor', 'pointer').on('click', function (e) {
        var panelContents = $(this).next('.panel_contents');
        $(this).closest('.toggle.panel').toggleClass('on'); // CSS state: chevron + collapsed/expanded header
        panelContents.slideToggle("fast", function() {
            if ($(this).is(':visible')) {
                $(this).trigger('panel:opened');
            }
        });
        return false;
    });
});