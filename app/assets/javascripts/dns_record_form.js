$(document).ready(function () {
    var $type = $('select.dns-record-type');
    var $content = $('input.dns-record-content');
    if ($type.length === 0 || $content.length === 0) {
        return;
    }

    var hints = $content.data('content-hints') || {};
    // on validation error formtastic wraps the input in div.field_with_errors,
    // so hint and error are looked up in the whole input wrapper, not in input siblings.
    var $wrapper = $content.closest('li');
    var $hint = $wrapper.find('p.inline-hints');
    if ($hint.length === 0) {
        $hint = $('<p class="inline-hints"></p>').appendTo($wrapper);
    }

    $type.on('change', function () {
        $hint.text(hints[$(this).val()] || '');
        // error was rendered for the previously selected record type
        $wrapper.find('p.inline-errors').remove();
        $wrapper.removeClass('error');
    });
});
