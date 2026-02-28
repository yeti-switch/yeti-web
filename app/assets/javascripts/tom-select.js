//= require tom-select-rails/js/tom-select.complete
//= require tom-select-ajax
//= require tom-select-ajax-fillable

// https://tom-select.js.org/

$(document).ready(function () {
    initTomSelect($('body'))
    $(document).on('has_many_add:after', function (e, fieldset) {
        initTomSelect(fieldset)
    })
})

function tomSelectRenderItemFunc(data, escape) {
    return '<div><span class="item-text">' + escape(data.text) + '</span></div>'
}

function tomSelectRenderNoResultsFunc() {
    return '<div class="no-results">No results matched</div>'
}

function initTomSelect(parent) {
    function hasBlankOption(el) {
        return $(el).find('option[value=""]').length > 0
    }

    function hasSelectedOption(el) {
        return $(el).find('option[selected]').length > 0
    }

    // Basic: .tom-select, .tom-select-wide
    parent.find('select.tom-select, select.tom-select-wide').each(function () {
        if (this.tomselect) return

        var plugins = []
        var $el = $(this)
        var isMultiple = !!$el.attr('multiple')
        var allowEmptyOption = !!$el.data('allow-empty-option')
        var skipDropdownInput = !!$el.data('skip-dropdown-input')

        if (!isMultiple && !skipDropdownInput) plugins.push('dropdown_input')
        if (isMultiple) plugins.push('remove_button')
        if (hasBlankOption(this)) plugins.push('clear_button')
        if (hasBlankOption(this) && !allowEmptyOption) {
            // delete empty option from original select to avoid duplication
            $el.find('option[value=""]').remove()
        }
        new TomSelect(this, {
            plugins: plugins,
            allowEmptyOption: hasBlankOption(this),
            controlInput: isMultiple ? undefined : null,
            maxOptions: null,
            loadThrottle: 0,
            refreshThrottle: 0,
            onInitialize: function () {
                // avoid selecting first option by default
                if (!hasSelectedOption(this.input)) this.clear()
            },
            render: {
                item: tomSelectRenderItemFunc
            }
        })
    })

    // Sortable: .tom-select-sortable (always multiple)
    parent.find('select.tom-select-sortable').each(function () {
        if (this.tomselect) return

        var plugins = ['remove_button', 'drag_drop', 'clear_button']
        var $el = $(this)
        if (hasBlankOption(this) && !$el.data('allow-empty-option')) {
            // delete empty option from original select to avoid duplication
            $el.find('option[value=""]').remove()
        }
        new TomSelect(this, {
            plugins: plugins,
            maxOptions: null,
            loadThrottle: 0,
            refreshThrottle: 0,
            onInitialize: function () {
                // avoid selecting first option by default
                if (!hasSelectedOption(this.input)) this.clear()
            },
            render: {
                item: tomSelectRenderItemFunc
            }
        })
    })

    // AJAX search: .tom-select-ajax
    parent.find('select.tom-select-ajax').each(function () {
        if (this.tomselect) return

        initTomSelectAjax(this)
    })

    // AJAX fillable: .tom-select-ajax-fillable
    parent.find('select.tom-select-ajax-fillable').each(function () {
        if (this.tomselect) return

        initTomSelectAjaxFillable(this)
    })

    // Filter form selects
    parent.find('form.filter_form div.select_and_search > select').each(function () {
        if (this.tomselect) return
        new TomSelect(this, {
            plugins: [],
            controlInput: null,
            maxOptions: null,
            loadThrottle: 0,
            refreshThrottle: 0,
            render: {
                item: tomSelectRenderItemFunc
            }
        })
    })
}
