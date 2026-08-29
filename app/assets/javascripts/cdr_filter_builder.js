// Chips + autocomplete filter builder for CDR report forms.
//
// Looks like a text input you type into; each completed condition becomes a
// removable chip ("Customer = Acme Corp", "Duration > 60"). Entry is staged with
// autocomplete: column -> predicate -> value. For association columns the value
// stage searches the matching endpoint and the chip shows the friendly name
// while the serialised value is the id.
//
// Conditions are AND-ed and written as a Ransack query string into the report's
// (advanced) `filter` field, e.g. "customer_id_eq=5&duration_gt=60". Reads its
// config from a `.cdr-filter-builder` container: data-target (id of the filter
// input) + a child <script type="application/json"> with the column metadata.
(function () {
  'use strict';

  var PREDICATE_LABELS = {
    eq: '=', not_eq: '≠', gt: '>', gteq: '≥', lt: '<', lteq: '≤',
    in: 'in', cont: 'contains', start: 'starts with', end: 'ends with',
    gteq_datetime: 'from', lteq_datetime: 'to'
  };

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    attrs = attrs || {};
    Object.keys(attrs).forEach(function (k) {
      if (k === 'class') node.className = attrs[k];
      else if (k === 'text') node.textContent = attrs[k];
      else node.setAttribute(k, attrs[k]);
    });
    (children || []).forEach(function (c) { node.appendChild(c); });
    return node;
  }

  function flattenQuery(params) {
    var parts = [];
    (function walk(prefix, obj) {
      Object.keys(obj).forEach(function (k) {
        var key = prefix ? prefix + '[' + k + ']' : k;
        var v = obj[k];
        if (v && typeof v === 'object') walk(key, v);
        else parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(v));
      });
    })('', params || {});
    return parts.join('&');
  }

  function CdrFilterChips(container) {
    this.container = container;
    this.target = document.getElementById(container.getAttribute('data-target'));
    var script = container.querySelector('script[type="application/json"]');
    this.metadata = JSON.parse(script.textContent);
    this.byName = {};
    this.metadata.forEach(function (m) { this.byName[m.name] = m; }, this);

    this.chips = [];          // [{column, predicate, value, label}]
    this.draft = {};          // {meta, predicate}
    this.stage = 'column';    // 'column' | 'predicate' | 'value'
    this.suggestions = [];
    this.active = -1;
    this.searchSeq = 0;

    this.build();
    this.loadFromTarget();
    this.render();
    this.serialize(); // reflect any loaded chips in the hint
  }

  var P = CdrFilterChips.prototype;

  P.build = function () {
    this.box = el('div', { class: 'cdr-chips' });
    this.entry = el('input', { type: 'text', class: 'cdr-chip-entry', autocomplete: 'off', placeholder: 'Add filter…' });
    this.menu = el('div', { class: 'cdr-suggest', style: 'display:none' });
    this.box.appendChild(this.entry);
    // Put the chips box above the preview hint, so the hint sits *under* the
    // input like a standard ActiveAdmin hint.
    this.preview = this.container.querySelector('.cdr-filter-preview');
    this.container.insertBefore(this.box, this.preview);
    this.container.appendChild(this.menu);

    var self = this;
    this.entry.addEventListener('input', function () { self.onInput(); });
    this.entry.addEventListener('keydown', function (e) { self.onKeydown(e); });
    this.entry.addEventListener('focus', function () { self.onInput(); });
    this.box.addEventListener('click', function () { self.entry.focus(); });
    document.addEventListener('click', function (e) {
      if (!self.container.contains(e.target)) self.closeMenu();
    });
  };

  // ---- suggestions per stage -------------------------------------------------

  P.onInput = function () {
    var q = this.entry.value.trim().toLowerCase();
    if (this.stage === 'column') this.showColumnSuggestions(q);
    else if (this.stage === 'predicate') this.showPredicateSuggestions(q);
    // value stage gets the raw (untrimmed) input so association search can use
    // the "3 spaces = load all" convention used elsewhere in the app.
    else this.showValueSuggestions(this.entry.value);
  };

  P.showColumnSuggestions = function (q) {
    var list = this.metadata.filter(function (m) {
      return !q || m.label.toLowerCase().indexOf(q) >= 0 || m.name.indexOf(q) >= 0;
    }).slice(0, 50).map(function (m) {
      return { label: m.label, hint: m.name, pick: { type: 'column', meta: m } };
    });
    this.setSuggestions(list);
  };

  P.showPredicateSuggestions = function (q) {
    var meta = this.draft.meta;
    var list = meta.predicates.filter(function (p) {
      var label = PREDICATE_LABELS[p] || p;
      return !q || p.indexOf(q) >= 0 || label.toLowerCase().indexOf(q) >= 0;
    }).map(function (p) {
      return { label: PREDICATE_LABELS[p] || p, hint: p, pick: { type: 'predicate', predicate: p } };
    });
    this.setSuggestions(list);
  };

  P.showValueSuggestions = function (raw) {
    var meta = this.draft.meta;
    if (meta.value_type === 'boolean') {
      var q = raw.trim().toLowerCase();
      this.setSuggestions(['true', 'false'].filter(function (v) { return !q || v.indexOf(q) >= 0; }).map(function (v) {
        return { label: v, pick: { type: 'value', value: v, label: v } };
      }));
    } else if (meta.value_type === 'association') {
      this.searchAssociation(raw); // keep whitespace: 3 spaces loads the full list
    } else {
      // free value (number / string / date) — Enter adds it
      var t = raw.trim();
      this.setSuggestions(t ? [{ label: 'Add “' + t + '”', pick: { type: 'value', value: t, label: t } }]
                            : [{ label: 'Type a value, then press Enter', disabled: true }]);
    }
  };

  P.searchAssociation = function (q) {
    // Mirror initTomSelectAjax: search from 3 chars; 3 spaces loads everything.
    if (q.length < 3) {
      this.setSuggestions([{ label: 'Type 3+ characters (or 3 spaces for all)…', disabled: true }]);
      return;
    }
    var meta = this.draft.meta;
    var base = meta.search.path;
    var params = flattenQuery(meta.search.params);
    if (params) base += (base.indexOf('?') >= 0 ? '&' : '?') + params;
    var url = base + (base.indexOf('?') >= 0 ? '&' : '?') + 'q[search_for]=' + encodeURIComponent(q);

    var seq = ++this.searchSeq;
    var self = this;
    fetch(url).then(function (r) { return r.json(); }).then(function (items) {
      if (seq !== self.searchSeq) return; // a newer query superseded this one
      self.setSuggestions(items.slice(0, 50).map(function (i) {
        return { label: i.value, hint: '#' + i.id, pick: { type: 'value', value: String(i.id), label: i.value } };
      }));
    }).catch(function () { /* ignore */ });
  };

  // ---- selection / staging ---------------------------------------------------

  P.choose = function (pick) {
    if (pick.type === 'column') {
      this.draft = { meta: pick.meta };
      this.stage = 'predicate';
      this.entry.value = '';
      this.render();
      this.onInput();
    } else if (pick.type === 'predicate') {
      this.draft.predicate = pick.predicate;
      this.stage = 'value';
      this.entry.value = '';
      this.render();
      this.onInput();
    } else if (pick.type === 'value') {
      this.addChip(pick.value, pick.label);
    }
  };

  P.addChip = function (value, label) {
    var meta = this.draft.meta;
    this.chips.push({
      column: meta.name,
      predicate: this.draft.predicate,
      value: value,
      label: meta.label + ' ' + (PREDICATE_LABELS[this.draft.predicate] || this.draft.predicate) + ' ' + label
    });
    this.resetDraft();
    this.serialize();
    this.render();
    this.onInput();
  };

  P.resetDraft = function () {
    this.draft = {};
    this.stage = 'column';
    this.entry.value = '';
  };

  P.removeChip = function (index) {
    this.chips.splice(index, 1);
    this.serialize();
    this.render();
  };

  // ---- keyboard --------------------------------------------------------------

  P.onKeydown = function (e) {
    var visible = this.menu.style.display !== 'none';
    if (e.key === 'ArrowDown' && visible) { e.preventDefault(); this.move(1); }
    else if (e.key === 'ArrowUp' && visible) { e.preventDefault(); this.move(-1); }
    else if (e.key === 'Escape') { this.closeMenu(); }
    else if (e.key === 'Enter') {
      e.preventDefault();
      var sel = this.suggestions[this.active];
      if (sel && sel.pick) this.choose(sel.pick);
      else if (this.stage === 'value' && this.draft.meta.value_type !== 'association' && this.entry.value.trim()) {
        this.addChip(this.entry.value.trim(), this.entry.value.trim());
      }
    } else if (e.key === 'Backspace' && this.entry.value === '') {
      if (this.stage === 'value') { this.stage = 'predicate'; this.draft.predicate = null; this.render(); this.onInput(); }
      else if (this.stage === 'predicate') { this.stage = 'column'; this.draft = {}; this.render(); this.onInput(); }
      else if (this.chips.length) { this.removeChip(this.chips.length - 1); }
    }
  };

  P.move = function (delta) {
    var pickable = [];
    this.suggestions.forEach(function (s, i) { if (!s.disabled) pickable.push(i); });
    if (!pickable.length) return;
    var pos = pickable.indexOf(this.active);
    pos = (pos + delta + pickable.length) % pickable.length;
    this.active = pickable[pos];
    this.renderMenu();
  };

  // ---- rendering -------------------------------------------------------------

  P.setSuggestions = function (list) {
    this.suggestions = list;
    this.active = list.findIndex(function (s) { return !s.disabled; });
    this.renderMenu();
  };

  P.renderMenu = function () {
    var self = this;
    this.menu.innerHTML = '';
    if (!this.suggestions.length) { this.menu.style.display = 'none'; return; }
    this.suggestions.forEach(function (s, i) {
      var item = el('div', { class: 'cdr-suggest-item' + (i === self.active ? ' active' : '') + (s.disabled ? ' disabled' : '') });
      item.appendChild(el('span', { class: 'cdr-suggest-label', text: s.label }));
      if (s.hint) item.appendChild(el('span', { class: 'cdr-suggest-hint', text: s.hint }));
      if (!s.disabled) {
        item.addEventListener('mousedown', function (e) { e.preventDefault(); self.choose(s.pick); });
      }
      self.menu.appendChild(item);
    });
    // Anchor the dropdown to the chips box (the builder container can be wider
    // than the form's input column).
    this.menu.style.left = this.box.offsetLeft + 'px';
    this.menu.style.top = (this.box.offsetTop + this.box.offsetHeight) + 'px';
    this.menu.style.width = this.box.offsetWidth + 'px';
    this.menu.style.display = 'block';
  };

  P.closeMenu = function () { this.menu.style.display = 'none'; };

  P.render = function () {
    var self = this;
    // wipe everything before the entry input
    while (this.box.firstChild && this.box.firstChild !== this.entry) this.box.removeChild(this.box.firstChild);

    this.chips.forEach(function (chip, i) {
      var pill = el('span', { class: 'cdr-chip' }, [el('span', { class: 'cdr-chip-text', text: chip.label })]);
      var x = el('button', { type: 'button', class: 'cdr-chip-remove', text: '×' });
      x.addEventListener('click', function () { self.removeChip(i); self.entry.focus(); });
      pill.appendChild(x);
      self.box.insertBefore(pill, self.entry);
    });

    // in-progress draft shown as a faint pending prefix
    if (this.draft.meta) {
      var txt = this.draft.meta.label;
      if (this.draft.predicate) txt += ' ' + (PREDICATE_LABELS[this.draft.predicate] || this.draft.predicate);
      this.box.insertBefore(el('span', { class: 'cdr-chip cdr-chip-pending', text: txt }), this.entry);
    }

    this.entry.placeholder = this.stage === 'column' ? (this.chips.length ? 'Add filter…' : 'Add filter (e.g. Customer)…')
      : this.stage === 'predicate' ? 'predicate…' : 'value…';
  };

  // ---- (de)serialisation to the Ransack string -------------------------------

  P.serialize = function () {
    var parts = this.chips.map(function (chip) {
      var key = chip.column + '_' + chip.predicate;
      if (chip.predicate === 'in') return encodeURIComponent(key + '[]') + '=' + encodeURIComponent(chip.value);
      return encodeURIComponent(key) + '=' + encodeURIComponent(chip.value);
    });
    var str = parts.join('&');
    if (this.target) this.target.value = str;
    if (this.preview) this.preview.textContent = str ? 'Ransack filter: ' + str : '';
  };

  P.loadFromTarget = function () {
    if (!this.target || !this.target.value) return;
    var self = this;
    this.target.value.split('&').forEach(function (pair) {
      if (!pair) return;
      var idx = pair.indexOf('=');
      var rawKey = decodeURIComponent(pair.slice(0, idx).replace(/\+/g, ' ')).replace(/\[\]$/, '');
      var rawVal = decodeURIComponent(pair.slice(idx + 1).replace(/\+/g, ' '));
      var match = self.splitKey(rawKey);
      if (!match) return; // unrepresentable -> left to the Advanced field
      var meta = self.byName[match.column];
      // label for an FK id isn't known without a lookup; show the id.
      self.chips.push({
        column: match.column,
        predicate: match.predicate,
        value: rawVal,
        label: meta.label + ' ' + (PREDICATE_LABELS[match.predicate] || match.predicate) + ' ' + rawVal
      });
    });
  };

  P.splitKey = function (key) {
    var found = null;
    this.metadata.forEach(function (m) {
      m.predicates.forEach(function (p) {
        if (key === m.name + '_' + p) found = { column: m.name, predicate: p };
      });
    });
    return found;
  };

  document.addEventListener('DOMContentLoaded', function () {
    Array.prototype.forEach.call(document.querySelectorAll('.cdr-filter-builder'), function (c) {
      if (c.getAttribute('data-initialized')) return;
      c.setAttribute('data-initialized', '1');
      new CdrFilterChips(c);
    });
  });
})();
