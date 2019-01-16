$(document).ready(function (){
    var server_time_string = $("#servertime").data('servertime');
    if (typeof(server_time_string) == 'undefined')  {
        return false;
    }

    var bits =  server_time_string.split(" ");
    var server_time =  new Date(bits[0], --bits[1], bits[2], bits[3], bits[4], bits[5]);
    var zone = bits[6];
    var client_time = new Date().getTime();
    $('#tabs').append(
        $('<li>').attr('id', 'servertime').append(
                $('<span>').css('color', 'white' )
    ));
    var time_placeholder = $('#servertime span');
    var time_func = function(){
            var now =  new Date();
            now.setTime(server_time.getTime() + now.getTime() - client_time);
            var bits = now.toString().split(' ');
            time_placeholder.html([bits[3], bits[1], bits[2], bits[4], zone].join(' '));
    }
    time_func();
    setInterval(time_func, 1000);
});
