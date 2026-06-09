// Dark-mode toggle. Cycles auto → light → dark → auto.
//  - auto:  no stored choice; follows the OS (prefers-color-scheme) live.
//  - light/dark: force html[data-theme] and persist the choice in localStorage.
// Default (nothing stored) = auto.
(function () {
  var KEY = 'aa-theme';
  var root = document.documentElement;

  function stored() { try { return localStorage.getItem(KEY); } catch (e) { return null; } }
  function mode() { var s = stored(); return (s === 'light' || s === 'dark') ? s : 'auto'; }
  function apply() {
    var m = mode();
    // auto → drop the attribute so @media (prefers-color-scheme) decides.
    if (m === 'auto') root.removeAttribute('data-theme');
    else root.setAttribute('data-theme', m);
  }

  apply(); // run as early as possible to minimize flash

  $(document).ready(function () {
    if (!$('#utility_nav').length || $('#theme_toggle').length) return;

    var $li = $(
      '<li id="theme_toggle" class="header-item">' +
        '<a href="#" role="button"></a>' +
      '</li>'
    );
    $('#utility_nav').prepend($li);

    var LABEL = {
      auto:  'Theme: auto (follows OS) — click for light',
      light: 'Theme: light — click for dark',
      dark:  'Theme: dark — click for auto'
    };
    function refresh() {
      var m = mode();
      $li.attr('data-mode', m);
      $li.find('a').attr({ title: LABEL[m], 'aria-label': LABEL[m] });
    }
    refresh();

    var NEXT = { auto: 'light', light: 'dark', dark: 'auto' };
    $li.on('click', 'a', function (ev) {
      ev.preventDefault();
      var next = NEXT[mode()];
      try {
        if (next === 'auto') localStorage.removeItem(KEY);
        else localStorage.setItem(KEY, next);
      } catch (e) {}
      apply();
      refresh();
    });

    // In auto mode, follow live OS theme changes.
    if (window.matchMedia) {
      var mq = window.matchMedia('(prefers-color-scheme: dark)');
      var onChange = function () { if (mode() === 'auto') { apply(); refresh(); } };
      if (mq.addEventListener) mq.addEventListener('change', onChange);
      else if (mq.addListener) mq.addListener(onChange);
    }
  });
})();
