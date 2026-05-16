(function () {
    'use strict';

    var SVG_NS = 'http://www.w3.org/2000/svg';

    // --- layout constants ---
    var NODE_W = 220;        // single-column node width (orig/term)
    var SBC_W = 360;         // sbc node width (port header + RX-errors / RX-TX-label columns)
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
    // Receive-side error counters are recorded on the TX stream row (one set
    // per local port). They describe the RX direction, so they are shown next
    // to the RX label inside the SBC port.
    function rxErrCount(v) { return (v === null || v === undefined) ? 0 : v; }
    // One entry per line; `err` flags the counters whose value is non-zero so
    // only those rows are highlighted (the header is never highlighted).
    function rxErrRows(s) {
        var ob = rxErrCount(s.rx_out_of_buffer_errors);
        var pe = rxErrCount(s.rx_rtp_parse_errors);
        var dp = rxErrCount(s.rx_dropped_packets);
        var sd = rxErrCount(s.rx_srtp_decrypt_errors);
        return [
            { text: 'RX Errors:', err: false },
            { text: '  out of buffer: ' + ob, err: ob > 0 },
            { text: '  parse: ' + pe, err: pe > 0 },
            { text: '  dropped: ' + dp, err: dp > 0 },
            { text: '  srtp decrypt: ' + sd, err: sd > 0 }
        ];
    }
    function rxErrTooltip(s) {
        return 'RX errors (per local port)\n' +
               'out of buffer: ' + rxErrCount(s.rx_out_of_buffer_errors) + '\n' +
               'rtp parse: ' + rxErrCount(s.rx_rtp_parse_errors) + '\n' +
               'dropped packets: ' + rxErrCount(s.rx_dropped_packets) + '\n' +
               'srtp decrypt: ' + rxErrCount(s.rx_srtp_decrypt_errors);
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

        // The remote gateway is a single "port" object: one box that all of
        // Yeti's arrows connect to. Labels are from the GATEWAY's perspective,
        // which is inverted vs Yeti: Yeti RX = gateway TX, Yeti TX = gateway RX.
        // The remote host:port is only known from Yeti's RX streams (= the
        // gateway's TX), so it is shown on the gateway-TX rows; gateway-RX rows
        // show "—". RX/TX labels sit at the arrow-facing edge.
        var side = n.kind === 'orig' ? 'left' : 'right';
        var rowX = n.x + 6;
        var rowW = n.w - 12;

        var firstY = n.rows[0].y;
        var lastY = n.rows[n.rows.length - 1].y;
        var boxY = firstY + 1;
        var boxH = (lastY + PORT_H) - firstY - 2;

        children.push(el('rect', {
            x: rowX, y: boxY, width: rowW, height: boxH,
            fill: '#fff', stroke: '#666', 'stroke-width': 1, rx: 2, ry: 2
        }));

        // Arrow-facing edge: orig (left) → right edge; term (right) → left edge.
        // The ip:port sits right next to the direction label, sharing its
        // alignment (just inward from the label).
        var labelX, labelAnchor, ipX;
        if (side === 'left') {
            labelX = rowX + rowW - 6;
            labelAnchor = 'end';
            ipX = labelX - 26;
        } else {
            labelX = rowX + 6;
            labelAnchor = 'start';
            ipX = labelX + 26;
        }

        // Multiple RX streams (= gateway TX) can belong to the same call leg.
        // Show the remote ip:port once per distinct value: if they all share
        // the same remote socket, only the first RX row prints it; differing
        // sockets are each shown next to their own TX label.
        var seenRemote = {};

        n.rows.forEach(function (re) {
            var r = re.row;
            var color = colorFor(r.direction, side);
            var rowMidY = re.y + PORT_H / 2 + 3;

            // Gateway-side direction is the inverse of Yeti's.
            var gwDir = r.direction === 'rx' ? 'TX' : 'RX';
            var rowEls = [];

            // Remote ip:port is only known from RX streams (gateway TX),
            // deduplicated across the leg.
            if (r.direction === 'rx' && !seenRemote[r.gw_label]) {
                seenRemote[r.gw_label] = true;
                var ip = el('text', {
                    x: ipX, y: rowMidY, 'text-anchor': labelAnchor,
                    'font-size': 11, fill: '#222'
                });
                ip.appendChild(textNode(r.gw_label));
                rowEls.push(ip);
            }

            var tag = el('text', {
                x: labelX, y: rowMidY, 'text-anchor': labelAnchor,
                'font-size': 11, 'font-weight': 'bold', fill: color
            });
            tag.appendChild(textNode(gwDir));
            rowEls.push(tag);

            var title = el('title');
            title.appendChild(textNode(r.tooltip));
            children.push(el('g', null, [title].concat(rowEls)));
        });
        return el('g', null, children);
    }

    // Group consecutive SBC rows that share the same local socket into one "port"
    // object. The TX stream and its related RX stream(s) bind the same local
    // host:port (RX local_host/port is copied from the TX stream), so they belong
    // to a single Yeti SBC port — one box, with one arrow per stream.
    function groupSbcPorts(sbcRows) {
        var groups = [];
        sbcRows.forEach(function (sbcRow) {
            var key = sbcRow.side + '|' + sbcRow.gw_node_id + '|' + sbcRow.row.sbc_label;
            var last = groups[groups.length - 1];
            if (last && last.key === key) {
                last.rows.push(sbcRow);
            } else {
                groups.push({
                    key: key, side: sbcRow.side,
                    label: sbcRow.row.sbc_label, rows: [sbcRow]
                });
            }
        });
        return groups;
    }

    function renderSbcNode(n) {
        var rect = el('rect', { x: n.x, y: n.y, width: n.w, height: n.h, rx: 6, ry: 6,
                                fill: NODE_FILL.sbc, stroke: '#222' });
        var children = [rect].concat(renderHeader(n));

        // One box per local port; the TX stream and its related RX stream(s)
        // (same local host:port) share it. Per-stream RX/TX tags sit at each
        // arrow's y so every arrow still reads its own direction.
        var LABEL_W = 30;     // RX / TX label column width

        groupSbcPorts(n.sbcRows).forEach(function (port) {
            var rowX, rowW;
            if (port.side === 'left') {
                rowX = n.x + 4;
                rowW = n.w / 2 - 8;
            } else {
                rowX = n.x + n.w / 2 + 4;
                rowW = n.w / 2 - 8;
            }
            var firstY = port.rows[0].y;
            var lastY = port.rows[port.rows.length - 1].y;
            var boxY = firstY + 1;
            var boxH = (lastY + PORT_H) - firstY - 2;

            // Neutral border: the port is bidirectional; direction is conveyed
            // by the per-stream RX/TX labels and the arrow colors.
            var box = el('rect', {
                x: rowX, y: boxY, width: rowW, height: boxH,
                fill: '#fff', stroke: '#666', 'stroke-width': 1, rx: 2, ry: 2
            });
            var groupEls = [box];

            // Two body columns. The RX/TX label column sits at the
            // arrow-facing edge (left side → left edge, right side → right
            // edge); the RX-errors column takes the remaining inner space.
            var labelX, labelAnchor, errColX;
            if (port.side === 'left') {
                labelX = rowX + 6;
                labelAnchor = 'start';
                errColX = rowX + LABEL_W + 6;
            } else {
                labelX = rowX + rowW - 6;
                labelAnchor = 'end';
                errColX = rowX + 6;
            }

            // --- port header: host:port (left-aligned with the errors block) ---
            var hdr = el('text', {
                x: errColX, y: boxY + 11, 'text-anchor': 'start',
                'font-size': 12, 'font-weight': 'bold', fill: '#222'
            });
            hdr.appendChild(textNode(port.label));
            groupEls.push(hdr);

            // RX-side error counters are stored on the TX stream row for this
            // local port; render them once per port in the errors column.
            var txStream = null;
            port.rows.forEach(function (sbcRow) {
                if (!txStream && sbcRow.row.direction === 'tx') txStream = sbcRow.row.stream;
            });
            if (txStream) {
                var rows = rxErrRows(txStream);
                var lineH = 12;
                // Start the errors block on the same line as the first RX/TX label.
                var blockTop = firstY + PORT_H / 2 + 3;
                var errT = el('text', {
                    x: errColX, 'text-anchor': 'start', 'font-size': 10
                });
                rows.forEach(function (ln, i) {
                    // Only the counter line with a non-zero value turns red.
                    var tspan = el('tspan', {
                        x: errColX, y: blockTop + i * lineH,
                        fill: ln.err ? '#c33' : '#999'
                    });
                    tspan.appendChild(textNode(ln.text));
                    errT.appendChild(tspan);
                });
                var errTitle = el('title');
                errTitle.appendChild(textNode(rxErrTooltip(txStream)));
                errT.appendChild(errTitle);
                groupEls.push(errT);
            }

            // RX / TX label per member stream, aligned with its arrow.
            port.rows.forEach(function (sbcRow) {
                var r = sbcRow.row;
                var color = colorFor(r.direction, sbcRow.side);
                var tag = el('text', {
                    x: labelX, y: sbcRow.y + PORT_H / 2 + 3, 'text-anchor': labelAnchor,
                    'font-size': 11, 'font-weight': 'bold', fill: color
                });
                tag.appendChild(textNode(r.direction.toUpperCase()));
                groupEls.push(tag);
            });

            var title = el('title');
            title.appendChild(textNode(
                'Yeti SBC port ' + port.label + '\n' +
                port.rows.map(function (sr) { return sr.row.tooltip; }).join('\n\n')
            ));
            children.push(el('g', null, [title].concat(groupEls)));
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
            // wide invisible hit area so clicking near the arrow works.
            // 32 ≈ row pitch (PORT_H 38) minus a small gap so adjacent
            // arrows' hit zones don't overlap.
            var hit = el('line', {
                x1: x1, y1: y, x2: x2, y2: y,
                stroke: 'transparent', 'stroke-width': 32,
                'pointer-events': 'all', style: 'cursor:pointer'
            });
            var midX = (x1 + x2) / 2;
            var ssrcLbl = el('text', {
                x: midX, y: y - 4, 'text-anchor': 'middle',
                'font-size': 9, fill: color, 'pointer-events': 'none'
            });
            ssrcLbl.appendChild(textNode(r.ssrc));
            var pktLbl = el('text', {
                x: midX, y: y + 11, 'text-anchor': 'middle',
                'font-size': 9, fill: '#555', 'pointer-events': 'none'
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

    // Field order and labels mirror the RtpRxStreams admin show page.
    var RX_PANEL_FIELDS = [
        ['id', 'Id'],
        ['time_start', 'Time start'],
        ['stream_time_start', 'Stream time start'],
        ['stream_time_end', 'Stream time end'],
        ['rx_ssrc', 'Rx ssrc'],
        ['remote_host', 'Remote host'],
        ['remote_port', 'Remote port'],
        ['local_host', 'Local host'],
        ['local_port', 'Local port'],
        ['rx_packets', 'Rx packets'],
        ['rx_bytes', 'Rx bytes'],
        ['rx_total_lost', 'Rx total lost'],
        ['rx_payloads_transcoded', 'Rx payloads transcoded'],
        ['rx_payloads_relayed', 'Rx payloads relayed'],
        ['rx_decode_errors', 'Rx decode errors'],
        ['rx_packet_delta_min', 'Rx packet delta min'],
        ['rx_packet_delta_max', 'Rx packet delta max'],
        ['rx_packet_delta_mean', 'Rx packet delta mean'],
        ['rx_packet_delta_std', 'Rx packet delta std'],
        ['rx_packet_jitter_min', 'Rx packet jitter min'],
        ['rx_packet_jitter_max', 'Rx packet jitter max'],
        ['rx_packet_jitter_mean', 'Rx packet jitter mean'],
        ['rx_packet_jitter_std', 'Rx packet jitter std'],
        ['rx_rtcp_jitter_min', 'Rx rtcp jitter min'],
        ['rx_rtcp_jitter_max', 'Rx rtcp jitter max'],
        ['rx_rtcp_jitter_mean', 'Rx rtcp jitter mean'],
        ['rx_rtcp_jitter_std', 'Rx rtcp jitter std']
    ];
    // Field order and labels mirror the RtpTxStreams admin show page.
    var TX_PANEL_FIELDS = [
        ['id', 'Id'],
        ['time_start', 'Time start'],
        ['stream_time_start', 'Stream time start'],
        ['stream_time_end', 'Stream time end'],
        ['rtcp_rtt_min', 'Rtcp rtt min'],
        ['rtcp_rtt_max', 'Rtcp rtt max'],
        ['rtcp_rtt_mean', 'Rtcp rtt mean'],
        ['rtcp_rtt_std', 'Rtcp rtt std'],
        ['rx_out_of_buffer_errors', 'Rx out of buffer errors'],
        ['rx_rtp_parse_errors', 'Rx rtp parse errors'],
        ['rx_dropped_packets', 'Rx dropped packets'],
        ['rx_srtp_decrypt_errors', 'Rx srtp decrypt errors'],
        ['tx_packets', 'Tx packets'],
        ['tx_bytes', 'Tx bytes'],
        ['tx_ssrc', 'Tx ssrc'],
        ['local_host', 'Local host'],
        ['local_port', 'Local port'],
        ['tx_total_lost', 'Tx total lost'],
        ['tx_payloads_transcoded', 'Tx payloads transcoded'],
        ['tx_payloads_relayed', 'Tx payloads relayed'],
        ['tx_rtcp_jitter_min', 'Tx rtcp jitter min'],
        ['tx_rtcp_jitter_max', 'Tx rtcp jitter max'],
        ['tx_rtcp_jitter_mean', 'Tx rtcp jitter mean'],
        ['tx_rtcp_jitter_std', 'Tx rtcp jitter std']
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

        // A single reusable orange "border": a wider line drawn *behind* the
        // selected arrow, so the arrow keeps its own color and width and just
        // gains an orange outline. Appended before the arrows so it sits under
        // them but above the node boxes.
        var highlight = el('line', {
            stroke: '#f60', 'stroke-width': 7, 'stroke-linecap': 'round',
            'pointer-events': 'none', visibility: 'hidden'
        });
        svg.appendChild(highlight);
        renderEdges(layout, function (info) {
            ['x1', 'y1', 'x2', 'y2'].forEach(function (a) {
                highlight.setAttribute(a, info.line.getAttribute(a));
            });
            highlight.setAttribute('visibility', 'visible');
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
