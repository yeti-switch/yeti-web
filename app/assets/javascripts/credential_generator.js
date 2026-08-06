// Fills an input with a random credential. The "click to fill random ..." hint
// links opt in with a `data-generate-credential` attribute (optionally carrying a
// length) and are bound by the delegated handler below rather than an inline
// onclick=, so the admin runs under a Content-Security-Policy without
// `script-src 'unsafe-inline'` — see also chart_init.js.
function generateCredential(target, length) {
  if (!$(target).is('input')) { target = $(target).closest('li[id$=input]').find('input')[0]; }
  if (typeof(target) === 'undefined' || target.length === 0) return;

  var length = length || 20;
  var credential = '';
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;

  for (var i = 0; i < length; i++) {
    credential += characters.charAt(Math.floor(Math.random() * charactersLength));
  }

  $(target).val(credential);
}

// Delegated: the hint links live inside formtastic inputs that are re-rendered
// (and, on the gateway form, revealed) after page load.
$(document).on('click', '[data-generate-credential]', function (e) {
  e.preventDefault();
  var length = parseInt($(this).data('generateCredential'), 10);
  generateCredential(this, isNaN(length) ? undefined : length);
});
