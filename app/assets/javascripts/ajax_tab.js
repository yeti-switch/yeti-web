function loadAjaxContent(container, url) {
    container.data('loaded', true);
    $.get(url, function (response) {
        var pre = $('<pre>');
        var code = $('<code class="json">');
        code.text(JSON.stringify(response, null, 2));
        pre.append(code);
        container.empty().append(pre);
        hljs.highlightElement(code[0]);
    }).fail(function (xhr) {
        container.empty().text('Failed to load data: ' + xhr.statusText);
    });
}

$(document).ready(function () {
    // Auto-load JSON content on page load (show pages).
    $('.ajax-load-content[data-ajax-load-url]').each(function () {
        var container = $(this);
        if (container.data('loaded')) return;
        loadAjaxContent(container, container.data('ajax-load-url'));
    });

    // Load JSON content when a tab is activated.
    $('#active_admin_content .tabs').on('tabsactivate', function (event, ui) {
        var container = ui.newPanel.find('.ajax-tab-content[data-ajax-tab-url]');
        if (container.length === 0) return;
        if (container.data('loaded')) return;
        loadAjaxContent(container, container.data('ajax-tab-url'));
    });
});
