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

        // tom-select marks selected options with the `selected` property and not
        // with the attribute, so `option[selected]` only ever sees the value the
        // page was rendered with, not the one selected afterwards.
        function selectedValues() {
            return $el.find('option:selected')
                .map(function() { return String($(this).val()) })
                .get()
                .filter(function(value) { return value !== '' })
        }

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
                    // read the selection right before dropping options, so a value
                    // selected while the request was in flight is kept as well
                    var prevValues = selectedValues()
                    ts.clear(true)
                    ts.clearOptions()
                    var restoreValues = []
                    items.forEach(function(i) {
                        var val = String(i.id)
                        if (prevValues.indexOf(val) !== -1) restoreValues.push(val)
                        ts.addOption({ value: val, text: i.value })
                    })
                    if (restoreValues.length) {
                        ts.setValue(el.multiple ? restoreValues : restoreValues[0], true)
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
