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
