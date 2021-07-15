$(function () {
    $('.clear_filters_btn').click(function () {
        $.ajax(this.href, {
            async: false,
            data: {
                clear_filters: true
            },
            type: 'GET',
            dataType: 'html'
        })
    })
})
