$(document).ready(function () {
    if ($('body').is('.index.cdrs')) {
        $("#statistic_sidebar_section h3 span.sidebar_title").on('click', function (e) {
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
                    $("#cdr_stat_profit").text(json.profit);
                    $("#cdr_stat_origination_cost").text(json.origination_cost);
                    $("#cdr_stat_termination_cost").text(json.termination_cost);
                    $("#cdr_statistic_placeholder").show();
                });
            }
        });
    }

    if ($('body').is('.index.cdr_cdr_archives')) {
        $("#statistic_sidebar_section h3 span.sidebar_title").on('click', function (e) {
            var div = $("#cdr_statistic");
            if (div) {

                var params = $('#new_q').serializeObject();
                $.getJSON("/remote_stats/cdrs_summary_archive.json", params, function (json) {

                    div.hide();
                    $("#cdr_stat_originated_calls_count").text(json.originated_calls_count);
                    $("#cdr_stat_rerouted_calls_count").text(json.rerouted_calls_count + "(" + Number(json.rerouted_calls_percent).toFixed(2) +"%)");
                    $("#cdr_stat_termination_attempts_count").text(json.termination_attempts_count);
                    $("#cdr_stat_calls_duration").text(json.calls_duration);
                    $("#cdr_stat_acd").text(json.acd);

                    $("#cdr_stat_origination_asr").text(json.origination_asr);
                    $("#cdr_stat_termination_asr").text(json.termination_asr);
                    $("#cdr_stat_profit").text(json.profit);
                    $("#cdr_stat_origination_cost").text(json.origination_cost);
                    $("#cdr_stat_termination_cost").text(json.termination_cost);
                    $("#cdr_statistic_placeholder").show();
                });
            }
        });
    }
});