$(document).ready(function() {

    $('form').find('input[type="number"]').on('focus', function (e) {
        $(this).on('mousewheel.disableScroll', function (e) {
            e.preventDefault();
        })
    }).on('blur', function (e) {
        $(this).off('mousewheel.disableScroll')
    });

});
