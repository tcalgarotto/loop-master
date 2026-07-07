/**
 * HubFU Workflow whiteboard — drag/drop nodes + magnetic Bézier connectors.
 * Vanilla JS · preview/hubfu-design-system.html#workflow
 */
(function (global) {
  'use strict';

  var GRID = 8;
  var CP_OFFSET = 50;
  var ZOOM_MIN = 0.5;
  var ZOOM_MAX = 1.5;
  var ZOOM_STEP = 0.05;

  var EDGES = [
    { from: 'trigger', to: 'switch', style: 'accent' },
    { from: 'switch', to: 'upsell', style: 'accent', label: 'Score \u2265 85' },
    { from: 'switch', to: 'nurture', style: 'accent', label: 'Score 60\u201384' },
    { from: 'switch', to: 'crm', style: 'accent', label: 'Score < 60' },
    { from: 'upsell', to: 'outcome-deal', style: 'neutral' },
    { from: 'nurture', to: 'outcome-campaign', style: 'neutral' },
    { from: 'crm', to: 'outcome-archived', style: 'neutral' },
  ];

  function snap(v) {
    return Math.round(v / GRID) * GRID;
  }

  function parsePx(val) {
    if (!val) return 0;
    return parseFloat(String(val).replace('px', '')) || 0;
  }

  function clampZoom(scale) {
    return Math.min(ZOOM_MAX, Math.max(ZOOM_MIN, scale));
  }

  function bezierPath(sx, sy, tx, ty) {
    var dx = Math.max(CP_OFFSET, Math.abs(tx - sx) * 0.4);
    return (
      'M ' +
      sx +
      ' ' +
      sy +
      ' C ' +
      (sx + dx) +
      ' ' +
      sy +
      ', ' +
      (tx - dx) +
      ' ' +
      ty +
      ', ' +
      tx +
      ' ' +
      ty
    );
  }

  function labelPoint(sx, sy, tx, ty) {
    var mx = (sx + tx) / 2;
    var my = (sy + ty) / 2;
    var lift = sy !== ty ? (sy < ty ? -10 : 10) : -10;
    return { x: mx, y: my + lift };
  }

  function HubfuWorkflow(board) {
    this.board = board;
    this.inner = board.querySelector('#hubfu-flow-canvas-inner');
    this.viewport = board.querySelector('#hubfu-flow-viewport');
    this.svg = board.querySelector('.hubfu-flow-svg');
    this.levelEl = board.querySelector('.hubfu-flow-zoom-level');
    this.nodesLayer = board.querySelector('.hubfu-flow-nodes');
    this.scale = 1;
    this.nodes = {};
    this.dragState = null;
    this.panState = null;
  }

  HubfuWorkflow.prototype.init = function () {
    if (!this.inner || !this.svg) return;

    this.collectNodes();
    this.renderEdges();
    this.bindZoom();
    this.bindWheelZoom();
    this.bindPan();
    this.bindNodeDrag();
    this.bindSelection();
    this.applyZoom();
  };

  HubfuWorkflow.prototype.collectNodes = function () {
    var self = this;
    this.board.querySelectorAll('.hubfu-flow-node[data-node-id]').forEach(function (el) {
      var id = el.dataset.nodeId;
      var cs = getComputedStyle(el);
      self.nodes[id] = {
        id: id,
        el: el,
        x: parsePx(cs.getPropertyValue('--flow-x')),
        y: parsePx(cs.getPropertyValue('--flow-y')),
        width: 0,
        height: 0,
      };
    });
    this.measureNodes();
  };

  HubfuWorkflow.prototype.measureNodes = function () {
    var self = this;
    Object.keys(this.nodes).forEach(function (id) {
      var n = self.nodes[id];
      n.width = n.el.offsetWidth;
      n.height = n.el.offsetHeight;
    });
  };

  HubfuWorkflow.prototype.canvasOffset = function () {
    if (!this.nodesLayer || !this.inner) return { x: 0, y: 0 };
    return { x: this.nodesLayer.offsetLeft, y: this.nodesLayer.offsetTop };
  };

  HubfuWorkflow.prototype.getOutput = function (node) {
    var o = this.canvasOffset();
    return { x: o.x + node.x + node.width, y: o.y + node.y + node.height / 2 };
  };

  HubfuWorkflow.prototype.getInput = function (node) {
    var o = this.canvasOffset();
    return { x: o.x + node.x, y: o.y + node.y + node.height / 2 };
  };

  HubfuWorkflow.prototype.renderEdges = function () {
    var self = this;
    this.measureNodes();

    var defs = this.svg.querySelector('defs');
    this.svg.innerHTML = '';
    if (defs) this.svg.appendChild(defs);

    var gPaths = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    gPaths.setAttribute('class', 'hubfu-flow-paths');
    var gLabels = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    gLabels.setAttribute('class', 'hubfu-flow-labels');
    var gDots = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    gDots.setAttribute('class', 'hubfu-flow-dots');

    EDGES.forEach(function (edge, i) {
      var from = self.nodes[edge.from];
      var to = self.nodes[edge.to];
      if (!from || !to) return;

      var out = self.getOutput(from);
      var inp = self.getInput(to);
      var d = bezierPath(out.x, out.y, inp.x, inp.y);

      var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      path.setAttribute('class', 'hubfu-flow-path ' + (edge.style || 'accent'));
      path.setAttribute('d', d);
      path.setAttribute('marker-end', 'url(#flow-arrow)');
      path.dataset.edge = edge.from + '->' + edge.to;
      gPaths.appendChild(path);

      if (edge.label) {
        var lp = labelPoint(out.x, out.y, inp.x, inp.y);
        var text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('class', 'hubfu-flow-branch-label');
        text.setAttribute('x', lp.x);
        text.setAttribute('y', lp.y);
        text.textContent = edge.label;
        gLabels.appendChild(text);
      }

      var dot = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      dot.setAttribute('class', 'hubfu-flow-dot ' + (edge.style === 'neutral' ? 'neutral' : 'accent'));
      dot.setAttribute('r', edge.style === 'neutral' ? '3' : '3.5');
      var anim = document.createElementNS('http://www.w3.org/2000/svg', 'animateMotion');
      anim.setAttribute('dur', edge.from === 'trigger' ? '2.4s' : '2.8s');
      anim.setAttribute('repeatCount', 'indefinite');
      if (i > 0) anim.setAttribute('begin', 0.4 * (i - 1) + 's');
      anim.setAttribute('path', d);
      dot.appendChild(anim);
      gDots.appendChild(dot);
    });

    this.svg.appendChild(gPaths);
    this.svg.appendChild(gLabels);
    this.svg.appendChild(gDots);
  };

  HubfuWorkflow.prototype.setNodePos = function (node, x, y) {
    node.x = x;
    node.y = y;
    node.el.style.setProperty('--flow-x', x + 'px');
    node.el.style.setProperty('--flow-y', y + 'px');
  };

  HubfuWorkflow.prototype.setZoom = function (newScale, pivotClientX, pivotClientY) {
    var oldScale = this.scale;
    newScale = clampZoom(newScale);
    if (newScale === oldScale) return;

    if (this.viewport && pivotClientX != null && pivotClientY != null) {
      var rect = this.viewport.getBoundingClientRect();
      var innerLeft = this.inner.offsetLeft;
      var innerTop = this.inner.offsetTop;
      var contentX = this.viewport.scrollLeft + (pivotClientX - rect.left);
      var contentY = this.viewport.scrollTop + (pivotClientY - rect.top);
      var localX = (contentX - innerLeft) / oldScale;
      var localY = (contentY - innerTop) / oldScale;
      this.viewport.scrollLeft = innerLeft + localX * newScale - (pivotClientX - rect.left);
      this.viewport.scrollTop = innerTop + localY * newScale - (pivotClientY - rect.top);
    }

    this.scale = newScale;
    this.applyZoom();
  };

  HubfuWorkflow.prototype.zoomBy = function (delta, pivotClientX, pivotClientY) {
    this.setZoom(this.scale + delta, pivotClientX, pivotClientY);
  };

  HubfuWorkflow.prototype.bindZoom = function () {
    var self = this;
    this.board.querySelectorAll('.hubfu-flow-zoom-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var z = btn.dataset.zoom;
        var rect = self.viewport ? self.viewport.getBoundingClientRect() : null;
        var pivotX = rect ? rect.left + rect.width / 2 : null;
        var pivotY = rect ? rect.top + rect.height / 2 : null;
        if (z === 'in') self.zoomBy(ZOOM_STEP, pivotX, pivotY);
        else if (z === 'out') self.zoomBy(-ZOOM_STEP, pivotX, pivotY);
        else {
          self.scale = 1;
          self.applyZoom();
        }
      });
    });
  };

  HubfuWorkflow.prototype.bindWheelZoom = function () {
    var self = this;
    if (!this.viewport) return;

    this.viewport.addEventListener(
      'wheel',
      function (e) {
        if (!e.ctrlKey && !e.metaKey) return;
        e.preventDefault();
        var delta = e.deltaY > 0 ? -ZOOM_STEP : ZOOM_STEP;
        self.zoomBy(delta, e.clientX, e.clientY);
      },
      { passive: false }
    );
  };

  HubfuWorkflow.prototype.applyZoom = function () {
    this.inner.style.transform = 'scale(' + this.scale + ')';
    this.inner.style.transformOrigin = '0 0';
    if (this.levelEl) this.levelEl.textContent = Math.round(this.scale * 100) + '%';
  };

  HubfuWorkflow.prototype.bindPan = function () {
    var self = this;
    if (!this.viewport) return;

    this.viewport.addEventListener('pointerdown', function (e) {
      if (e.button !== 0 && e.pointerType === 'mouse') return;
      if (
        e.target.closest('.hubfu-flow-node') ||
        e.target.closest('.hubfu-flow-zoom') ||
        e.target.closest('.hubfu-flow-toolbar')
      ) return;
      self.panState = {
        startX: e.clientX,
        startY: e.clientY,
        scrollL: self.viewport.scrollLeft,
        scrollT: self.viewport.scrollTop,
        pointerId: e.pointerId,
      };
      self.viewport.setPointerCapture(e.pointerId);
      self.viewport.classList.add('is-panning');
    });

    this.viewport.addEventListener('pointermove', function (e) {
      if (!self.panState || self.panState.pointerId !== e.pointerId) return;
      self.viewport.scrollLeft = self.panState.scrollL - (e.clientX - self.panState.startX);
      self.viewport.scrollTop = self.panState.scrollT - (e.clientY - self.panState.startY);
    });

    function endPan(e) {
      if (!self.panState || (e && self.panState.pointerId !== e.pointerId)) return;
      try {
        self.viewport.releasePointerCapture(self.panState.pointerId);
      } catch (_) {}
      self.panState = null;
      self.viewport.classList.remove('is-panning');
    }

    this.viewport.addEventListener('pointerup', endPan);
    this.viewport.addEventListener('pointercancel', endPan);
  };

  HubfuWorkflow.prototype.bindSelection = function () {
    var self = this;
    this.board.querySelectorAll('.hubfu-flow-node').forEach(function (node) {
      node.addEventListener('click', function (e) {
        if (node.classList.contains('was-dragged')) {
          node.classList.remove('was-dragged');
          e.preventDefault();
          return;
        }
        self.board.querySelectorAll('.hubfu-flow-node.is-selected').forEach(function (n) {
          n.classList.remove('is-selected');
        });
        node.classList.add('is-selected');
      });
    });
  };

  HubfuWorkflow.prototype.bindNodeDrag = function () {
    var self = this;

    this.board.querySelectorAll('.hubfu-flow-node[data-node-id]').forEach(function (el) {
      el.addEventListener('pointerdown', function (e) {
        if (e.button !== 0 && e.pointerType === 'mouse') return;
        e.stopPropagation();

        var id = el.dataset.nodeId;
        var node = self.nodes[id];
        if (!node) return;

        self.board.querySelectorAll('.hubfu-flow-node.is-selected').forEach(function (n) {
          n.classList.remove('is-selected');
        });
        el.classList.add('is-selected', 'is-dragging');
        el.setPointerCapture(e.pointerId);

        self.dragState = {
          id: id,
          pointerId: e.pointerId,
          startX: e.clientX,
          startY: e.clientY,
          origX: node.x,
          origY: node.y,
          moved: false,
        };
      });

      el.addEventListener('pointermove', function (e) {
        if (!self.dragState || self.dragState.pointerId !== e.pointerId || self.dragState.id !== el.dataset.nodeId) return;

        var dx = (e.clientX - self.dragState.startX) / self.scale;
        var dy = (e.clientY - self.dragState.startY) / self.scale;

        if (Math.abs(dx) > 2 || Math.abs(dy) > 2) self.dragState.moved = true;

        var node = self.nodes[self.dragState.id];
        self.setNodePos(node, self.dragState.origX + dx, self.dragState.origY + dy);
        self.renderEdges();
      });

      function endDrag(e) {
        if (!self.dragState || self.dragState.pointerId !== e.pointerId || self.dragState.id !== el.dataset.nodeId) return;

        var node = self.nodes[self.dragState.id];
        if (self.dragState.moved) {
          self.setNodePos(node, snap(node.x), snap(node.y));
          self.renderEdges();
          el.classList.add('was-dragged');
        }

        el.classList.remove('is-dragging');
        try {
          el.releasePointerCapture(e.pointerId);
        } catch (_) {}
        self.dragState = null;
      }

      el.addEventListener('pointerup', endDrag);
      el.addEventListener('pointercancel', endDrag);
    });
  };

  function init() {
    var board = document.getElementById('hubfu-flow-board');
    if (!board) return;
    var wf = new HubfuWorkflow(board);
    wf.init();
    global.HubfuWorkflow = wf;
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})(typeof window !== 'undefined' ? window : global);
