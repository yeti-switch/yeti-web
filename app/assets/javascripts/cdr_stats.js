// Fills the collapsible "Statistic" sidebar section on the CDRs index the first
// time it is opened (the section is declared in lib/resource_dsl/acts_as_cdr_stat.rb,
// and panel_toggle.js fires `panel:opened` after the slide finishes).
//
// The guard used to be `$('body').is('.index.cdrs')`, relying on the body classes
// ActiveAdmin 3 emitted and 4 does not. Binding straight to the section is both
// the correct precondition (it exists only on that page) and independent of the
// gem's markup for page identity.
$(document).ready(function () {
    var $section = $("#statistic_sidebar_section .panel-body");
    if ($section.length) {
        $section.one('panel:opened', function () {
            var div = $("#cdr_statistic");
            if (div) {

                var params = $('#new_q').serializeObject();
                $.getJSON("/remote_stats/cdrs_summary.json", params, function (json) {

                    div.hide();
                    $("#cdr_stat_originated_calls_count").text(json.originated_calls_count);
                    $("#cdr_stat_rerouted_calls_count").text(json.rerouted_calls_count + "(" + Number(json.rerouted_calls_percent).toFixed(2) +"%)");
                    $("#cdr_stat_termination_attempts_count").text(json.termination_attempts_count);
                    $("#cdr_stat_calls_duration").text(json.calls_duration);
                    $("#cdr_stat_acd").text(json.acd);

                    $("#cdr_stat_origination_asr").text(json.origination_asr);
                    $("#cdr_stat_termination_asr").text(json.termination_asr);
                    var currency = json.system_currency ? ' ' + json.system_currency : '';
                    $("#cdr_stat_profit").text(json.profit + currency);
                    $("#cdr_stat_origination_cost").text(json.origination_cost + currency);
                    var origByCurrency = $("#cdr_stat_origination_cost_by_currency").empty();
                    $.each(json.origination_cost_by_currency || [], function(_, e) {
                        origByCurrency.append($('<div class="cdr-stat-currency-row">').append(
                            $('<span class="cdr-stat-currency-label">').text(e.currency),
                            $('<span class="cdr-stat-currency-value">').text(e.amount)
                        ));
                    });
                    $("#cdr_stat_termination_cost").text(json.termination_cost + currency);
                    var termByCurrency = $("#cdr_stat_termination_cost_by_currency").empty();
                    $.each(json.termination_cost_by_currency || [], function(_, e) {
                        termByCurrency.append($('<div class="cdr-stat-currency-row">').append(
                            $('<span class="cdr-stat-currency-label">').text(e.currency),
                            $('<span class="cdr-stat-currency-value">').text(e.amount)
                        ));
                    });
                    $("#cdr_statistic_placeholder").css('display', 'grid');
                });
            }
        });
    }
});
