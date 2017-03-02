$(document).ready(function () {
    var windowWidth = $(window).width();
    var buttonsBar = $('#titlebar_right');
    var buttonsBarWidth = buttonsBar.width();
    var buttonBarPosition = windowWidth - buttonsBarWidth - 15;

    $(buttonsBar).css("left", buttonBarPosition);

    $(window).scroll(function () {
        var max_width = $(document).width() - $(window).width();
        var scroll_width = $(this).scrollLeft();
        var overflow = scroll_width > max_width ? (scroll_width - max_width) : 0;

        var buttonBarPosition = windowWidth - buttonsBarWidth - (15 + overflow);
        $(buttonsBar).css({
            'left': buttonBarPosition + scroll_width
        });
    });

    $(window).resize(function () {
        windowWidth = $(window).width();
        buttonBarPosition = windowWidth - buttonsBarWidth - 15;
        $(buttonsBar).css({
            'left': buttonBarPosition
        });
    });
});