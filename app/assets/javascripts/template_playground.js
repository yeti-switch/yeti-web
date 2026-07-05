// Invoice template playground: POST the edited (unsaved) template + the selected
// invoice id to the `preview` action and show the returned PDF in the iframe.
// The editor is pre-filled server-side with the template being edited. Loaded
// only by the page-scoped `playground` bundle, so it never runs elsewhere.
$(document).ready(function () {
    var container = document.querySelector('.template-playground');
    if (!container) return;

    var previewUrl = container.getAttribute('data-preview-url');
    var csrfEl = document.querySelector('meta[name="csrf-token"]');
    var csrf = csrfEl ? csrfEl.content : '';
    var invoiceSel = document.getElementById('tp-invoice');
    var editor = document.getElementById('tp-template');
    var iframe = document.getElementById('tp-pdf');
    var errorBox = document.getElementById('tp-error');
    var body = container.querySelector('.tp-body');

    // Upgrade the textarea to a CodeMirror editor when the library is present
    // (django mode covers HTML + pongo2 {{ }}/{% %} tags); otherwise keep the
    // plain textarea so the page still works.
    var cm = null;
    if (window.CodeMirror) {
        cm = CodeMirror.fromTextArea(editor, {
            mode: 'django',
            lineNumbers: true,
            lineWrapping: false
        });
    }

    // Follow the admin's theme: dark when html[data-theme="dark"], or when the OS
    // is dark and the user hasn't forced light. Toggles .cm-dark on the container
    // (CSS styles CodeMirror dark). Reacts to the toggle and to OS changes.
    function isDark() {
        var t = document.documentElement.getAttribute('data-theme');
        if (t === 'dark') return true;
        if (t === 'light') return false;
        return !!(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    }
    function applyTheme() {
        container.classList.toggle('cm-dark', isDark());
    }
    applyTheme();
    new MutationObserver(applyTheme).observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
    if (window.matchMedia) {
        try { window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', applyTheme); } catch (e) { /* older browsers */ }
    }

    // Size the split panes to the space left below them (viewport bottom minus
    // the panes' top), so the page itself doesn't scroll — only the editor
    // (horizontally) and the PDF pane scroll internally.
    function fitHeight() {
        if (!body) return;
        function apply(h) {
            body.style.height = h + 'px';
            if (cm) cm.setSize('100%', h);
        }
        var h = Math.max(300, window.innerHeight - body.getBoundingClientRect().top - 8);
        apply(h);
        // Shrink by whatever still overflows below (AA footer, page margins) so
        // the page never scrolls — only the panes do. Reading scrollHeight forces
        // a reflow, so iterate a few times to converge.
        for (var i = 0; i < 3; i++) {
            var overflow = document.documentElement.scrollHeight - document.documentElement.clientHeight;
            if (overflow <= 0) break;
            h = Math.max(300, h - overflow);
            apply(h);
        }
    }
    fitHeight();
    // Re-fit after async layout settles (tom-select, web fonts, initial render).
    setTimeout(fitHeight, 400);
    window.addEventListener('resize', fitHeight);

    function templateValue() {
        return cm ? cm.getValue() : editor.value;
    }

    function showError(msg) {
        errorBox.textContent = msg;
        errorBox.style.display = 'block';
    }

    function hideError() {
        errorBox.style.display = 'none';
    }

    // Render the current template against the selected invoice. A spinner is
    // shown over the previous PDF until the response arrives.
    var spinner = container.querySelector('.tp-spinner');
    var renderTimer = null;

    function render() {
        hideError();
        if (!invoiceSel.value) {
            showError('Select an invoice first.');
            return;
        }
        spinner.classList.add('active');
        fetch(previewUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrf,
                'Accept': 'application/pdf'
            },
            body: JSON.stringify({ invoice_id: invoiceSel.value, template: templateValue() })
        }).then(function (resp) {
            if (resp.ok) {
                return resp.blob().then(function (blob) {
                    iframe.src = URL.createObjectURL(blob);
                });
            }
            return resp.text().then(function (t) { showError('Render failed: ' + t); });
        }).catch(function (e) {
            showError('Request failed: ' + e.message);
        }).finally(function () {
            spinner.classList.remove('active');
        });
    }

    // Debounce edits so we don't render on every keystroke.
    function scheduleRender() {
        clearTimeout(renderTimer);
        renderTimer = setTimeout(render, 700);
    }

    invoiceSel.addEventListener('change', render); // immediate on invoice change
    if (cm) {
        cm.on('change', scheduleRender);
    } else {
        editor.addEventListener('input', scheduleRender);
    }

    // Toolbar: Rollback (reload the saved template) and Save (persist edits).
    var templateUrl = container.getAttribute('data-template-url');
    var saveUrl = container.getAttribute('data-save-url');
    var templateId = container.getAttribute('data-template-id');
    var saveStatus = document.getElementById('tp-save-status');

    function setTemplate(val) {
        if (cm) { cm.setValue(val); } else { editor.value = val; }
    }

    document.getElementById('tp-rollback').addEventListener('click', function (e) {
        e.preventDefault();
        hideError();
        fetch(templateUrl + '?template_id=' + encodeURIComponent(templateId), { headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (j) { setTemplate(j.html_template || ''); render(); })
            .catch(function (e) { showError('Reload failed: ' + e.message); });
    });

    document.getElementById('tp-save').addEventListener('click', function (e) {
        e.preventDefault();
        hideError();
        if (saveStatus) { saveStatus.textContent = 'Saving…'; }
        fetch(saveUrl, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrf, 'Accept': 'application/json' },
            body: JSON.stringify({ template_id: templateId, html_template: templateValue() })
        }).then(function (r) {
            if (r.ok) {
                if (saveStatus) {
                    saveStatus.textContent = 'Saved';
                    setTimeout(function () { saveStatus.textContent = ''; }, 2000);
                }
                return;
            }
            return r.json().then(function (j) {
                if (saveStatus) { saveStatus.textContent = ''; }
                showError('Save failed: ' + (j.error || r.status));
            });
        }).catch(function (e) {
            if (saveStatus) { saveStatus.textContent = ''; }
            showError('Save failed: ' + e.message);
        });
    });

    // Initial render so the preview reflects the opened template + first invoice.
    render();
});
