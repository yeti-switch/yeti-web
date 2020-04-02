$(document).ready(function () {
  $('body').on('modal-link:after_open', function (event, title, form, _link) {
    if (title !== 'Apply unique columns') return;

    // fix labels
    form.find('label').text('Unique Columns');

    // fix inputs
    form.find('select')
      .attr('name', 'changes[unique_columns][]')
      .attr('multiple', 'multiple')
      .chosen({ width: '100%' });
  });
});
