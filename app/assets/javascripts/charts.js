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

  // Destroy any chart bound to this canvas — both via our own registry AND
  // via Chart.js's global canvas tracking. Belt-and-suspenders: if a chart
  // was created without going through `register` (or another tab activation
  // raced ahead), Chart.getChart() catches it.
  function destroyExisting(canvasId) {
    if (instances[canvasId]) {
      instances[canvasId].destroy();
      delete instances[canvasId];
    }
    var canvas = document.getElementById(canvasId);
    if (canvas) {
      var orphan = Chart.getChart(canvas);
      if (orphan) orphan.destroy();
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
      ticks: { maxRotation: 45, autoSkip: true, color: tickColor },
      grid: { color: gridColor },
      border: { color: gridColor }
    };
  }

  function linearYScale(opts, extra) {
    return Object.assign({
      type: 'linear',
      title: opts.yAxisLabel ? { display: true, text: opts.yAxisLabel } : { display: false },
      ticks: opts.yTickPrecision === 'integer'
        ? { precision: 0, color: tickColor }
        : { color: tickColor },
      grid: { color: gridColor },
      border: { color: gridColor }
    }, extra || {});
  }

  // mode:'index' picks exactly one point per dataset (the one at the cursor's
  // x-index), so the tooltip always shows one entry per series without
  // duplicates from dense-data hitbox overlap. This requires all series to
  // share the same x-array — see alignToCommonXAxis below, which pads missing
  // x's with 0 so series that started later (or have gaps) still align.
  // animation:false removes the slide-between-points delay.
  // Register a 'cursor' tooltip positioner once: place the tooltip at the mouse
  // cursor instead of snapping it to the nearest/average data point. Built-in
  // positioners ('nearest'/'average') ignore the cursor's exact location.
  function ensureCursorPositioner() {
    if (root.Chart && Chart.Tooltip && Chart.Tooltip.positioners &&
        !Chart.Tooltip.positioners.cursor) {
      Chart.Tooltip.positioners.cursor = function (_elements, eventPosition) {
        return { x: eventPosition.x, y: eventPosition.y };
      };
    }
  }

  // Read a value from the active theme palette (the --aa-* CSS custom properties
  // defined by active_admin_theme), with a fallback. Used so chart text/grid/
  // crosshair colors follow light/dark mode.
  function cssVar(name, fallback) {
    try {
      var v = getComputedStyle(document.documentElement).getPropertyValue(name).trim();
      return v || fallback;
    } catch (e) { return fallback; }
  }

  // Scriptable colors for axis grid / ticks / legend. Chart.js calls these at
  // draw time, so they return the LIVE theme value — charts follow a runtime
  // light/dark switch (a plain color is captured at creation and would freeze).
  function gridColor() { return cssVar('--aa-border', 'rgba(0, 0, 0, 0.1)'); }
  function tickColor() { return cssVar('--aa-text-muted', '#666'); }

  // Point Chart.js's global font (ticks, legend) and grid/border colors at the
  // theme palette. Read at build time; charts already drawn keep their colors
  // until the next render (e.g. page reload or zoom change).
  function applyChartTheme() {
    if (!root.Chart) return;
    Chart.defaults.color = cssVar('--aa-text-muted', '#666');
    Chart.defaults.borderColor = cssVar('--aa-border', 'rgba(0, 0, 0, 0.1)');
  }

  // Re-theme already-drawn charts when the color mode changes at runtime. Grid /
  // tick colors are read from the theme palette at draw time, so without this a
  // toggle (or OS change) leaves charts showing the previous mode's grid (a light
  // grid on a now-dark page reads as white; a dark grid on light as black) until
  // the page is reloaded. update() re-resolves options from the new defaults.
  function refreshChartsTheme() {
    applyChartTheme();
    // Grid/tick/legend colors are scriptable (read the live theme at draw time),
    // so a redraw is all that's needed to pick up the new mode.
    Object.keys(instances).forEach(function (id) {
      var c = instances[id];
      if (c) { try { c.update('none'); } catch (e) {} }
    });
  }

  // The toggle sets/removes html[data-theme]; an OS change (when the user hasn't
  // chosen) flips prefers-color-scheme. Re-theme charts on either.
  if (root.MutationObserver) {
    new MutationObserver(refreshChartsTheme).observe(document.documentElement, {
      attributes: true, attributeFilter: ['data-theme']
    });
  }
  if (root.matchMedia) {
    var prefersDark = root.matchMedia('(prefers-color-scheme: dark)');
    if (prefersDark.addEventListener) prefersDark.addEventListener('change', refreshChartsTheme);
    else if (prefersDark.addListener) prefersDark.addListener(refreshChartsTheme);
  }

  // Inline plugin: draw a vertical crosshair at the hovered data column. With
  // interaction mode 'index' all active elements share one x, so the line marks
  // exactly where the cursor's index crosses every series' point.
  var crosshairPlugin = {
    id: 'crosshair',
    afterDraw: function (chart) {
      var active = chart.tooltip && chart.tooltip.getActiveElements
        ? chart.tooltip.getActiveElements()
        : (chart.tooltip && chart.tooltip._active) || [];
      if (!active.length) return;

      var x = active[0].element.x;
      var area = chart.chartArea;
      var ctx = chart.ctx;
      ctx.save();
      ctx.beginPath();
      ctx.moveTo(x, area.top);
      ctx.lineTo(x, area.bottom);
      ctx.lineWidth = 1;
      ctx.strokeStyle = cssVar('--aa-text-muted', 'rgba(0, 0, 0, 0.35)');
      ctx.stroke();
      ctx.restore();
    }
  };

  // Tooltip footer: sum of all series' values at the hovered index, shown as an
  // extra "Total:" row (no dedicated dataset). Used only on multi-series charts.
  function totalFooter(items) {
    var total = items.reduce(function (sum, item) {
      var y = item.parsed && typeof item.parsed.y === 'number' ? item.parsed.y : 0;
      return sum + y;
    }, 0);
    return 'Total: ' + total;
  }

  // Legend click isolates the clicked series: show ONLY it and hide the rest.
  // Clicking the already-isolated series again restores all series. (Default
  // Chart.js behaviour just toggles the clicked series off.)
  function isolateLegendOnClick(_e, legendItem, legend) {
    var chart = legend.chart;
    var index = legendItem.datasetIndex;
    var datasets = chart.data.datasets;
    var alreadyIsolated = chart.isDatasetVisible(index) && datasets.every(function (_ds, i) {
      return i === index ? chart.isDatasetVisible(i) : !chart.isDatasetVisible(i);
    });
    datasets.forEach(function (_ds, i) {
      chart.setDatasetVisibility(i, alreadyIsolated ? true : i === index);
    });
    chart.update();
  }

  function baseOptions(opts) {
    ensureCursorPositioner();
    applyChartTheme();
    var mode = opts.interactionMode || 'index';
    return {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: mode, intersect: false, axis: 'x' },
      plugins: {
        legend: { position: 'top', align: 'end', labels: { boxWidth: 12, boxHeight: 12, color: tickColor } },
        tooltip: {
          enabled: true,
          mode: mode,
          intersect: false,
          animation: false,
          position: 'cursor'
        }
      }
    };
  }

  // Take [{key, values: [{x, y}, ...]}, ...] and return the same shape with
  // every series covering the union of all x's. Missing points are filled
  // with 0. Required so mode:'index' aligns datasets correctly even when
  // some series start later or have gaps in their data.
  function alignToCommonXAxis(json) {
    var allXs = new Set();
    json.forEach(function (series) {
      (series.values || []).forEach(function (p) { allXs.add(p.x); });
    });
    var sortedXs = Array.from(allXs).sort(function (a, b) { return a - b; });

    return json.map(function (series) {
      var byX = {};
      (series.values || []).forEach(function (p) { byX[p.x] = p.y; });
      return {
        key: series.key,
        values: sortedXs.map(function (x) {
          return { x: x, y: x in byX ? byX[x] : 0 };
        })
      };
    });
  }

  // Active-call stats are stored only when non-zero (a missing sample means
  // zero active calls). Detect the sampling cadence as the smallest positive
  // gap between consecutive points across all series; default to 1 minute.
  function detectStepMs(json) {
    var min = Infinity;
    json.forEach(function (series) {
      var vs = series.values || [];
      for (var i = 1; i < vs.length; i++) {
        var d = vs[i].x - vs[i - 1].x;
        if (d > 0 && d < min) min = d;
      }
    });
    return isFinite(min) ? min : 60000;
  }

  // Insert a pair of zero points just inside any gap wider than ~1.5 sampling
  // intervals, so the line drops to 0 between bursts instead of bridging the
  // gap with a sloped segment. Input must be sorted ascending by x.
  function withZeroBaseline(values, stepMs) {
    if (!values || values.length === 0) return values;
    var out = [];
    for (var i = 0; i < values.length; i++) {
      if (i > 0 && values[i].x - values[i - 1].x > stepMs * 1.5) {
        out.push({ x: values[i - 1].x + stepMs, y: 0 });
        out.push({ x: values[i].x - stepMs, y: 0 });
      }
      out.push(values[i]);
    }
    return out;
  }

  function reconstructZeros(json) {
    var stepMs = detectStepMs(json);
    return json.map(function (series) {
      return { key: series.key, values: withZeroBaseline(series.values || [], stepMs) };
    });
  }

  // Performance + reduction options for the dense time-series line charts:
  // - parsing:false   data is already in Chart.js-native {x,y} form (also
  //                   required for the decimation plugin to run).
  // - normalized:true data is sorted ascending with unique x's per dataset.
  // - animation:false no slide animation over thousands of points.
  // Decimation (min-max) keeps both the floor and the spikes per pixel column,
  // matching what the server min/max rollup used to provide. It is NOT enabled
  // for stacked/filled charts, where Chart.js decimation is unreliable.
  function applyTimeSeriesPerf(options, opts, decimate) {
    options.parsing = false;
    options.normalized = true;
    options.animation = false;
    if (decimate) {
      options.plugins.decimation = {
        enabled: true,
        algorithm: opts.decimationAlgorithm || 'min-max'
      };
    }
    return options;
  }

  function renderLine(canvasId, json, opts) {
    opts = opts || {};
    var canvas = getCanvas(canvasId, opts.placeholderId);
    if (!canvas) return null;
    destroyExisting(canvasId);

    json = alignToCommonXAxis(reconstructZeros(json));
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

    var options = Object.assign(baseOptions(opts), {
      scales: {
        x: timeXScale(opts),
        y: linearYScale(opts)
      }
    });
    applyTimeSeriesPerf(options, opts, true);
    if (datasets.length > 1) {
      options.plugins.tooltip.callbacks = { footer: totalFooter };
      options.plugins.legend.onClick = isolateLegendOnClick;
    }

    var config = {
      type: 'line',
      data: { datasets: datasets },
      options: options,
      plugins: [crosshairPlugin]
    };
    return register(canvasId, new Chart(canvas, config));
  }

  function renderStackedArea(canvasId, json, opts) {
    opts = opts || {};
    var canvas = getCanvas(canvasId, opts.placeholderId);
    if (!canvas) return null;
    destroyExisting(canvasId);

    json = alignToCommonXAxis(reconstructZeros(json));
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

    var options = Object.assign(baseOptions(opts), {
      scales: {
        x: timeXScale(opts),
        y: linearYScale(opts, { stacked: true })
      }
    });
    applyTimeSeriesPerf(options, opts, false);
    if (datasets.length > 1) {
      options.plugins.tooltip.callbacks = { footer: totalFooter };
      options.plugins.legend.onClick = isolateLegendOnClick;
    }

    var config = {
      type: 'line',
      data: { datasets: datasets },
      options: options,
      plugins: [crosshairPlugin]
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

    json = alignToCommonXAxis(json);
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

  // Default time-range choices for the active-call charts. Capped at 30d on the
  // client; the server caps the `hours` param at the 1-month retention window.
  var DEFAULT_RANGES = [
    { label: '24h', hours: 24 },
    { label: '7d', hours: 168 },
    { label: '30d', hours: 720 }
  ];

  // Render a time-series chart with a range picker. Builds a <select> before the
  // chart placeholder once, then (re)loads `url?hours=N` and renders on the
  // selected range — and on every call, so re-activating the tab refreshes data.
  // opts: { url, canvasId, placeholderId, type: 'line'|'stackedArea',
  //         chartOpts, ranges, defaultHours }
  function renderRanged(opts) {
    var placeholder = document.getElementById(opts.placeholderId);
    if (!placeholder) return;

    var ranges = opts.ranges || DEFAULT_RANGES;
    var defaultHours = opts.defaultHours || 24;
    var renderFn = opts.type === 'stackedArea' ? renderStackedArea : renderLine;

    var chartOpts = Object.assign({ placeholderId: opts.placeholderId }, opts.chartOpts || {});

    function load(hours) {
      var sep = opts.url.indexOf('?') === -1 ? '?' : '&';
      $.getJSON(opts.url + sep + 'hours=' + hours, function (json) {
        renderFn(opts.canvasId, json, chartOpts);
      });
    }

    var pickerId = opts.canvasId + '-range';
    var picker = document.getElementById(pickerId);
    if (!picker) {
      picker = document.createElement('select');
      picker.id = pickerId;
      picker.className = 'chart-range-select';
      ranges.forEach(function (r) {
        var option = document.createElement('option');
        option.value = r.hours;
        option.text = r.label;
        if (r.hours === defaultHours) option.selected = true;
        picker.appendChild(option);
      });
      picker.addEventListener('change', function () {
        load(parseInt(picker.value, 10) || defaultHours);
      });
      // Overlay the picker in the chart's top-left corner so it shares the row
      // with the (right-aligned) legend instead of taking an extra row above.
      placeholder.insertBefore(picker, placeholder.firstChild);
    }

    load(parseInt(picker.value, 10) || defaultHours);
  }

  root.Charts = {
    renderLine: renderLine,
    renderStackedArea: renderStackedArea,
    renderBar: renderBar,
    renderGroupedBar: renderGroupedBar,
    renderRanged: renderRanged
  };
})(window);
