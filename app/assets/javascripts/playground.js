// Page-scoped CodeMirror bundle for the invoice template playground. Included
// only on that page (via javascript_include_tag in the page content), so
// CodeMirror is NOT loaded on every admin page. The playground's own init lives
// in template_playground.js (global, tiny) and upgrades the textarea to
// CodeMirror when this bundle is present. Vendor the CodeMirror 5 files below.
//
//= require vendor/codemirror/lib/codemirror
//= require vendor/codemirror/mode/xml/xml
//= require vendor/codemirror/mode/javascript/javascript
//= require vendor/codemirror/mode/css/css
//= require vendor/codemirror/mode/htmlmixed/htmlmixed
//= require vendor/codemirror/addon/mode/overlay
//= require vendor/codemirror/mode/django/django
