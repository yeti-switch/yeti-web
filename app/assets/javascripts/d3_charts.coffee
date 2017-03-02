$(document).on 'ready page:load', ->
  $('div.d3-piechart').each ->
    el = this
    nv.addGraph ->

      chart = nv.models.pieChart(
      ).x((d) ->
          d.label
      ).y((d) ->
        d.value
      ).showLabels(true)

      d3.select(el).append("svg:svg").datum($(el).data('series')).transition().call(chart)
      chart
