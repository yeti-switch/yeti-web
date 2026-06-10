// Row highlight, kept in sync with the batch-selection checkbox.
//
// For a row that has a checkbox, the highlight follows the checkbox state (the
// `tr:has(... input:checked)` rule in table_highlights.css), and a click anywhere
// in the row toggles that checkbox — so the line and the checkbox always match,
// whether you click the row or the checkbox itself. We drive the checkbox ourselves
// in the capture phase and stopPropagation, so ActiveAdmin's own cell-click toggler
// (regular batch actions) doesn't double-toggle it; on scoped-collection tables
// (e.g. /accounts) AA has no such toggler, so this is what makes the row click work
// at all.
//
// A row without a checkbox has nothing to sync to, so we toggle a standalone class.
//
// This only flips a checkbox / CSS class — it never sends a request, so a row click
// cannot change data. Links and form controls keep their own behavior.
document.addEventListener('click', function (e) {
    var target = e.target;
    if (!target || !target.closest) return;
    var td = target.closest('table.index_table tbody td');
    if (!td) return;
    // Leave interactive controls (links, form fields, including the checkbox itself)
    // to their own behavior.
    if (target.closest('a, input, button, select, textarea, label')) return;

    var row = td.parentNode;
    var checkbox = row.querySelector('td.col-selectable input[type="checkbox"]');
    if (checkbox) {
        e.stopPropagation(); // we drive the checkbox; don't let AA's cell-click also toggle it
        checkbox.checked = !checkbox.checked;
        checkbox.dispatchEvent(new Event('change', { bubbles: true }));
    } else {
        row.classList.toggle('selected');
    }
}, true);
