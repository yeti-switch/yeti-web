(function ($) {

    // Ajax objects holder
    var ajaxFillableXmlHttpRequests = {}

    $.fn.chosenAjaxFillable = function (options, chosenOptions) {
        // Call chosen
        // see https://harvesthq.github.io/chosen/options.html
        $(this).chosen(chosenOptions)

        // Loo selectors
        $.each(this, function () {
            var select = $(this)
            var chosen = $(this).next('div')

            function clearSelect() {
                select.find('option').remove()
                // Set new options
                if (emptyOption) {
                    select.append('<option value="">' + emptyOption+ '</option>')
                } else {
                    select.append('<option value=""></option>')
                }
            }

            // Create unique key for each element to be able to abort search
            // when new search triggered before previous being finished.
            var key = 'k-' + Math.floor((Math.random() * 9999999999) + 1000000000)
            select.attr('data-key', key)

            var ajaxMethod = options.ajax_method || 'GET'

            var path = select.attr('data-path')
            var emptyOption = select.attr('data-empty-option')
            var requiredParam = select.attr('data-required-param')
            var pathParams = select.data('pathParams')
            var fillOnInit = select.attr('data-fill-on-init')

            // Trigger filling select when any parent change
            Object.values(pathParams).forEach(function (paramSelector) {
                $(paramSelector).on('change', function () {
                    select.trigger('chosen:ajax-fill')
                })
            })

            select.on('chosen:ajax-fill', function () {
                // Set term parameter
                var ajaxData = {}

                // set data from options
                if (options.ajaxData) $.extend(ajaxData, options.ajaxData)

                Object.keys(pathParams).forEach(function (name) {
                    ajaxData[name] = $(pathParams[name]).val()
                })

                // clear options when required parameter is missing
                if (requiredParam && !ajaxData[requiredParam]) {
                    clearSelect()
                    select.trigger('chosen:updated')
                    return
                }

                // save current selected value to restore it after options rewrite
                var currentSelectValue = select.val()

                // Abort previous ajax request
                if (ajaxFillableXmlHttpRequests[key]) {
                    ajaxFillableXmlHttpRequests[key].abort()
                }

                // Save current ajax request object
                ajaxFillableXmlHttpRequests[key] = $.ajax({
                    url: path,
                    method: ajaxMethod,
                    type: ajaxMethod,
                    data: ajaxData,
                    dataType: 'json',
                    success: function (data) {
                        ajaxFillableXmlHttpRequests[key] = null
                        clearSelect()
                        if (data.length === 0) {
                            select.trigger('chosen:updated')
                            return
                        }

                        var hasPrevVal = false
                        $.each(data, function (i, item) {
                            if (!hasPrevVal && item.id.toString() === currentSelectValue) hasPrevVal = true
                            select.append('<option value="' + item.id + '">' + item.value + '</option>')
                        })

                        if (hasPrevVal) select.val(currentSelectValue)
                        select.trigger('chosen:updated')
                    },
                    error: function (jqXHR, exception) {
                        console.error(exception)
                        chosen.trigger('chosen:no_results')
                    }
                })
            })

            if (fillOnInit) select.trigger('chosen:ajax-fill')
        })
    }
}(jQuery))
