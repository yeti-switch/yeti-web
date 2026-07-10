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

    // Activate a tab panel: load its JSON content, and lazily set the src of any
    // embedded iframe (e.g. the invoice PDF) so it is fetched on demand.
    //
    // ActiveAdmin 3 rendered jQuery UI tabs and this hooked their `tabsactivate`
    // event. ActiveAdmin 4 has no jQuery, and the tabs component
    // (lib/active_admin/views/components/tabs.rb) now emits Flowbite markup, so
    // bind to the tab button's click instead. `data-tab-target` is set there.
    $('#active_admin_content .tabs').on('click', '[data-tab-target]', function () {
        var panel = $($(this).data('tab-target'));
        if (panel.length === 0) return;

        var container = panel.find('.ajax-tab-content[data-ajax-tab-url]');
        if (container.length && !container.data('loaded')) {
            loadAjaxContent(container, container.data('ajax-tab-url'));
        }

        panel.find('iframe[data-src]').each(function () {
            if (!this.getAttribute('src')) {
                this.setAttribute('src', this.getAttribute('data-src'));
            }
        });
    });
});
