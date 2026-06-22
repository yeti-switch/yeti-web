$(document).ready(function () {

    // Filter-saving toggle: an icon-only button in the filters sidebar header.
    //   open padlock    -> saving disabled (click to enable)
    //   closed padlock  -> saving enabled  (click to disable)
    //   spinner         -> request in flight; the icon only swaps once the
    //                      server confirms with a 200.
    var $section = $('#sidebar #filters_sidebar_section');
    if ($section.length === 0) {
        return;
    }

    var ICON_ON = 'fa-lock';            // saving enabled (filters locked in place)
    var ICON_OFF = 'fa-unlock-alt';     // saving disabled
    var ICON_BUSY = 'fa-spinner fa-spin';

    var enabled = $('#active_admin_content').hasClass('with_persistent_filters');

    var $btn = $('<a href="#" role="button" class="filter_indicator_persist"><i class="fa"></i></a>');
    var $icon = $btn.find('i');
    $section.find('h3').first().append($btn);

    function render(state) {
        $icon.attr('class', 'fa ' + (state ? ICON_ON : ICON_OFF));
        $btn.toggleClass('persist', state)
            .attr('title', state ? 'Filter saving on — click to disable'
                                 : 'Filter saving off — click to enable');
    }
    render(enabled);

    $btn.on('click', function (e) {
        e.preventDefault();
        if ($btn.hasClass('busy')) {
            return;
        }
        var next = !enabled;
        $btn.addClass('busy').attr('title', 'Saving…');
        $icon.attr('class', 'fa ' + ICON_BUSY);

        // HTML format on purpose: the JSON download format is gated by
        // `config.download_links` and would be rejected by ActiveAdmin's
        // restrict_format_access! (401) on most resources.
        $.ajax(window.location.href, {
            data: { search_filter_switch: next },
            dataType: 'html'
        }).done(function () {
            enabled = next;
            $btn.removeClass('busy');
            render(enabled);
        }).fail(function () {
            $btn.removeClass('busy');
            render(enabled); // revert to the previous state on failure
            $btn.attr('title', 'Could not save — try again');
        });
    });

});
