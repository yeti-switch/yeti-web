$(document).ready(function () {
  $('body').on('modal-link:after_open', function (event, title, form, link) {
    if (title !== 'Apply unique columns') return;

    const hint = link.data('hint');
    if (hint) {
      form.prepend($('<p></p>').text(hint));
    }

    // fix inputs
    const uniqueColumnsSelect = form.find('select')
      .attr('name', 'changes[unique_columns][]')
      .attr('id', 'changes_unique_columns')
      .attr('multiple', 'multiple');

    form.find('input[name="additional_filter"]')
        .attr('name', 'changes[additional_filter]')
        .attr('id', 'changes_additional_filter');


    // fix labels
    form.find('#changes_unique_columns').siblings('label').text('Unique Columns');
    form.find('#changes_additional_filter').siblings('label').text('Additional SQL filter');

      // add select all button
      if (uniqueColumnsSelect.length > 0) {
        var ts = new TomSelect(uniqueColumnsSelect[0], {
          plugins: ['remove_button', 'clear_button']
        });
        // Make ts-wrapper take full width
        $(ts.wrapper).css('width', '100%');

        let select_all_column = $('<a></a>').text('Select All').attr('id', 'select-all-unique-columns').attr('href', '#');
        form.append(select_all_column);
        select_all_column.click(function () {
          var allValues = [];
          uniqueColumnsSelect.find('option').each(function() {
            if (this.value) allValues.push(this.value);
          });
          ts.setValue(allValues);
        });
      }
  });
});
