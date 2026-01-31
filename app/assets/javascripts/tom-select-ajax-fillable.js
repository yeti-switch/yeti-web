(function() {
    var abortControllers = {}

    window.initTomSelectAjaxFillable = function(el) {
        var $el = $(el)
        var path = $el.attr('data-path')
        var pathParams = $el.data('pathParams')
        var requiredParam = $el.attr('data-required-param')
        var fillOnInit = $el.attr('data-fill-on-init')
        var key = 'k-' + Math.random().toString(36).substr(2, 9)

        // Build initial options from existing <option> elements
        var options = []
        var items = []
        $el.find('option').each(function() {
            if (this.value) {
                options.push({ value: this.value, text: $(this).text() })
                if (this.selected) items.push(this.value)
            }
        })

        var ts = new TomSelect(el, {
            plugins: ['clear_button'],
            valueField: 'value',
            labelField: 'text',
            searchField: 'text',
            allowEmptyOption: true,
            controlInput: null, // add search box only for tom-select-ajax
            options: options,
            items: items,
            render: {
                no_results: function() {
                    return '<div class="no-results">No results matched</div>'
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

            var currentValue = ts.getValue()
            if (abortControllers[key]) abortControllers[key].abort()
            abortControllers[key] = new AbortController()

            fetch(path + '?' + $.param(data), { signal: abortControllers[key].signal })
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
                    if (hasPrev) ts.setValue(currentValue, true)
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
