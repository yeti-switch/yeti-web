//= require jquery3
//= require jquery-ui/widgets/tooltip
//= require jquery-tablesorter
//= require jquery.dependent.fields
//= require active_admin/base
//= require gateway_form
//= require table_highlights
//= require import_form
//= require panel_toggle
//= require action_buttons
//= require server_clock
//= require theme_toggle
//= require scrollbar_width
//= require tooltip
//= require dependent_fields
//= require chart.umd
//= require luxon.min
//= require chartjs-adapter-luxon.umd
//= require charts
//= require cdr_stats
//= require active_calls
//= require active_admin_sidebar

//= require active_admin_date_range_preset
//= require active_admin_datetimepicker
//= require datetimepicker_dark
//= require active_admin_scoped_collection_actions
//= require mousewheel_disable
//= require clear_filters
//= require debug_call_form
//= require delay
//= require index_as_table_visible_columns
//= require sidebar_filter_actions
//= require sorting_persist
//= require modal_confirm_fix
//= require password-toggle

//= require vendor/highlightjs/highlight.min
//= require vendor/highlightjs/languages/lua.min
//= require vendor/highlightjs/languages/json.min
//= require vendor/highlightjs/languages/xml.min
//= require vendor/highlightjs/languages/django.min
//= require highlightjs
//= require modal_link
//= require import_apply_unique_fields
//= require tom-select
//= require credential_generator
//= require vendor/jquery.serialize-object.min.js
//= require build_tags
//= require ajax_tab
//= require rtp_diagram


$(document).ready(function () {

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
            $.get("/system_network_prefixes/prefix_hint", {prefix: self.val()}, function (json) {
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
