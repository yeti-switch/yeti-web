(function ($) {

    function generateRandomKey() {
        return 'k-' + Math.floor((Math.random() * 9999999999) + 1000000000)
    }

    // Ajax objects holder
    var ajaxXmlHttpRequests = {}

    $.fn.chosen_ajax = function (options) {
        // Call chosen
        $(this).chosen(options)

        // Loo selectors
        $.each(this, function () {
            var select = $(this)   // Original select element
            var chosen = $(this).next('div')   // Chosen div, chosen-container

            // Create unique key for each element to be able to abort search
            // when new search triggered before previous being finished.
            var key = generateRandomKey()
            select.attr('data-key', key)

            select.on('change', function () {
                var childrenSelector = select.attr('data-clear-on-change')
                if (childrenSelector) {
                    $.each($(childrenSelector), function () {
                        var child = $(this)
                        child.removeAttr('data-search-term')
                        var emptyOption = child.attr('data-empty-option')
                        child.find('option').remove()
                        if (emptyOption) {
                            child.append('<option value="">' + emptyOption+ '</option>')
                        } else {
                            child.append('<option value=""></option>')
                        }
                        child.val('')
                        child.trigger('chosen:updated')
                    })
                }
            })

            // Set listener on search field
            chosen.find('.search-field input, .chosen-search input').on('input', function () {
                var requireParentSelector = select.attr('data-path-required-parent')
                if (requireParentSelector) {
                    var requireParent = $(requireParentSelector)
                    if (!$(requireParent).val()) {
                        return true
                    }
                }


                var oldSearchTerm = select.attr('data-search-term')
                var searchTerm = $(this).val()

                // skip if search blank or equal to last search
                if (!searchTerm || oldSearchTerm === searchTerm) {
                    return true
                }

                // skip if search input has less then required min characters
                if (options.hasOwnProperty('ajax_min_chars') && searchTerm.length < options.ajax_min_chars) {
                    return true
                }

                // assign data-search-term to check future changes as above
                select.attr('data-search-term', searchTerm)

                // save current selected value to restore it after options rewrite
                var currentSelectValue = select.val()

                // Set URL
                var path = select.attr('data-path')

                // Set Method
                var ajaxMethod = options.ajax_method || 'GET'

                // Set term parameter
                var ajaxData = { 'q[search_for]': searchTerm }

                // set data from options
                if (options.ajaxData) {
                    $.extend(ajaxData, options.ajaxData)
                }

                var emptyOption = select.attr('data-empty-option')

                // Set data from dependent fields (data-path-parents)
                var pathParents = select.data('pathParents')
                if (pathParents) {
                    var params = {}
                    Object.keys(pathParents).forEach(function (name) {
                        params[name] = $(pathParents[name]).val()
                    })
                    $.extend(ajaxData, params)
                }

                // Abort previous ajax request
                if (ajaxXmlHttpRequests[key]) {
                    ajaxXmlHttpRequests[key].abort()
                }

                // Save current ajax request object
                ajaxXmlHttpRequests[key] = $.ajax({
                    url: path,
                    method: ajaxMethod,
                    type: ajaxMethod,
                    data: ajaxData,
                    dataType: 'json',
                    success: function (data) {
                        ajaxXmlHttpRequests[key] = null
                        if (data.length === 0) {
                            return true
                        }
                        // Clear options
                        select.find('option').remove()
                        // chosen.find('ul.chosen-results').html('')
                        // Set new options
                        if (emptyOption) {
                            select.append('<option value="">' + emptyOption+ '</option>')
                        } else {
                            select.append('<option value=""></option>')
                        }
                        $.each(data, function (i, item) {
                            select.append('<option value="' + item.id + '">' + item.value + '</option>')
                        })
                        select.val(currentSelectValue)
                        select.trigger('chosen:updated')
                        // restores search input after ajax request
                        chosen.find('.search-field input').click()
                        chosen.find('.chosen-search input').val(searchTerm)
                        chosen.find('.search-field input').val(searchTerm)
                    },
                    error: function (jqXHR, exception) {
                        console.error(exception)
                        chosen.trigger('chosen:no_results')
                    }
                })
            })
        })
    }
}(jQuery))
