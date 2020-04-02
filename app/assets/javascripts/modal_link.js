$(document).ready(function () {
  /* Usage:
   *
   *  // triggers before modal is open
   *  $('body').on('modal-link:before_open', function (event, title, link) {
   *    title - link data-confirm or text
   *    link - jquery link node that opens modal
   *  });
   *
   *  // triggers after modal is open
   *  $('body').on('modal-link:after_open', function (event, title, form, link) {
   *    title - link data-confirm or text
   *    form - jquery form node
   *    link - jquery link node that opens modal
   *  });
   *
   *  // triggers on modal submit
   *  $('body').on('modal-link:submit', function (event, title, payload, form, link) {
   *    title - link data-confirm or text
   *    payload - serialized form inputs
   *    form - jquery form node
   *    link - jquery link node that opens modal
   *  });
   *
   */
  $('.modal-link').click(function (event) {
    event.stopPropagation(); // prevent Rails UJS click event
    event.preventDefault();

    var link = $(event.target);
    var title = link.data('confirm') || link.text();
    var inputs = link.data('inputs');

    $('body').trigger('modal-link:before_open', [title, link]);

    ActiveAdmin.modal_dialog(title, inputs, function (payload) {
      var form = $('form#dialog_confirm');
      $('body').trigger('modal-link:submit', [title, payload, form, link]);
    });

    setTimeout(function (){
      var form = $('form#dialog_confirm');

      // increase dialog size
      form.closest('.ui-dialog').css({left: '30%', width: '40%'});

      // set form action and method
      form.attr('action', link.attr('href'));
      form.attr('method', 'post');

      // append csrf token and method
      form.append(
        $('<input>', { type: 'hidden', name: $.rails.csrfParam(), value: $.rails.csrfToken() }, [])
      );
      form.append(
        $('<input>', { type: 'hidden', name: '_method', value: link.data('method') }, [])
      );

      $('body').trigger('modal-link:after_open', [title, form, link]);
    }, 0);
  });

  $('body').on('modal-link:submit', function (event, title, payload, form, link) {
    form[0].submit();
  })

});
