//= require jquery3
//= require jquery-ui/widgets/tooltip
//= require jquery-tablesorter
//= require jquery.dependent.fields
//= require chosen-jquery
//= require jquery-chosen-sortable
//= require active_admin/base
//= require gateway_form
//= require table_highlights
//= require import_form
//= require panel_toggle
//= require action_buttons
//= require server_clock
//= require tooltip
//= require boolean_editable
//= require dependent_fields
//= require d3
//= require nv.d3
//= require sticky_headers
//= require cdr_stats
//= require active_calls
//= require active_admin_sidebar

//= require active_admin_date_range_preset
//= require active_admin_datetimepicker
//= require active_admin_scoped_collection_actions
//= require mousewheel_disable
//= require clear_filters
//= require debug_call_form
//= require delay
//= require index_as_table_visible_columns
//= require sidebar_filter_actions
//= require modal_confirm_fix
//= require d3_charts
//= require password-toggle

//= require vendor/highlight.pack
//= require highlightjs
//= require modal_link
//= require import_apply_unique_fields
//= require chosen_ajax
//= require chosen_ajax_fillable
//= require credential_generator
//= require vendor/jquery.serialize-object.min.js
//= require build_tags


$(document).ready(function () {

    function initChosen (parent) {
        parent.find("select.chosen").chosen({
                no_results_text: 'No results matched',
                width: '240px',
                search_contains: true,
                allow_single_deselect: true
        })
        parent.find("select.chosen-wide").chosen({
            no_results_text: 'No results matched',
            width: '80%',
            search_contains: true,
            allow_single_deselect: true
        })
        parent.find("select.chosen-sortable").chosen({
            no_results_text: 'No results matched',
            width: '80%',
            search_contains: true,
            allow_single_deselect: true
        }).chosenSortable()

        parent.find("select.chosen-ajax").chosenAjax(
            {ajax_method: "GET", ajax_min_chars: 3 },
            {width: '240px', no_results_text: "No results matched", allow_single_deselect: true}
        )

        parent.find("select.chosen-ajax-fillable").chosenAjaxFillable(
            {ajax_method: "GET"},
            {
                width: '240px',
                no_results_text: "No results matched",
                allow_single_deselect: true,
                search_contains: true
            }
        )
    }

    initChosen($('body'))

    $(document).on('has_many_add:after', function (e, fieldset) {
        initChosen(fieldset)
    })

    $('.index_as_table .index_table').stickyTableHeaders();

    $('#active_admin_content .tabs').on("tabsactivate", function (event, ui) {

    }).on('tabsbeforeactivate', function (event, ui) {
        chart = $(".chart-container", $(ui.newPanel));
        $(".chart-container svg").empty();
        chart.addClass('chart-placeholder');
    });


    $('input.prefix_detector').blur(function () {
        self = $(this);
        hint = self.next();
        if (hint.hasClass('inline-hints') && $.isNumeric(self.val())) {
            hint.text('loading...');
            $.get("/system_network_prefixes/search", {prefix: self.val()}, function (json) {
                hint.html(json);
            });
        }

    });

    $('form.filter_form div.filter_date_time_range').date_range_ext_preset({
        show_time: true
    });

    $('form.formtastic li.datetime_preset_pair').date_range_ext_preset({
        show_time: true
    });

});
