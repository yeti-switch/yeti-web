//= require tom-select-rails/js/tom-select.complete
//= require tom-select-ajax
//= require tom-select-ajax-fillable

// https://tom-select.js.org/

$(document).ready(function () {
    initTomSelect($('body'))

    // ActiveAdmin 3 triggered `has_many_add:after` when its "Add New" link
    // inserted a has-many row, which is what this listener was written for.
    // ActiveAdmin 4's replacement (app/javascript/active_admin/features/has_many.js
    // #hasManyAddClick) inserts the fieldset and dispatches nothing at all, so
    // there is no event left to hook: every dynamically added row rendered its
    // selects unenhanced.
    //
    // Watch the DOM instead. This is deliberately not a click handler on
    // `.has-many-add` — that would race with ActiveAdmin's own delegated
    // handler, which inserts the row, and the winner depends on registration
    // order. Observing the insertion itself has no such ordering problem.
    $(document).on('has_many_add:after', function (e, fieldset) {
        initTomSelect(fieldset)
    })

    if (window.MutationObserver) {
        new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                Array.prototype.forEach.call(mutation.addedNodes, function (node) {
                    if (node.nodeType !== 1) return // element nodes only

                    var $node = $(node)
                    // Guarded to has-many fieldsets so tom-select's own DOM
                    // insertions do not re-enter this. initTomSelect is a no-op
                    // on already-initialised controls in any case.
                    if ($node.is('fieldset.has-many-fields') || $node.find('fieldset.has-many-fields').length) {
                        initTomSelect($node)
                    }
                })
            })
        }).observe(document.body, { childList: true, subtree: true })
    }
})

function tomSelectRenderItemFunc(data, escape) {
    return '<div><span class="item-text">' + escape(data.text) + '</span></div>'
}

function tomSelectRenderNoResultsFunc() {
    return '<div class="no-results">No results matched</div>'
}

function initTomSelect(parent, options = {}) {
    function hasBlankOption(el) {
        return $(el).find('option[value=""]').length > 0
    }

    function hasSelectedOption(el) {
        return $(el).find('option[selected]').length > 0
    }

    // Basic: .tom-select, .tom-select-wide
    parent.find('select.tom-select, select.tom-select-wide').each(function () {
        if (this.tomselect) return

        var plugins = ['dropdown_input']
        var el = this
        var $el = $(el)
        var isMultiple = !!$el.attr('multiple')
        var allowEmptyOption = !!$el.data('allow-empty-option')
        // `.tom-select-clear` adds the single clear-all button to a multi-select
        // (on top of the per-chip remove). All multi-selects get the per-chip
        // remove_button; clearOnly ones additionally get the clear_button.
        var clearOnly = $el.hasClass('tom-select-clear')
        if (hasBlankOption(el) || (isMultiple && clearOnly)) plugins.push('clear_button')
        if (isMultiple) plugins.push('remove_button')
        new TomSelect(this, {
            plugins: plugins,
            allowEmptyOption: allowEmptyOption,
            controlInput: null,
            maxOptions: null,
            loadThrottle: 0,
            refreshThrottle: 0,
            render: {
                item: tomSelectRenderItemFunc
            },
            onChange: function (value) {
                // allowEmptyOption does not work properly with multiselect, we fix it here
                // Note: js array comparison is broken
                // [''] === [''] #=> false
                // [''] == [''] #=> false
                if (allowEmptyOption && isMultiple && value.length === 1 && value[0] === "") {
                    const emptyOption = Array.from(el.options).find((option) => option.value === "")
                    emptyOption.selected = true
                }
            },
            ...options
        })
    })

    // Sortable: .tom-select-sortable (always multiple)
    parent.find('select.tom-select-sortable').each(function () {
        if (this.tomselect) return

        var plugins = ['remove_button', 'drag_drop', 'clear_button']
        var el = this
        var $el = $(el)
        var isMultiple = !!$el.attr('multiple')
        var allowEmptyOption = !!$el.data('allow-empty-option')
        var skipDropdownInput = !!$el.data('skip-dropdown-input')
        if (!skipDropdownInput) plugins.push('dropdown_input')
        if (hasBlankOption(this) && !allowEmptyOption) {
            // delete empty option from original select to avoid duplication
            $el.find('option[value=""]').remove()
        }
        new TomSelect(this, {
            plugins: plugins,
            allowEmptyOption: allowEmptyOption,
            maxOptions: null,
            loadThrottle: 0,
            refreshThrottle: 0,
            onInitialize: function () {
                // avoid selecting first option by default
                if (!hasSelectedOption(this.input)) this.clear()
            },
            onChange: function (value) {
                // allowEmptyOption does not work properly with multiselect, we fix it here
                if (allowEmptyOption && isMultiple && value.length === 1 && value[0] === "") {
                    const emptyOption = Array.from(el.options).find((option) => option.value === "")
                    emptyOption.selected = true
                }
            },
            render: {
                item: tomSelectRenderItemFunc
            },
            ...options
        })
    })

    // AJAX search: .tom-select-ajax
    parent.find('select.tom-select-ajax').each(function () {
        if (this.tomselect) return

        initTomSelectAjax(this, options)
    })

    // AJAX fillable: .tom-select-ajax-fillable
    parent.find('select.tom-select-ajax-fillable').each(function () {
        if (this.tomselect) return

        initTomSelectAjaxFillable(this, options)
    })

    // Filter form predicate selects (the "Equals / Greater / Less" dropdown that
    // sits next to the value input). ActiveAdmin 4 renamed the filter markup:
    // `form.filter_form` -> `form.filters-form` and the predicate+value wrapper
    // `div.select_and_search` -> `div.filters-form-input-group`. The predicate
    // select is still that wrapper's direct <select> child.
    parent.find('form.filters-form div.filters-form-input-group > select').each(function () {
        if (this.tomselect) return
        new TomSelect(this, {
            plugins: [],
            controlInput: null,
            maxOptions: null,
            loadThrottle: 0,
            refreshThrottle: 0,
            render: {
                item: tomSelectRenderItemFunc
            },
            ...options
        })
    })
}
