$(document).ready(function () {

    // Reset button + Active indicator
    if ($('#sidebar #filters_sidebar_section').length > 0) {

        var $filter_wrapper = $('#sidebar #filters_sidebar_section'),
            paramsStr = window.location.search;

        $filter_wrapper.on('click', '.filter_indicator_btn_reset', function(e){
            e.preventDefault();
            $(this).text('Wait...');
            $filter_wrapper.find('.clear_filters_btn').trigger('click');
        });

        if (paramsStr.indexOf('&q%5B') >= 0 || paramsStr.indexOf('&q[') >= 0 ||
            $('#active_admin_content').hasClass('with_default_filters'))
        {
            // Filters active
            $filter_wrapper.find('h3').append(
                '<span class="filter_indicator_btn_reset" title="Clear Filters">Reset</span>'
            );
        }

        // Filter Persistent switcher
        if ($('#sidebar #filters_sidebar_section').length > 0) {
            var switcher_checked = $('#active_admin_content').hasClass('with_persistent_filters');

            $filter_wrapper.find('h3').append('<label class="filter_indicator_persist' + ((switcher_checked) ? ' persist' : '') + '">Persist ' +
                '<input type="checkbox" name="filter_persistent_switcher" value="Y" ' + ((switcher_checked) ? 'checked' : '') + ' /></label>');

            $filter_wrapper.find('[name=filter_persistent_switcher]').on('change', function(){
                $.getJSON(this.href, {search_filter_switch: this.checked});
                $(this).parent().toggleClass('persist');
            });
        }
    }

});