$(document).ready(function () {
    $("#gateway_allow_origination").click(function () {
        $("#origination_settings_inputs").toggle('slow');
    });


    $("#gateway_allow_termination").click(function () {
        $("#termination_settings_inputs").toggle('slow');
    });

    $("#gateway_sst_enabled").click(function () {
        $("#session_timers_inputs").toggle('slow');
    });



});
