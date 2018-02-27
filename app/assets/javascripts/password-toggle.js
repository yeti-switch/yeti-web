$(document).ready(function () {

  $('.password-mask').on('click', '.password-toggle span, .password-toggle-inline span', function() {
    var btnWrapper = $(this).parent(),
        input;

    if (btnWrapper.hasClass('password-toggle-inline')) {
      input = btnWrapper.closest('td').find('span.value');
    } else {
      input = btnWrapper.closest('li').find('input');
    }

    if (input.hasClass('dotsfont')) {
      input.removeClass('dotsfont');
    } else {
      input.addClass('dotsfont');
    }
  });

  // Form Input
  $('li.password-mask').each(function(_, el) {
    var wrapper = $(el);
    wrapper.append('<div class="password-toggle"><span></span></div>');
    wrapper.find('.password-toggle span').click();
  });

  // Show page table row
  $('tr.row.password-mask').each(function(_, el) {
    var wrapper = $(el).find('td');

    wrapper.html('<span class="value">' + wrapper.text() +'</span>');
    wrapper.append('<div class="password-toggle-inline"><span></span></div>');
    wrapper.find('.password-toggle-inline span').click();
  });

});
