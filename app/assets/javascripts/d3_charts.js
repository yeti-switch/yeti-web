$(document).on('ready page:load', function () {
    $('div.d3-piechart').each(function () {
        var el = this
        return nv.addGraph(function () {
            var chart = nv.models.pieChart().x(function (d) {
                return d.label
            }).y(function (d) {
                return d.value
            }).showLabels(true)
            d3.select(el).append('svg:svg').datum($(el).data('series')).transition().call(chart)
            return chart
        })
    })
})
