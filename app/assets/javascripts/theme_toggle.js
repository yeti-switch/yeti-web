// Dark-mode toggle. Sets html[data-theme] (overrides the OS preference) and
// persists the choice in localStorage. Default (no stored choice) = follow OS.
(function () {
  var KEY = 'aa-theme';
  var root = document.documentElement;

  function stored() { try { return localStorage.getItem(KEY); } catch (e) { return null; } }
  function systemDark() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }
  function effective() {
    var s = stored();
    return (s === 'dark' || s === 'light') ? s : (systemDark() ? 'dark' : 'light');
  }
  function apply() {
    var s = stored();
    if (s === 'dark' || s === 'light') root.setAttribute('data-theme', s);
    else root.removeAttribute('data-theme'); // fall back to @media (prefers-color-scheme)
  }

  apply(); // run as early as possible to minimize flash

  $(document).ready(function () {
    if (!$('#utility_nav').length || $('#theme_toggle').length) return;

    var $li = $(
      '<li id="theme_toggle" class="header-item">' +
        '<a href="#" title="Toggle dark mode" role="button" aria-label="Toggle dark mode"></a>' +
      '</li>'
    );
    $('#utility_nav').prepend($li);

    function refresh() { $li.attr('data-mode', effective()); }
    refresh();

    $li.on('click', 'a', function (ev) {
      ev.preventDefault();
      var next = (effective() === 'dark') ? 'light' : 'dark';
      try { localStorage.setItem(KEY, next); } catch (e) {}
      apply();
      refresh();
    });

    // Track OS changes while the user hasn't made an explicit choice
    if (window.matchMedia) {
      var mq = window.matchMedia('(prefers-color-scheme: dark)');
      var onChange = function () { if (!stored()) { apply(); refresh(); } };
      if (mq.addEventListener) mq.addEventListener('change', onChange);
      else if (mq.addListener) mq.addListener(onChange);
    }
  });
})();
