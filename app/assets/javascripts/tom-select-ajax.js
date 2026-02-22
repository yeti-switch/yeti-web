(function () {
    var abortControllers = {}

    window.initTomSelectAjax = function (el) {
        var $el = $(el)
        var path = $el.attr('data-path')
        if (path.includes('?') && path.indexOf('?') === -1) path += '&'
        if (!path.includes('?') && path.indexOf('?') === -1) path += '?'
        var pathParams = $el.data('pathParams')
        var requiredParam = $el.attr('data-required-param')
        var key = 'k-' + Math.random().toString(36).substr(2, 9)

        // Build initial options from existing <option> elements
        var options = []
        var items = []
        $el.find('option').each(function () {
            if (this.value) {
                options.push({value: this.value, text: $(this).text()})
                if (this.selected) items.push(this.value)
            }
        })

        var ts = new TomSelect(el, {
            plugins: ['dropdown_input', 'clear_button'],
            valueField: 'value',
            labelField: 'text',
            searchField: 'text',
            options: options,
            maxOptions: null,
            allowEmptyOption: true,
            items: items,
            onInitialize: function () {
                this.inputValue = function () {
                    // no trim
                    return this.control_input.value
                }
            },
            shouldLoad: function (q) {
                return q.length >= 3
            },
            loadThrottle: 300,
            load: function (query, callback) {
                if (abortControllers[key]) abortControllers[key].abort()

                // Convert spaces-only query to empty for API (loads all)
                // var searchQuery = /^\s{3,}$/.test(query) ? '' : query
                var data = {'q[search_for]': query}
                if (pathParams) {
                    Object.keys(pathParams).forEach(function (name) {
                        data[name] = $(pathParams[name]).val()
                    })
                }
                if (requiredParam && !data[requiredParam]) {
                    callback()
                    return
                }

                abortControllers[key] = new AbortController()
                fetch(path + $.param(data), {signal: abortControllers[key].signal})
                    .then(function (r) {
                        return r.json()
                    })
                    .then(function (items) {
                        callback(items.map(function (i) {
                            return {value: String(i.id), text: i.value}
                        }))
                    })
                    .catch(function (e) {
                        if (e.name !== 'AbortError') console.error(e)
                        callback()
                    })
            },
            render: {
                no_results: tomSelectRenderNoResultsFunc,
                not_loading: function () {
                    return '<div class="no-results">Type 3 chars to search...</div>'
                },
                item: tomSelectRenderItemFunc
            }
        })

        // Clear when required param field becomes empty
        if (requiredParam && pathParams && pathParams[requiredParam]) {
            $(pathParams[requiredParam]).on('change', function () {
                if (!$(this).val()) {
                    ts.clear()
                    ts.clearOptions()
                }
            })
        }
    }
})()
