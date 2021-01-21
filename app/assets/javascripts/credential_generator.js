function generateCredential(target, length = 20) {
  if (typeof(target) === 'undefined' || target.length === 0) return;

  let credential = '';
  let characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let charactersLength = characters.length;

  for (let i = 0; i < length; i++) {
    credential += characters.charAt(Math.floor(Math.random() * charactersLength));
  }

  $(target).val(credential);
}
