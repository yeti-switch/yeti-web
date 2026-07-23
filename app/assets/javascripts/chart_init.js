// Wires the chart placeholders rendered by app/views/charts/*.html.erb to the
// Charts wrapper (charts.js). Each placeholder is a `.js-chart` element that
// carries its configuration in data-* attributes; this scans for them on load
// and binds the "render when its tab is opened" behaviour that used to live in a
// per-partial inline <script>.
//
// Moving this out of inline scripts lets the admin run under a Content-Security-
// Policy without `script-src 'unsafe-inline'`. Passing the config through data-*
// attributes (HTML-escaped by ERB) is also safer than interpolating request
// values into an inline script string.
(function ($) {
  'use strict';

  // Chart option object shared by every render method. Only keys actually present
  // on the element are set, so each chart gets exactly the options it declared.
  function chartOptions(el) {
    var opts = {};
    if (el.data('chartYLabel') != null) { opts.yAxisLabel = el.data('chartYLabel'); }
    if (el.data('chartXLabel') != null) { opts.xAxisLabel = el.data('chartXLabel'); }
    if (el.data('chartYPrecision') != null) { opts.yTickPrecision = el.data('chartYPrecision'); }
    if (el.data('chartXScale') != null) { opts.xScale = el.data('chartXScale'); }
    if (el.data('chartColorBy') != null) { opts.colorBy = el.data('chartColorBy'); }
    return opts;
  }

  // The only pre-render massaging any chart needs: duration is returned in
  // seconds and displayed in minutes.
  function applyTransform(name, json) {
    if (name === 'durationSeconds') {
      json[0].values = json[0].values.map(function (point) {
        return { x: point.x, y: parseFloat(point.y) / 60.0 };
      });
    }
    return json;
  }

  function render(el) {
    var url = el.data('chartUrl');
    var canvasId = el.data('chartCanvas');
    var placeholderId = el.attr('id');

    // renderRanged fetches the url itself; the bar variants take pre-fetched data.
    if (el.data('chartRender') === 'ranged') {
      Charts.renderRanged({
        url: url,
        canvasId: canvasId,
        placeholderId: placeholderId,
        type: el.data('chartType'),
        chartOpts: chartOptions(el)
      });
      return;
    }

    var method = el.data('chartRender') === 'grouped-bar' ? 'renderGroupedBar' : 'renderBar';
    var transform = el.data('chartTransform');
    $.getJSON(url, function (json) {
      var opts = chartOptions(el);
      opts.placeholderId = placeholderId;
      Charts[method](canvasId, applyTransform(transform, json), opts);
    });
  }

  $(function () {
    $('.js-chart').each(function () {
      var el = $(this);
      if (el.data('chartBound')) { return; } // idempotent if the scan runs twice
      el.data('chartBound', true);

      // Charts render lazily when their tab is opened, matching the old inline
      // behaviour. Handlers stack per chart, so several charts can share a tab.
      $("div.tabs a[href='" + el.data('chartTab') + "']").on('click.chart', function () {
        render(el);
      });

      // A few charts sit on the initially-visible tab and render immediately.
      if (el.data('chartAutoTrigger')) { render(el); }
    });
  });
}(jQuery));
