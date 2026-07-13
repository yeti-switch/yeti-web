(function() {
    var abortControllers = {}

    window.initTomSelectAjaxFillable = function(el, options = {}) {
        var $el = $(el)
        var skipDropdownInput = !!$el.data('skip-dropdown-input')
        var path = $el.attr('data-path')
        path += path.includes('?') ? '&' : '?'
        var pathParams = $el.data('pathParams')
        var requiredParam = $el.attr('data-required-param')
        var fillOnInit = $el.attr('data-fill-on-init')
        var key = 'k-' + Math.random().toString(36).substr(2, 9)
        var plugins = ['clear_button']
        if (!skipDropdownInput) plugins.push('dropdown_input')
        // Per-chip remove icons for multi-selects (match the non-ajax widgets).
        if ($el.attr('multiple')) plugins.push('remove_button')

        var ts = new TomSelect(el, {
            plugins: plugins,
            valueField: 'value',
            labelField: 'text',
            searchField: 'text',
            allowEmptyOption: true,
            maxOptions: null,
            controlInput: null,
            render: {
                no_results: tomSelectRenderNoResultsFunc,
                item: tomSelectRenderItemFunc
            },
            ...options
        })

        function fillOptions() {
            var data = {}
            if (pathParams) {
                Object.keys(pathParams).forEach(function(name) {
                    data[name] = $(pathParams[name]).val()
                })
            }
            if (requiredParam && !data[requiredParam]) {
                ts.clear()
                ts.clearOptions()
                return
            }

            if (abortControllers[key]) abortControllers[key].abort()
            abortControllers[key] = new AbortController()

            fetch(path + $.param(data), { signal: abortControllers[key].signal })
                .then(function(r) { return r.json() })
                .then(function(items) {
                    // Read the current selection at resolve time (not before the
                    // fetch) so a value chosen while the request was in flight is
                    // preserved instead of being wiped by ts.clear() below. This
                    // is the Account-right-after-Vendor race: the parent field
                    // change kicks off this fetch, the dependent field is filled
                    // immediately, and the late response used to clobber it.
                    // ts.getValue() reflects the live selection (property based);
                    // option[selected] only carries the server-rendered initial
                    // value, so fall back to it for the edit form.
                    var currentValue = el.multiple
                        ? $el.find('option[selected]').map(function() { return $(this).val() })
                        : (ts.getValue() || $el.find('option[selected]').val())
                    ts.clear(true)
                    ts.clearOptions()
                    var hasPrev = false
                    items.forEach(function(i) {
                        var val = String(i.id)
                        if (val === currentValue) hasPrev = true
                        ts.addOption({ value: val, text: i.value })
                    })
                    if (hasPrev) {
                        ts.setValue(currentValue, true)
                    }
                })
                .catch(function(e) {
                    if (e.name !== 'AbortError') console.error(e)
                })
        }

        // Listen to parent field changes
        if (pathParams) {
            Object.values(pathParams).forEach(function(sel) {
                $(sel).on('change', fillOptions)
            })
        }

        // Custom event support
        $el.on('tom-select:ajax-fill', fillOptions)

        if (fillOnInit) fillOptions()
    }
})()
