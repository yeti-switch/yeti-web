(function () {
    'use strict';

    var SVG_NS = 'http://www.w3.org/2000/svg';

    // --- layout constants ---
    var NODE_W = 220;        // single-column node width (orig/term)
    var SBC_W = 240;         // sbc node width (header + 2 port-column markers)
    var HEADER_H = 40;       // header area (type label + name label)
    var PORT_H = 38;         // height of one port row — drives vertical spacing between arrows
    var NODE_BOTTOM_PAD = 6; // small clearance under last port row
    var COL_GAP = 160;       // horizontal arrow length between node outer edges
    var BETWEEN_ROW = 20;    // vertical gap between adjacent gateway nodes in same column
    var PAD = 10;

    // Colors describe the audio flow direction, not Yeti's RX/TX:
    //   forward  (orig→yeti, yeti→term) = green
    //   backward (yeti→orig, term→yeti) = blue
    var COLOR_FWD = '#2a7';
    var COLOR_BWD = '#27a';
    var NODE_FILL = { orig: '#369', term: '#693', sbc: '#444' };

    function colorFor(direction, side) {
        var fwd = (direction === 'rx' && side === 'left') ||
                  (direction === 'tx' && side === 'right');
        return fwd ? COLOR_FWD : COLOR_BWD;
    }

    function markerFor(direction, side) {
        return colorFor(direction, side) === COLOR_FWD ? 'rtp-arrow-fwd' : 'rtp-arrow-bwd';
    }

    function el(tag, attrs, children) {
        var node = document.createElementNS(SVG_NS, tag);
        if (attrs) Object.keys(attrs).forEach(function (k) {
            if (attrs[k] !== null && attrs[k] !== undefined) node.setAttribute(k, attrs[k]);
        });
        if (children) children.forEach(function (c) { if (c) node.appendChild(c); });
        return node;
    }
    function textNode(t) { return document.createTextNode(t); }

    function socketLabel(host, port) {
        if (host === null || host === undefined || port === null || port === undefined) return '—';
        return host + ':' + port;
    }
    function ssrcLabel(ssrc) {
        if (ssrc === null || ssrc === undefined) return '?';
        return '0x' + ssrc.toString(16).toUpperCase();
    }
    function rxTooltip(s, leg, gwName) {
        return 'Leg' + leg + ' RX  Yeti <- ' + gwName + '\n' +
               'stream #' + s.id + '  ssrc=' + ssrcLabel(s.rx_ssrc) + '\n' +
               'pkts=' + s.rx_packets + '  bytes=' + s.rx_bytes + '  lost=' + s.rx_total_lost + '\n' +
               'jitter_mean=' + s.rx_packet_jitter_mean;
    }
    function txTooltip(s, leg, gwName) {
        return 'Leg' + leg + ' TX  Yeti -> ' + gwName + '\n' +
               'stream #' + s.id + '  ssrc=' + ssrcLabel(s.tx_ssrc) + '\n' +
               'pkts=' + s.tx_packets + '  bytes=' + s.tx_bytes + '  lost=' + s.tx_total_lost + '\n' +
               'rtt_mean=' + s.rtcp_rtt_mean;
    }

    // Build the list of node "pairs":
    //   - Orig: one pair per orig_gw (LegA tag is shared across attempts, so we merge by gateway).
    //   - Term: one pair PER ATTEMPT (a re-routed attempt that reuses the same term gateway
    //     still gets its own node, because each attempt has its own legb_local_tag and stats).
    function pairStreamsByGateway(data) {
        var pairs = {};
        var byTagAndGw = function (streams, tag, gwId) {
            return streams.filter(function (s) { return s.local_tag === tag && s.gateway_id === gwId; });
        };

        // Orig column — group by orig_gw
        var origByGw = {};
        data.attempts.forEach(function (a) {
            if (!a.orig_gw) return;
            var entry = origByGw[a.orig_gw.id] || { gw: a.orig_gw, tags: [] };
            if (entry.tags.indexOf(a.local_tag) === -1 && a.local_tag) entry.tags.push(a.local_tag);
            origByGw[a.orig_gw.id] = entry;
        });
        Object.keys(origByGw).forEach(function (gwIdStr) {
            var gwId = parseInt(gwIdStr, 10);
            var info = origByGw[gwId];
            var rx = [], tx = [];
            info.tags.forEach(function (t) {
                rx = rx.concat(byTagAndGw(data.rx_streams, t, gwId));
                tx = tx.concat(byTagAndGw(data.tx_streams, t, gwId));
            });
            if (rx.length || tx.length) {
                pairs['orig_' + gwId] = {
                    gw: info.gw, side: 'left', leg: 'A',
                    first_attempt: 0,
                    rx: rx.sort(function (a, b) { return a.id - b.id; }),
                    tx: tx.sort(function (a, b) { return a.id - b.id; })
                };
            }
        });

        // Term column — one node per attempt
        data.attempts.forEach(function (a) {
            if (!a.term_gw || !a.legb_local_tag) return;
            var rx = byTagAndGw(data.rx_streams, a.legb_local_tag, a.term_gw.id);
            var tx = byTagAndGw(data.tx_streams, a.legb_local_tag, a.term_gw.id);
            if (!rx.length && !tx.length) return;
            pairs['term_' + a.id] = {
                gw: a.term_gw, side: 'right', leg: 'B',
                routing_attempt: a.routing_attempt,
                first_attempt: a.routing_attempt,
                rx: rx.sort(function (x, y) { return x.id - y.id; }),
                tx: tx.sort(function (x, y) { return x.id - y.id; })
            };
        });

        return pairs;
    }

    // Build a flat list of port rows for one pair.
    //   - Orig (left): RX rows first, then TX rows.
    //   - Term (right): TX rows first, then RX rows — so the outgoing leg sits on top.
    function buildPortRows(pair) {
        var rxRows = pair.rx.map(function (s) {
            return {
                stream: s, direction: 'rx',
                gw_label: socketLabel(s.remote_host, s.remote_port),
                sbc_label: socketLabel(s.local_host, s.local_port),
                tooltip: rxTooltip(s, pair.leg, pair.gw.name),
                ssrc: ssrcLabel(s.rx_ssrc),
                packets: s.rx_packets
            };
        });
        var txRows = pair.tx.map(function (s) {
            return {
                stream: s, direction: 'tx',
                gw_label: '—',
                sbc_label: socketLabel(s.local_host, s.local_port),
                tooltip: txTooltip(s, pair.leg, pair.gw.name),
                ssrc: ssrcLabel(s.tx_ssrc),
                packets: s.tx_packets
            };
        });
        return pair.side === 'right' ? txRows.concat(rxRows) : rxRows.concat(txRows);
    }

    function layoutNodes(pairs) {
        var origIds = Object.keys(pairs).filter(function (k) { return pairs[k].side === 'left'; });
        var termIds = Object.keys(pairs)
            .filter(function (k) { return pairs[k].side === 'right'; })
            .sort(function (a, b) { return pairs[a].first_attempt - pairs[b].first_attempt; });

        var yetiX = PAD + NODE_W + COL_GAP;
        var termX = yetiX + SBC_W + COL_GAP;

        var nodes = {};

        function placeColumn(ids, x, kind, baseTypeLabel) {
            var cursorY = PAD;
            ids.forEach(function (id) {
                var rows = buildPortRows(pairs[id]);
                var h = HEADER_H + rows.length * PORT_H + NODE_BOTTOM_PAD;
                var typeLabel = baseTypeLabel;
                if (kind === 'term') {
                    typeLabel += ' #' + pairs[id].routing_attempt;
                }
                nodes[id] = {
                    id: id, kind: kind, x: x, y: cursorY, w: NODE_W, h: h,
                    type_label: typeLabel,
                    name_label: pairs[id].gw.name,
                    rows: rows.map(function (r, i) {
                        return {
                            y: cursorY + HEADER_H + i * PORT_H,
                            row: r
                        };
                    })
                };
                cursorY += h + BETWEEN_ROW;
            });
        }
        placeColumn(origIds, PAD, 'orig', 'Origination Gateway');
        placeColumn(termIds, termX, 'term', 'Termination Gateway');

        // SBC port rows: one per gateway port row, at the same y so arrows are horizontal.
        var sbcRows = [];
        origIds.concat(termIds).forEach(function (id) {
            var gwNode = nodes[id];
            gwNode.rows.forEach(function (rowEntry) {
                sbcRows.push({
                    y: rowEntry.y,
                    row: rowEntry.row,
                    side: pairs[id].side === 'left' ? 'left' : 'right',
                    gw_node_id: id,
                    pair: pairs[id]
                });
            });
        });

        // SBC dimensions: cover header + all port row positions.
        var topPortY = Math.min.apply(null, sbcRows.map(function (r) { return r.y; }));
        var bottomPortY = Math.max.apply(null, sbcRows.map(function (r) { return r.y; }));
        var sbcTop = Math.min(PAD, topPortY - HEADER_H);
        var sbcBottom = bottomPortY + PORT_H + NODE_BOTTOM_PAD;

        nodes.sbc = {
            id: 'sbc', kind: 'sbc', x: yetiX, y: sbcTop, w: SBC_W, h: sbcBottom - sbcTop,
            type_label: null,
            name_label: 'Yeti SBC',
            sbcRows: sbcRows
        };

        var canvasWidth = PAD * 2 + NODE_W * 2 + SBC_W + COL_GAP * 2;
        var canvasHeight = Math.max.apply(null, Object.keys(nodes).map(function (id) {
            return nodes[id].y + nodes[id].h;
        })) + PAD;

        return { nodes: nodes, pairs: pairs, width: canvasWidth, height: canvasHeight };
    }

    function renderHeader(n) {
        var centerX = n.x + n.w / 2;
        var els = [];
        if (n.type_label) {
            var typeT = el('text', {
                x: centerX, y: n.y + 16, 'text-anchor': 'middle',
                fill: 'white', 'font-size': 11, 'font-style': 'italic', opacity: 0.85
            });
            typeT.appendChild(textNode(n.type_label));
            var nameT = el('text', {
                x: centerX, y: n.y + 32, 'text-anchor': 'middle',
                fill: 'white', 'font-size': 13, 'font-weight': 'bold'
            });
            nameT.appendChild(textNode(n.name_label));
            els.push(typeT, nameT);
        } else {
            var lbl = el('text', {
                x: centerX, y: n.y + 24, 'text-anchor': 'middle',
                fill: 'white', 'font-size': 14, 'font-weight': 'bold'
            });
            lbl.appendChild(textNode(n.name_label));
            els.push(lbl);
        }
        return els;
    }

    function renderGatewayNode(n) {
        var rect = el('rect', { x: n.x, y: n.y, width: n.w, height: n.h, rx: 6, ry: 6,
                                fill: NODE_FILL[n.kind], stroke: '#222' });
        var children = [rect].concat(renderHeader(n));

        // Header/port separator line
        children.push(el('line', { x1: n.x + 4, x2: n.x + n.w - 4,
                                   y1: n.y + HEADER_H, y2: n.y + HEADER_H,
                                   stroke: 'rgba(255,255,255,0.3)', 'stroke-width': 1 }));

        // Each port row: white box w/ colored border + IP:Port text, centered in the row.
        // No RX/TX tag here — direction is shown only on the SBC side (Yeti's perspective).
        var side = n.kind === 'orig' ? 'left' : 'right';
        n.rows.forEach(function (re) {
            var r = re.row;
            var color = colorFor(r.direction, side);
            var rowX = n.x + 6;
            var rowW = n.w - 12;
            var box = el('rect', {
                x: rowX, y: re.y + 1, width: rowW, height: PORT_H - 2,
                fill: '#fff', stroke: color, 'stroke-width': 1, rx: 2, ry: 2
            });
            var label = el('text', {
                x: n.x + n.w / 2, y: re.y + PORT_H / 2 + 3, 'text-anchor': 'middle',
                'font-size': 10, fill: '#222'
            });
            label.appendChild(textNode(r.gw_label));

            var title = el('title');
            title.appendChild(textNode(r.tooltip));
            children.push(el('g', null, [title, box, label]));
        });
        return el('g', null, children);
    }

    function renderSbcNode(n) {
        var rect = el('rect', { x: n.x, y: n.y, width: n.w, height: n.h, rx: 6, ry: 6,
                                fill: NODE_FILL.sbc, stroke: '#222' });
        var children = [rect].concat(renderHeader(n));

        // SBC port rows with RX/TX tag at the arrow-facing edge (Yeti's perspective).
        n.sbcRows.forEach(function (sbcRow) {
            var r = sbcRow.row;
            var color = colorFor(r.direction, sbcRow.side);
            var rowX, rowW;
            if (sbcRow.side === 'left') {
                rowX = n.x + 4;
                rowW = n.w / 2 - 8;
            } else {
                rowX = n.x + n.w / 2 + 4;
                rowW = n.w / 2 - 8;
            }
            var box = el('rect', {
                x: rowX, y: sbcRow.y + 1, width: rowW, height: PORT_H - 2,
                fill: '#fff', stroke: color, 'stroke-width': 1, rx: 2, ry: 2
            });
            var label = el('text', {
                x: rowX + rowW / 2, y: sbcRow.y + PORT_H / 2 + 3, 'text-anchor': 'middle',
                'font-size': 10, fill: '#222'
            });
            label.appendChild(textNode(r.sbc_label));

            // RX/TX tag at the edge that faces the arrow
            var tagX = sbcRow.side === 'left' ? rowX + 4 : rowX + rowW - 4;
            var tagAnchor = sbcRow.side === 'left' ? 'start' : 'end';
            var tag = el('text', {
                x: tagX, y: sbcRow.y + PORT_H / 2 + 3, 'text-anchor': tagAnchor,
                'font-size': 9, 'font-weight': 'bold', fill: color
            });
            tag.appendChild(textNode(r.direction.toUpperCase()));

            var title = el('title');
            title.appendChild(textNode(r.tooltip));
            children.push(el('g', null, [title, box, label, tag]));
        });
        return el('g', null, children);
    }

    function renderEdges(layout, onArrowClick) {
        var sbc = layout.nodes.sbc;
        var arrowEls = [];
        sbc.sbcRows.forEach(function (sbcRow) {
            var r = sbcRow.row;
            var color = colorFor(r.direction, sbcRow.side);
            var marker = markerFor(r.direction, sbcRow.side);
            var y = sbcRow.y + PORT_H / 2;
            var gwNode = layout.nodes[sbcRow.gw_node_id];
            var gwOuterX = sbcRow.side === 'left' ? gwNode.x + gwNode.w : gwNode.x;
            var sbcOuterX = sbcRow.side === 'left' ? sbc.x : sbc.x + sbc.w;
            var x1, x2;
            if (r.direction === 'rx') {
                x1 = gwOuterX; x2 = sbcOuterX;
            } else {
                x1 = sbcOuterX; x2 = gwOuterX;
            }
            var line = el('line', {
                x1: x1, y1: y, x2: x2, y2: y,
                stroke: color, 'stroke-width': 2, 'marker-end': 'url(#' + marker + ')',
                'class': 'rtp-edge'
            });
            // wide invisible hit area so clicking near the arrow works
            var hit = el('line', {
                x1: x1, y1: y, x2: x2, y2: y,
                stroke: 'transparent', 'stroke-width': 18,
                'pointer-events': 'all', style: 'cursor:pointer'
            });
            var midX = (x1 + x2) / 2;
            var ssrcLbl = el('text', {
                x: midX, y: y - 4, 'text-anchor': 'middle',
                'font-size': 9, fill: color
            });
            ssrcLbl.appendChild(textNode(r.ssrc));
            var pktLbl = el('text', {
                x: midX, y: y + 11, 'text-anchor': 'middle',
                'font-size': 9, fill: '#555'
            });
            var pkts = (r.packets === null || r.packets === undefined) ? '?' : r.packets;
            var verb = r.direction === 'rx' ? 'received' : 'sent';
            pktLbl.appendChild(textNode(pkts + ' pkt ' + verb));

            var clickHandler = function () {
                onArrowClick({ stream: r.stream, direction: r.direction, pair: sbcRow.pair, line: line });
            };
            line.addEventListener('click', clickHandler);
            hit.addEventListener('click', clickHandler);

            arrowEls.push(line, hit, ssrcLbl, pktLbl);
        });
        return arrowEls;
    }

    var RX_PANEL_FIELDS = [
        ['id', 'Stream id'],
        ['local_tag', 'Local tag'],
        ['gateway_id', 'Gateway id'],
        ['time_start', 'Time start'],
        ['time_end', 'Time end'],
        ['local_host', 'Local host'],
        ['local_port', 'Local port'],
        ['remote_host', 'Remote host'],
        ['remote_port', 'Remote port'],
        ['rx_ssrc', 'SSRC'],
        ['rx_packets', 'Packets'],
        ['rx_bytes', 'Bytes'],
        ['rx_total_lost', 'Lost'],
        ['rx_packet_jitter_mean', 'Jitter (mean)'],
        ['rx_packet_jitter_max', 'Jitter (max)'],
        ['rx_decode_errors', 'Decode errors']
    ];
    var TX_PANEL_FIELDS = [
        ['id', 'Stream id'],
        ['local_tag', 'Local tag'],
        ['gateway_id', 'Gateway id'],
        ['time_start', 'Time start'],
        ['time_end', 'Time end'],
        ['local_host', 'Local host'],
        ['local_port', 'Local port'],
        ['tx_ssrc', 'SSRC'],
        ['tx_packets', 'Packets'],
        ['tx_bytes', 'Bytes'],
        ['tx_total_lost', 'Lost'],
        ['tx_rtcp_jitter_mean', 'RTCP jitter (mean)'],
        ['rtcp_rtt_mean', 'RTT (mean)'],
        ['rtcp_rtt_max', 'RTT (max)']
    ];

    function formatValue(field, value) {
        if (value === null || value === undefined) return '—';
        if (field.indexOf('ssrc') >= 0) return ssrcLabel(value);
        return String(value);
    }

    function renderStreamPanel(panel, info) {
        panel.innerHTML = '';
        var s = info.stream;
        var fields = info.direction === 'rx' ? RX_PANEL_FIELDS : TX_PANEL_FIELDS;

        var title = document.createElement('h4');
        title.style.cssText = 'margin: 0 0 8px; font-size: 13px; color: #222;';
        var dirText = info.direction === 'rx' ? 'RX (Yeti receives)' : 'TX (Yeti sends)';
        var pairText = info.pair.leg === 'A'
            ? 'LegA ' + (info.direction === 'rx' ? 'from ' : 'to ') + info.pair.gw.name
            : 'LegB ' + (info.direction === 'rx' ? 'from ' : 'to ') + info.pair.gw.name +
              (info.pair.routing_attempt ? ' (attempt #' + info.pair.routing_attempt + ')' : '');
        title.textContent = 'Stream #' + s.id + ' · ' + dirText + ' · ' + pairText;
        panel.appendChild(title);

        // Use a CSS grid of <dl> rows — avoids interaction with ActiveAdmin's table styles.
        var grid = document.createElement('div');
        grid.style.cssText = 'display: grid; grid-template-columns: max-content 1fr; column-gap: 16px; row-gap: 2px; font-size: 12px; color: #222;';
        fields.forEach(function (f) {
            var key = document.createElement('div');
            key.textContent = f[1];
            key.style.cssText = 'color: #666;';
            var val = document.createElement('div');
            val.textContent = formatValue(f[0], s[f[0]]);
            val.style.cssText = 'font-family: monospace;';
            grid.appendChild(key);
            grid.appendChild(val);
        });
        panel.appendChild(grid);
    }

    function renderEmpty(container) {
        container.innerHTML = '';
        var p = document.createElement('p');
        p.textContent = 'No RTP streams found for this CDR.';
        container.appendChild(p);
    }

    function renderDiagram(container, data) {
        data = data || {};
        data.attempts   = data.attempts   || [];
        data.rx_streams = data.rx_streams || [];
        data.tx_streams = data.tx_streams || [];
        if (data.attempts.length === 0 ||
            (data.rx_streams.length === 0 && data.tx_streams.length === 0)) {
            renderEmpty(container);
            return;
        }
        var pairs = pairStreamsByGateway(data);
        if (Object.keys(pairs).length === 0) { renderEmpty(container); return; }
        var layout = layoutNodes(pairs);

        var svg = el('svg', {
            xmlns: SVG_NS, width: layout.width, height: layout.height, 'class': 'rtp-diagram',
            style: 'display:block;width:' + layout.width + 'px;height:' + layout.height +
                   'px;border:1px solid #ddd;background:#fafafa'
        });

        svg.appendChild(el('defs', null, [
            el('marker', { id: 'rtp-arrow-fwd', viewBox: '0 0 10 10', refX: 9, refY: 5,
                           markerWidth: 6, markerHeight: 6, orient: 'auto-start-reverse' }, [
                el('path', { d: 'M 0 0 L 10 5 L 0 10 z', fill: COLOR_FWD })
            ]),
            el('marker', { id: 'rtp-arrow-bwd', viewBox: '0 0 10 10', refX: 9, refY: 5,
                           markerWidth: 6, markerHeight: 6, orient: 'auto-start-reverse' }, [
                el('path', { d: 'M 0 0 L 10 5 L 0 10 z', fill: COLOR_BWD })
            ])
        ]));

        Object.keys(layout.nodes).forEach(function (id) {
            var n = layout.nodes[id];
            svg.appendChild(n.kind === 'sbc' ? renderSbcNode(n) : renderGatewayNode(n));
        });

        container.innerHTML = '';
        container.style.cssText = 'display: flex; align-items: flex-start; gap: 12px;';
        container.appendChild(svg);

        var panel = document.createElement('div');
        panel.className = 'rtp-stream-panel';
        panel.style.cssText = 'flex: 0 0 420px; padding: 10px 14px; border: 1px solid #ddd; background: #fafafa; font-size: 12px; color: #555; align-self: stretch;';
        panel.textContent = 'Click an arrow to view full stream details.';
        container.appendChild(panel);

        var currentLine = null;
        renderEdges(layout, function (info) {
            if (currentLine) currentLine.setAttribute('stroke-width', '2');
            info.line.setAttribute('stroke-width', '4');
            currentLine = info.line;
            renderStreamPanel(panel, info);
        }).forEach(function (e) { svg.appendChild(e); });
    }

    function loadInto(container) {
        var $c = $(container);
        if ($c.data('loaded')) return;
        $c.data('loaded', true);
        var url = $c.data('rtp-diagram-url');
        $.getJSON(url).done(function (data) {
            renderDiagram(container, data);
        }).fail(function (xhr) {
            container.textContent = 'Failed to load RTP diagram: ' + xhr.statusText;
        });
    }

    $(document).ready(function () {
        $('#active_admin_content .tabs').on('tabsactivate', function (event, ui) {
            ui.newPanel.find('.rtp-diagram-container[data-rtp-diagram-url]').each(function () {
                loadInto(this);
            });
        });
    });

    window.RtpDiagram = { render: renderDiagram };
})();
