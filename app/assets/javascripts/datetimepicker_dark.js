// Activate the xdsoft datetimepicker's built-in dark theme (the `.xdsoft_dark`
// rules ship with active_admin_datetimepicker) when the app is in dark mode.
// The picker is a singleton appended to <body> and reused, so we toggle the class
// on open and whenever the app theme changes.
$(function () {
  function isDark() {
    var t = document.documentElement.getAttribute('data-theme');
    if (t === 'dark') return true;
    if (t === 'light') return false;
    return !!(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
  }

  function sync() {
    $('.xdsoft_datetimepicker').toggleClass('xdsoft_dark', isDark());
  }

  sync(); // in case the picker is already in the DOM
  // xdsoft fires open.xdsoft on the input when the picker is shown (bubbles to document).
  $(document).on('open.xdsoft', sync);

  // Follow runtime theme switches (theme_toggle.js sets html[data-theme]).
  if (window.MutationObserver) {
    new MutationObserver(sync).observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-theme']
    });
  }
  // Follow OS theme changes while in auto mode.
  if (window.matchMedia) {
    var mq = window.matchMedia('(prefers-color-scheme: dark)');
    if (mq.addEventListener) mq.addEventListener('change', sync);
    else if (mq.addListener) mq.addListener(sync);
  }
});
