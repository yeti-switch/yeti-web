$(document).ready(function () {
  $('body').on('modal-link:after_open', function (event, title, form, _link) {
    if (title !== 'Apply unique columns') return;

    // fix labels
    form.find('label').text('Unique Columns');

    // fix inputs
    form.find('select')
      .attr('name', 'changes[unique_columns][]')
      .attr('id', 'changes_unique_columns')
      .attr('multiple', 'multiple')
      .chosen({ width: '100%' });

      // add select all button
      let select_all_column = $('<a></a>').text('Select All').attr('id', 'select-all-unique-columns').attr('href', '#');
      form.append(select_all_column);
      select_all_column.click(function () {
          form.find('select option').prop('selected', true).trigger('chosen:updated');
      });
  });
});
