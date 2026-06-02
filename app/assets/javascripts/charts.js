// Thin wrapper around Chart.js v4 for the /remote_stats endpoints:
// [{key, values: [{x, y}, ...]}, ...]
// x is a Unix-millisecond integer for time charts, or a category value
// (PDD distribution bar charts). The format is Chart.js-native — no
// per-render conversion needed.

(function (root) {
  'use strict';

  var PALETTE = [
    '#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a',
    '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94',
    '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d',
    '#17becf', '#9edae5'
  ];

  var instances = {};

  // IANA name of Rails Time.zone, exposed via meta tag from the AA initializer.
  // Falls back to browser local TZ if the tag is missing.
  function serverTimezone() {
    var tag = document.querySelector('meta[name="yeti-timezone"]');
    return (tag && tag.getAttribute('content')) || undefined;
  }

  function colorFor(index) {
    return PALETTE[index % PALETTE.length];
  }

  function destroyExisting(canvasId) {
    if (instances[canvasId]) {
      instances[canvasId].destroy();
      delete instances[canvasId];
    }
  }

  function register(canvasId, chart) {
    instances[canvasId] = chart;
    return chart;
  }

  function getCanvas(canvasId, placeholderId) {
    var canvas = document.getElementById(canvasId);
    if (!canvas) return null;
    if (placeholderId) {
      var ph = document.getElementById(placeholderId);
      if (ph) ph.classList.remove('chart-placeholder');
    }
    return canvas;
  }

  // 24-hour display formats override Chart.js's locale defaults, which use
  // 12-hour AM/PM in en-US. minUnit:'hour' stops Chart.js from picking minute
  // or finer ticks on dense 1-min/5-min data — wider zooms can still use day/
  // week ticks via autoSkip. Tokens are date-fns: HH=24h, mm=minutes.
  // Tokens are Luxon (see https://moment.github.io/luxon/#/formatting):
  // HH=24h, mm=minutes, yyyy=year, MMM=Jan/Feb, d=day, qqq=Q1/Q2.
  // zone is the server TZ so labels match Rails-formatted times elsewhere.
  function timeXScale(opts) {
    return {
      type: 'time',
      time: {
        minUnit: 'hour',
        tooltipFormat: 'yyyy-MM-dd HH:mm:ss',
        displayFormats: {
          hour:    'HH:mm',
          day:     'MMM d',
          week:    "yyyy-'W'WW",
          month:   'MMM yyyy',
          quarter: 'qqq yyyy',
          year:    'yyyy'
        }
      },
      adapters: { date: { zone: serverTimezone() } },
      title: opts.xAxisLabel ? { display: true, text: opts.xAxisLabel } : { display: false },
      ticks: { maxRotation: 45, autoSkip: true }
    };
  }

  function linearYScale(opts, extra) {
    return Object.assign({
      type: 'linear',
      title: opts.yAxisLabel ? { display: true, text: opts.yAxisLabel } : { display: false },
      ticks: opts.yTickPrecision === 'integer'
        ? { precision: 0 }
        : {}
    }, extra || {});
  }

  // mode:'x' makes the tooltip include every series at the hovered x-position,
  // even when series have different x-arrays (e.g. node #3 starts later than
  // node #1). animation:false on the tooltip removes the slide-between-points
  // delay that makes hovering feel laggy.
  function baseOptions(opts) {
    var mode = opts.interactionMode || 'x';
    return {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: mode, intersect: false, axis: 'x' },
      plugins: {
        legend: { position: 'top', align: 'end' },
        tooltip: {
          enabled: true,
          mode: mode,
          intersect: false,
          animation: false,
          position: 'nearest'
        }
      }
    };
  }

  function renderLine(canvasId, json, opts) {
    opts = opts || {};
    var canvas = getCanvas(canvasId, opts.placeholderId);
    if (!canvas) return null;
    destroyExisting(canvasId);

    var datasets = json.map(function (series, i) {
      return {
        label: series.key,
        data: series.values,
        borderColor: colorFor(i),
        backgroundColor: colorFor(i),
        fill: false,
        tension: 0,
        pointRadius: 0,
        pointHoverRadius: 4,
        borderWidth: 2
      };
    });

    var config = {
      type: 'line',
      data: { datasets: datasets },
      options: Object.assign(baseOptions(opts), {
        scales: {
          x: timeXScale(opts),
          y: linearYScale(opts)
        }
      })
    };
    return register(canvasId, new Chart(canvas, config));
  }

  function renderStackedArea(canvasId, json, opts) {
    opts = opts || {};
    var canvas = getCanvas(canvasId, opts.placeholderId);
    if (!canvas) return null;
    destroyExisting(canvasId);

    var datasets = json.map(function (series, i) {
      var color = colorFor(i);
      return {
        label: series.key,
        data: series.values,
        borderColor: color,
        backgroundColor: color,
        fill: true,
        tension: 0,
        pointRadius: 0,
        pointHoverRadius: 4,
        borderWidth: 1
      };
    });

    var config = {
      type: 'line',
      data: { datasets: datasets },
      options: Object.assign(baseOptions(opts), {
        scales: {
          x: timeXScale(opts),
          y: linearYScale(opts, { stacked: true })
        }
      })
    };
    return register(canvasId, new Chart(canvas, config));
  }

  // Discrete bar: json is [{key, values: [{x, y}]}]. x may be Unix seconds
  // (profit/duration) or a numeric category (PDD distribution).
  function renderBar(canvasId, json, opts) {
    opts = opts || {};
    var canvas = getCanvas(canvasId, opts.placeholderId);
    if (!canvas) return null;
    destroyExisting(canvasId);

    var series = json[0] || { values: [] };
    var values = series.values;
    var isTime = opts.xScale !== 'category';

    var labels = isTime
      ? values.map(function (v) { return new Date(v.x); })
      : values.map(function (v) { return v.x; });

    var data = values.map(function (v) { return v.y; });

    var bgColor;
    if (opts.colorBy === 'sign') {
      bgColor = data.map(function (y) { return y >= 0 ? '#1f77b4' : '#b22222'; });
    } else {
      bgColor = opts.color || '#1f77b4';
    }

    var config = {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: series.key,
          data: data,
          backgroundColor: bgColor,
          borderColor: bgColor,
          borderWidth: 1
        }]
      },
      options: Object.assign(baseOptions(opts), {
        plugins: {
          legend: { display: false },
          tooltip: { enabled: true }
        },
        scales: {
          x: isTime
            ? Object.assign(timeXScale(opts), { offset: true })
            : {
                type: 'linear',
                title: opts.xAxisLabel ? { display: true, text: opts.xAxisLabel } : { display: false },
                ticks: { precision: 0 }
              },
          y: linearYScale(opts)
        }
      })
    };
    return register(canvasId, new Chart(canvas, config));
  }

  // Grouped bar over a time x-axis: json is [{key, values: [{x, y}]}, ...].
  // All series share the same x ticks, so we collect the union sorted.
  function renderGroupedBar(canvasId, json, opts) {
    opts = opts || {};
    var canvas = getCanvas(canvasId, opts.placeholderId);
    if (!canvas) return null;
    destroyExisting(canvasId);

    var datasets = json.map(function (series, i) {
      return {
        label: series.key,
        data: series.values,
        backgroundColor: colorFor(i),
        borderColor: colorFor(i),
        borderWidth: 1
      };
    });

    var config = {
      type: 'bar',
      data: { datasets: datasets },
      options: Object.assign(baseOptions(opts), {
        scales: {
          x: Object.assign(timeXScale(opts), { offset: true }),
          y: linearYScale(opts)
        }
      })
    };
    return register(canvasId, new Chart(canvas, config));
  }

  root.Charts = {
    renderLine: renderLine,
    renderStackedArea: renderStackedArea,
    renderBar: renderBar,
    renderGroupedBar: renderGroupedBar
  };
})(window);
