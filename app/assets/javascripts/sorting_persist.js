$(document).ready(function () {

    // Sort-persistence toggle: an icon-only button in the index table's id
    // column header, aligned to the right of the cell.
    //   open padlock    -> saving disabled (click to enable)
    //   closed padlock  -> saving enabled  (click to disable)
    //   spinner         -> request in flight; the icon only swaps once the
    //                      server confirms with a 200.
    // Only shown on index pages that render an id column header.
    // ActiveAdmin 4 renders `table.data-table` and tags header cells with
    // `data-column` instead of AA3's `table.index_table` / `th.col-id`.
    var $bar = $('table.data-table thead th[data-column="id"]').first();
    if ($bar.length === 0) {
        return;
    }

    var ICON_ON = 'fa-lock';            // saving enabled (sort locked in place)
    var ICON_OFF = 'fa-unlock-alt';     // saving disabled
    var ICON_BUSY = 'fa-spinner fa-spin';

    var enabled = $('#active_admin_content').hasClass('with_persistent_sorting');

    var $btn = $('<a href="#" role="button" class="sorting_indicator_persist">' +
                 '<i class="fa lock_icon"></i>' +
                 '<i class="fa fa-sort-alpha-asc sort_arrows"></i>' +
                 '</a>');
    var $icon = $btn.find('i.lock_icon');
    $bar.append($btn);

    function render(state) {
        $icon.attr('class', 'fa lock_icon ' + (state ? ICON_ON : ICON_OFF));
        $btn.toggleClass('persist', state)
            .attr('title', state ? 'Sort saving on — click to disable'
                                 : 'Sort saving off — click to enable');
    }
    render(enabled);

    $btn.on('click', function (e) {
        e.preventDefault();
        if ($btn.hasClass('busy')) {
            return;
        }
        var next = !enabled;
        $btn.addClass('busy').attr('title', 'Saving…');
        $icon.attr('class', 'fa lock_icon ' + ICON_BUSY);

        // HTML format on purpose: the JSON download format is gated by
        // `config.download_links` and would be rejected by ActiveAdmin's
        // restrict_format_access! (401) on most resources.
        $.ajax(window.location.href, {
            data: { sorting_switch: next },
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
