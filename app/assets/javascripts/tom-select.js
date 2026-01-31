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

function initTomSelect(parent) {
    function hasBlankOption(el) {
        return $(el).find('option[value=""]').length > 0
    }

    // Basic: .tom-select
    parent.find('select.tom-select').each(function() {
        if (this.tomselect) return

        new TomSelect(this, {
            plugins: hasBlankOption(this) ? [] : ['clear_button'],
            allowEmptyOption: true,
            controlInput: null // add search box only for tom-select-ajax
        })
    })

    // Wide: .tom-select-wide
    parent.find('select.tom-select-wide').each(function() {
        if (this.tomselect) return

        new TomSelect(this, {
            plugins: hasBlankOption(this) ? [] : ['clear_button'],
            allowEmptyOption: true,
            controlInput: null // add search box only for tom-select-ajax
        })
    })

    // Sortable: .tom-select-sortable
    parent.find('select.tom-select-sortable').each(function() {
        if (this.tomselect) return
        var plugins = ['remove_button', 'drag_drop']
        if (!hasBlankOption(this)) plugins.push('clear_button')
        new TomSelect(this, {
            plugins: plugins,
            controlInput: null // add search box only for tom-select-ajax
        })
    })

    // AJAX search: .tom-select-ajax
    parent.find('select.tom-select-ajax').each(function() {
        if (this.tomselect) return
        initTomSelectAjax(this)
    })

    // AJAX fillable: .tom-select-ajax-fillable
    parent.find('select.tom-select-ajax-fillable').each(function() {
        if (this.tomselect) return
        initTomSelectAjaxFillable(this)
    })

    // Filter form selects (disable search)
    parent.find('form.filter_form div.select_and_search > select').each(function() {
        if (this.tomselect) return
        new TomSelect(this, { controlInput: null })
    })
}
