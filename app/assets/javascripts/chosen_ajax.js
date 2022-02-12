(function ($) {

    // Ajax objects holder
    var ajaxXmlHttpRequests = {}

    $.fn.chosenAjax = function (options, chosenOptions) {
        // Call chosen
        $(this).chosen(chosenOptions)

        // Loo selectors
        $.each(this, function () {
            var select = $(this)   // Original select element
            var chosen = $(this).next('div')   // Chosen div, chosen-container

            // Create unique key for each element to be able to abort search
            // when new search triggered before previous being finished.
            var key = 'k-' + Math.floor((Math.random() * 9999999999) + 1000000000)
            select.attr('data-key', key)

            var ajaxMethod = options.ajax_method || 'GET'
            var path = select.attr('data-path')
            var emptyOption = select.attr('data-empty-option')
            var pathParams = select.data('pathParams') // data-path-params
            var requiredParam = select.attr('data-required-param')

            if (requiredParam) {
                var requiredParamSelector = pathParams[requiredParam]
                $(requiredParamSelector).on('change', function () {
                    var requiredField = $(this)
                    if (requiredField.val()) return

                    select.removeAttr('data-search-term')
                    select.find('option').remove()
                    if (emptyOption) {
                        select.append('<option value="">' + emptyOption+ '</option>')
                    } else {
                        select.append('<option value=""></option>')
                    }
                    select.val('')
                    select.trigger('chosen:updated')
                })
            }

            // Set listener on search field
            chosen.find('.search-field input, .chosen-search input').on('input', function () {
                var oldSearchTerm = select.attr('data-search-term')
                var searchTerm = $(this).val()

                // skip if search blank or equal to last search
                if (!searchTerm || oldSearchTerm === searchTerm) return

                // skip if search input has less then required min characters
                if (options.ajax_min_chars !== undefined && searchTerm.length < options.ajax_min_chars) return

                // assign data-search-term to check future changes as above
                select.attr('data-search-term', searchTerm)

                // save current selected value to restore it after options rewrite
                var currentSelectValue = select.val()

                // Set term parameter
                var ajaxData = { 'q[search_for]': searchTerm }

                // set data from options
                if (options.ajaxData) $.extend(ajaxData, options.ajaxData)

                if (pathParams) {
                    Object.keys(pathParams).forEach(function (name) {
                        ajaxData[name] = $(pathParams[name]).val()
                    })
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
                        if (select.prop('multiple')) {
                            select.find('option:not(:selected)').remove()
                        }else{
                            select.find('option').remove()
                            // chosen.find('ul.chosen-results').html('')
                        }
                        // Set new options
                        if (emptyOption) {
                            select.append('<option value="">' + emptyOption+ '</option>')
                        } else {
                            select.append('<option value=""></option>')
                        }
                        $.each(data, function (i, item) {
                            select.append('<option value="' + item.id + '">' + item.value + '</option>')
                        })
                        if (!select.prop('multiple')) select.val(currentSelectValue)
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
