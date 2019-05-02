// jquery plugin that renders table body from schema and payload in json format
(function () {

  // instance initializer
  var JsIndexTable = (function () {
    function JsIndexTable ($table, options) {
      this.schema = $table.data('schema');
      this.payload = $table.data('payload');
      this.config = $table.data('config');
      this.init($table, options || {});
      this.renderTableBody(JsIndexTable.createElement);
      this.initSelectionBoxes();
    }

    // private class methods
    var _formatters = {}

    // public class methods
    JsIndexTable.createElement = function (tag, attributes, children) {
      if (children === undefined || children === null) children = []
      return $('<' + tag + '>', attributes || {}).append(children);
    };

    JsIndexTable.drawStatusTag = function (label, classes) {
      return this.createElement('span', { class: ['status_tag', classes].join(' ') }, label)
    };

    JsIndexTable.addFormatter = function (type, formatter) {
      _formatters[type] = formatter
    };

    JsIndexTable.defaultFormatter = function (value) {
      if (value === null) return '';
      return value.toString();
    };

    JsIndexTable.formatterFor = function (type) {
      return _formatters[type]
    };

    JsIndexTable.formatValue = function (value, schema, config) {
      if (!schema) schema = {};
      var formatter = JsIndexTable.formatterFor(schema.type)
      if (schema.type && formatter) {
        return formatter(value, schema, config);
      }
      return JsIndexTable.defaultFormatter(value, schema, config);
    };

    // instance methods
    JsIndexTable.prototype = (function () {
      // private instance methods
      var _table = null;
      var _settings = null;
      var _eventPrefix = 'jsIndexTable'
      var _triggerEvent = function (name, payload) {
        _table.trigger(_eventPrefix + ':' + name, payload)
      }
      // public instance methods
      return {
        init: function (table, options) {
          _table = table;
          _settings = options;
        },
        initSelectionBoxes: function () {
          if (!$(".batch_actions_selector").length && !$(":checkbox.toggle_all").length) return;
          _table.data('tableCheckboxToggler', null);
          _table.tableCheckboxToggler();
        },
        renderTableBody: function (createElement) {
          var that = this
          var tableRows = this.payload.map(function (row, rowIndex) {
            var rowClasses = [rowIndex % 2 ? 'even' : 'odd', that.config.rowClass].join(' ');
            var rowId = that.config.rowIdPrefix + '_' + row.id;
            var cells = row.columns.map(function (value, cellIndex) {
              var cellSchema = that.schema[cellIndex];
              var cellValue = JsIndexTable.formatValue(value, cellSchema, that.config);
              return createElement('td', { class: cellSchema.cellClass }, cellValue);
            });
            return createElement('tr', { class: rowClasses, id: rowId }, cells);
          });
          _table.find('tbody').append(tableRows);
          _triggerEvent('loaded');
          _table.addClass('index-js-table-loaded');
        }
      };
    })();
    return JsIndexTable;
  })();

  // built-in formatters
  JsIndexTable.addFormatter('string', function (value) {
    if (value === null) return '';
    return value.toString();
  });

  JsIndexTable.addFormatter('html', function (value) {
    return value;
  });

  JsIndexTable.addFormatter('badge', function (value) {
    if (value === null) return JsIndexTable.drawStatusTag('Empty', '');
    return JsIndexTable.drawStatusTag(value.label, value.class);
  });

  JsIndexTable.addFormatter('boolean', function (value, schema, config) {
    var badgeFormatter = JsIndexTable.formatterFor('badge');
    if (value === null) return badgeFormatter(null, schema, config);
    return value
      ? badgeFormatter({ label: 'Yes', class: 'yes' })
      : badgeFormatter({ label: 'No', class: 'no' });
  });

  JsIndexTable.addFormatter('id_link', function (value, schema, config) {
    if (!config.idUrl) return value;
    var url = config.idUrl + '/' + value;
    return JsIndexTable.createElement('a', { href: url, class: 'resource_id_link' }, value);
  });

  JsIndexTable.addFormatter('selectable', function (value) {
    return JsIndexTable.createElement('input', {
      type: 'checkbox',
      id: 'batch_action_item_' + value,
      value: value,
      class: 'collection_selection',
      name: 'collection_selection[]'
    });
  });

  JsIndexTable.addFormatter('actions', function (value, schema, config) {
    var nodes = [];
    var h = JsIndexTable.createElement;
    var extraClass = schema.class || '';
    if (config.showUrl && value.show) {
      nodes.push(h('a', { href: config.showUrl, class: 'view_link member_link ' + extraClass }, config.showTitle))
    }
    if (config.editUrl && value.edit) {
      nodes.push(h('a', { href: config.editUrl, class: 'edit_link member_link ' + extraClass }, config.editTitle))
    }
    if (config.destroyUrl && value.destroy) {
      nodes.push(h('a', { href: config.destroyUrl, class: 'delete_link member_link ' + extraClass }, config.destroyTitle))
    }
    return nodes
  });

  // jquery fn
  $.fn.jsIndexTable = function (options) {
    if (this.length === 0) return;
    var instances = [];
    this.each(function () {
      var table = $(this);
      if (table.data('jsIndexTable')) return table.data('jsIndexTable');
      var instance = new JsIndexTable(table, options);
      table.data('jsIndexTable', instance);
      instances.push(instance);
    });
    return instances;
  };

  // mount
  $(document).ready(function () {
    $('.js-index-table').jsIndexTable();
  });

})()
