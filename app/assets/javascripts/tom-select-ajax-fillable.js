(function() {
    var abortControllers = {}

    window.initTomSelectAjaxFillable = function(el) {
        var $el = $(el)
        var path = $el.attr('data-path')
        if (path.includes('?') && path.indexOf('?') === -1) path += '&'
        if (!path.includes('?') && path.indexOf('?') === -1) path += '?'
        var pathParams = $el.data('pathParams')
        var requiredParam = $el.attr('data-required-param')
        var fillOnInit = $el.attr('data-fill-on-init')
        var key = 'k-' + Math.random().toString(36).substr(2, 9)

        var ts = new TomSelect(el, {
            plugins: ['clear_button'],
            valueField: 'value',
            labelField: 'text',
            searchField: 'text',
            allowEmptyOption: true,
            controlInput: null, // add search box only for tom-select-ajax
            render: {
                no_results: function() {
                    return '<div class="no-results">No results matched</div>'
                },
                item: function (data, escape) {
                    return '<div><span class="item-text">' + escape(data.text) + '</span></div>'
                }
            }
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

            // by some reason el.value and ts.getValue() return empty string
            var currentValue = el.multiple
                ? $el.find('option[selected]').map(function() { return $(this).val() })
                : $el.find('option[selected]').val()
            if (abortControllers[key]) abortControllers[key].abort()
            abortControllers[key] = new AbortController()

            fetch(path + $.param(data), { signal: abortControllers[key].signal })
                .then(function(r) { return r.json() })
                .then(function(items) {
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
