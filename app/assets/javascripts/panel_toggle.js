// Collapsible sidebar panels (sections declared with `class: 'toggle'`, e.g. the
// CDR "Statistic" section, Update Filtered, the report sidebars).
//
// ActiveAdmin 3 wrapped a section's body in `.panel_contents`. ActiveAdmin 4 —
// and our app/views/active_admin/shared/_sidebar_sections — render `.panel-body`
// instead, so the old selector matched nothing: clicking the header toggled the
// `.on` class but slid an empty jQuery set, and the body never hid or showed.
$(document).ready(function() {
    var title = $('.toggle.panel > h3').wrapInner("<span class='sidebar_title'></span>");
    title.css('cursor', 'pointer').on('click', function (e) {
        var panelContents = $(this).next('.panel-body');
        $(this).closest('.toggle.panel').toggleClass('on'); // CSS state: chevron + collapsed/expanded header
        panelContents.slideToggle("fast", function() {
            if ($(this).is(':visible')) {
                $(this).trigger('panel:opened');
            }
        });
        return false;
    });
});
