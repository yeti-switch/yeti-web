(function ($) {

    // Ajax objects holder
    var ajax_xml_http_request = {};

    $.fn.chosen_ajax = function (options) {
        options.width = '50%'
        // Call chosen
        $(this).chosen(options);

        // Loo selectors
        $.each(this, function (i, obj) {
            // Create unique key for each element
            var key = "k-" + Math.floor((Math.random() * 9999999999) + 1000000000);
            $(this).attr("data-key", key);
            ajax_xml_http_request[key] = new window.XMLHttpRequest();
            //
            var select = $(this);   // Original select element
            var chosen = $(this).next('div');   // Chosen div, chosen-container

            // Set listener on search field
            chosen.find('.search-field input, .chosen-search input').on('input', function () {
                var old_search_term = $(this).attr("data-search");
                var search_term = $(this).val();
                var search_input = $(this)
                if (!search_term || old_search_term == search_term
                    || (options.hasOwnProperty('ajax_min_chars') && search_term.length < options.ajax_min_chars))
                    return true;
                $(this).attr("data-search", search_term);
                var val = select.val();

                // Set Method
                if (!options.hasOwnProperty('ajax_method'))
                    options.ajax_method = "GET";

                // Set data
                if (options.hasOwnProperty('ajax_data'))
                    options.ajax_data.search_for = search_term;
                else
                    options.ajax_data = {search_for: search_term};

                // Set term parameter
                var path = select.data('path');
                if (path.indexOf('?') > 1) {
                    path += '&' + 'q[search_for]=' + search_term;
                } else if (path.indexOf('?') === -1) {
                    path += '?' + 'q[search_for]=' + search_term;
                }
                // Abort previous ajax request
                ajax_xml_http_request[key].abort();
                var xhr = $.ajax({
                    url: path,
                    method: options.ajax_method,
                    type: options.ajax_method,
                    dataType: "json",
                    success: function (data) {
                        if (data.length == 0) {
                            return true;
                        }
                        // Clear options
                        select.find('option:not(:selected)').remove();
                        chosen.find('ul.chosen-results').html('');
                        // Set new options
                        $.each(data, function (i, item) {
                            select.append('<option value="' + item.id + '">' + item.value + '</option>');
                        });
                        select.val(val);
                        select.trigger('chosen:updated');
                        //
                        chosen.find('.search-field input').click();
                        chosen.find('.chosen-search input').val(search_term);
                        chosen.find('.search-field input').val(search_term);
                        //
                        select.trigger('chosen:open');
                        //
                        chosen.find('.search-field input, .chosen-search input').attr("style", "width:  100%");
                    },
                    error: function(jqXHR, exception) {
                        chosen.trigger('chosen:no_results')
                    }
                });
                ajax_xml_http_request[key] = xhr; // Save current ajax request object
            });
        });
    };
}(jQuery));
