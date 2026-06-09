// The server clock is a utility-nav menu item (see the utility_navigation menu):
//   <li id="servertime"><a href="#clock">YYYY MM DD HH MM SS ZONE</a></li>
// The link text is the per-request server time. Read it, sync to the client, and
// replace it with the two ticking lines (time + date). CSS hides the raw text
// (font-size:0) until this runs, so there is no flash.
$(document).ready(function () {
    var clock = $('#servertime > a');
    var server_time_string = (clock.text() || '').trim();
    if (!server_time_string) {
        return false;
    }

    var bits = server_time_string.split(' ');
    var server_time = new Date(bits[0], --bits[1], bits[2], bits[3], bits[4], bits[5]);
    var zone = bits[6];
    var client_time = new Date().getTime();

    var time_func = function () {
        var now = new Date();
        now.setTime(server_time.getTime() + now.getTime() - client_time);
        var parts = now.toString().split(' ');
        // Two lines: 1) time + timezone (larger), 2) day month year (smaller)
        clock.html(
            '<span class="clock-time">' + parts[4] + ' ' + zone + '</span>' +
            '<span class="clock-date">' + parts[3] + ' ' + parts[1] + ' ' + parts[2] + '</span>'
        );
    };
    time_func();
    setInterval(time_func, 1000);
});
