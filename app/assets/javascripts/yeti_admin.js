// Yeti's own admin JS bundle (was active_admin.js under ActiveAdmin 3; renamed
// so it cannot shadow the gem's `active_admin` asset, which the importmap pins).
// ActiveAdmin 4's own JS ships as an ES module via importmap and no longer
// bundles jQuery, so `active_admin/base` is gone. jQuery stays because the
// scripts below still depend on it.
//= require jquery3
//= require jquery-ui/widgets/tooltip
// index_as_table_visible_columns.js opens the "Visible columns" chooser with
// jQuery UI's dialog. ActiveAdmin 3 loaded the whole of jQuery UI; AA4 loads no
// jQuery at all, so the widget has to be required explicitly.
//= require jquery-ui/widgets/dialog
//= require jquery-tablesorter
//= require jquery.dependent.fields
//= require gateway_form
//= require table_highlights
//= require import_form
//= require panel_toggle
//= require action_buttons
//= require server_clock
//= require scrollbar_width
//= require tooltip
//= require dependent_fields
//= require chart.umd
//= require luxon.min
//= require chartjs-adapter-luxon.umd
//= require charts
//= require cdr_stats
//= require active_calls

//= require active_admin_date_range_preset
//= require mousewheel_disable
//= require clear_filters
//= require debug_call_form
//= require delay
//= require index_as_table_visible_columns
//= require sidebar_filter_actions
//= require sorting_persist
//= require password-toggle
//= require template_playground

//= require vendor/highlightjs/highlight.min
//= require vendor/highlightjs/languages/lua.min
//= require vendor/highlightjs/languages/json.min
//= require vendor/highlightjs/languages/xml.min
//= require vendor/highlightjs/languages/django.min
//= require highlightjs
//= require modal_link
//= require modal_link_customize
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

    $('form.formtastic li.datetime_preset_pair').date_range_ext_preset({
        show_time: true
    });


});
