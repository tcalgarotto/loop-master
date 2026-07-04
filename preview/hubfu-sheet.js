/**
 * HubfuSheet — planilha interativa estilo Excel (vanilla JS)
 * Edição inline + redimensionamento de colunas + navegação por teclado
 * Save otimista: UI instantânea + debounce mock + rollback em erro (demo)
 */
(function (global) {
  'use strict';

  var SVG = {
    play: '<svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M8 5v14l11-7z"/></svg>',
    coin: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 2l2.4 4.8 5.4.8-3.9 3.8.9 5.3L12 14.8 7.2 17l.9-5.3L4.2 7.6l5.4-.8L12 2z" fill="#f59e0b" stroke="#d97706" stroke-width=".5"/></svg>',
    pencil: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>',
    close: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M18 6 6 18M6 6l12 12"/></svg>',
    chevL: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>',
    chevR: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>',
    download: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>',
    sidebarChev: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>'
  };

  var SPECIMEN_ROWS = [
    ['https://www.linkedin.com/in/ethan-w…', 'Ethan Walker', 'San Francisco Bay Area', 'Co-Founder & CTO at bard…', 'Full Stack Engineer with 10+ years of experience building…'],
    ['https://www.linkedin.com/in/priya-m…', 'Priya Menon', 'Munich, Germany', 'Data Scientist @Example Inc', 'Data Scientist with 8+ years of experience in machine…'],
    ['https://www.linkedin.com/in/liam-o…', 'Liam O\'Connor', 'Dublin, Ireland', 'Head of Engineering at bard…', 'Engineering leader focused on scalable systems and…'],
    ['https://www.linkedin.com/in/sophia…', 'Sophia Nguyen', 'Singapore', 'Product Manager @Example Inc', 'Product leader driving B2B SaaS growth across APAC…'],
    ['https://www.linkedin.com/in/marco…', 'Marco Silva', 'São Paulo, Brazil', 'VP Sales · HubFU partner', 'Enterprise sales with focus on LATAM mid-market…'],
    ['https://www.linkedin.com/in/ana-r…', 'Ana Ribeiro', 'Rio de Janeiro, Brazil', 'Diretora comercial · TechParts', 'Qualificada · pipeline R$ 42k · último contato 12 mar…'],
    ['https://www.linkedin.com/in/ricardo…', 'Ricardo Lima', 'Curitiba, Brazil', 'CEO · Distrib. Sul', 'Proposta enviada R$ 56k · aguardando retorno…'],
    ['https://www.linkedin.com/in/mariana…', 'Mariana Costa', 'Belo Horizonte, Brazil', 'Sócia · Clínica Aurora', 'Negociação contrato anual · R$ 24k…'],
    ['https://www.linkedin.com/in/pedro…', 'Pedro Alves', 'Porto Alegre, Brazil', 'Compras · Metalúrgica Norte', 'Lead inbound · cotação solicitada R$ 38k…'],
    ['https://www.linkedin.com/in/julia…', 'Julia Mendes', 'Florianópolis, Brazil', 'COO · Office Plus', 'Proposta 50 licenças · desconto aprovado…'],
    ['https://www.linkedin.com/in/carlos…', 'Carlos Dias', 'Recife, Brazil', 'Logística · Logisul', 'Ganho R$ 22k · faturamento iniciado…'],
    ['https://www.linkedin.com/in/fernanda…', 'Fernanda Alves', 'Brasília, Brazil', 'Marketing · Agência Pixel', 'Briefing recebido · reunião agendada…']
  ];

  var CRM_MINI_ROWS = [
    ['Distrib. Lima', 'Lima SP', 'Negociação', 'R$ 56k'],
    ['Clínica Aurora', 'Saúde', 'Proposta', 'R$ 24k'],
    ['TechParts', 'Indústria', 'Ganho', 'R$ 31k'],
    ['Office Plus', 'Software', 'Proposta', 'R$ 19k'],
    ['Logisul', 'Logística', 'Ganho', 'R$ 22k']
  ];

  function defaults() {
    return {
      variant: 'full',
      title: 'Adicionar leads qualificados à planilha',
      credits: 64,
      tabLabel: 'Extrator de resultados',
      pageSize: 12,
      columns: [
        { label: 'URL do perfil', count: 10, width: 175, cellClass: 'cell-url' },
        { label: 'Nome', count: 10, width: 120, cellClass: 'cell-name' },
        { label: 'Localização', count: 10, width: 140 },
        { label: 'Headline', count: 10, width: 160 },
        { label: 'Sobre', count: 6, width: 200 }
      ],
      rows: SPECIMEN_ROWS.slice(),
      sidebar: true,
      editable: true,
      resizable: true,
      keyboardNav: true,
      optimisticSave: true,
      saveDebounceMs: 300,
      saveFailRate: 0.05
    };
  }

  function miniDefaults() {
    return {
      variant: 'mini',
      pageSize: 5,
      columns: [
        { label: 'Lead', count: 5, width: 100, cellClass: 'cell-name' },
        { label: 'Empresa', count: 5, width: 90 },
        { label: 'Status', count: 5, width: 80 },
        { label: 'Valor', count: 5, width: 70 }
      ],
      rows: CRM_MINI_ROWS.slice(),
      sidebar: false,
      editable: true,
      resizable: true,
      keyboardNav: true,
      optimisticSave: true,
      saveDebounceMs: 300,
      saveFailRate: 0.05
    };
  }

  function esc(s) {
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function HubfuSheet(root, options) {
    this.root = typeof root === 'string' ? document.querySelector(root) : root;
    if (!this.root) return;
    var base = options && options.variant === 'mini' ? miniDefaults() : defaults();
    this.opts = Object.assign({}, base, options || {});
    if (this.opts.editable && (!options || options.optimisticSave === undefined)) {
      this.opts.optimisticSave = true;
    }
    this.page = 0;
    this.colWidths = this.opts.columns.map(function (c) { return c.width || 120; });
    this._saveTimers = {};
    this.render();
    this.bindEvents();
  }

  HubfuSheet.prototype.totalPages = function () {
    return Math.max(1, Math.ceil(this.opts.rows.length / this.opts.pageSize));
  };

  HubfuSheet.prototype.pageRows = function () {
    var start = this.page * this.opts.pageSize;
    return this.opts.rows.slice(start, start + this.opts.pageSize);
  };

  HubfuSheet.prototype.renderHint = function () {
    return (
      '<div class="ds-sheet-hint" role="note">' +
        '<span class="ds-sheet-hint-icon" aria-hidden="true">i</span>' +
        '<span>Clique para editar · Salvo otimista (instantâneo) · Arraste a borda da coluna · Tab para navegar</span>' +
      '</div>'
    );
  };

  HubfuSheet.prototype.renderTable = function () {
    var self = this;
    var cols = this.opts.columns;
    var rows = this.pageRows();

    var colgroup = '<col class="col-row-num" style="width:36px">';
    cols.forEach(function (c, i) {
      colgroup += '<col style="width:' + self.colWidths[i] + 'px">';
    });

    var thead = '<thead><tr><th class="row-num" scope="col">#</th>';
    cols.forEach(function (c, i) {
      thead += '<th scope="col" data-col="' + i + '"><span class="col-label">' + esc(c.label) + '</span>';
      if (c.count != null) thead += '<span class="col-count">' + c.count + ' registros</span>';
      if (self.opts.resizable) {
        thead += '<span class="col-resize-handle" data-col="' + i + '" role="separator" aria-orientation="vertical" aria-label="Redimensionar coluna"></span>';
      }
      thead += '</th>';
    });
    thead += '</tr></thead>';

    var tbody = '<tbody>';
    rows.forEach(function (row, ri) {
      var rowNum = self.page * self.opts.pageSize + ri + 1;
      tbody += '<tr data-row="' + rowNum + '"><td class="row-num">' + rowNum + '</td>';
      cols.forEach(function (c, ci) {
        var val = row[ci] != null ? row[ci] : '';
        var cls = c.cellClass || '';
        var edit = self.opts.editable ? ' contenteditable="true" tabindex="0" data-editable data-col="' + ci + '"' : '';
        tbody += '<td class="' + cls + '"' + edit + '>' + esc(val) + '</td>';
      });
      tbody += '</tr>';
    });
    tbody += '</tbody>';

    return (
      '<div class="ds-sheet-table-wrap">' +
        '<table class="ds-sheet-table" role="grid">' +
          '<colgroup>' + colgroup + '</colgroup>' +
          thead + tbody +
        '</table>' +
      '</div>'
    );
  };

  HubfuSheet.prototype.renderChrome = function () {
    var o = this.opts;
    return (
      '<header class="ds-sheet-header">' +
        '<div class="ds-sheet-title-wrap">' +
          '<span class="ds-sheet-logo" aria-hidden="true"><span></span><span></span></span>' +
          '<span class="ds-sheet-title">' + esc(o.title) + '</span>' +
        '</div>' +
        '<div class="ds-sheet-header-actions">' +
          '<span class="ds-sheet-credits">' + SVG.coin + '<span>' + o.credits + '</span></span>' +
          '<button type="button" class="ds-sheet-icon-btn" aria-label="Editar workflow">' + SVG.pencil + '</button>' +
          '<button type="button" class="ds-sheet-run" aria-label="Executar workflow">' + SVG.play + 'Executar</button>' +
          '<button type="button" class="ds-sheet-close" aria-label="Fechar">' + SVG.close + '</button>' +
        '</div>' +
      '</header>' +
      '<div class="ds-sheet-body">' +
        '<div class="ds-sheet-main">' +
          '<div class="ds-sheet-tab">' +
            '<span class="ds-sheet-tab-label">' +
              '<span class="ds-sheet-tab-icon" aria-hidden="true"></span>' +
              esc(o.tabLabel) +
            '</span>' +
            '<div class="ds-sheet-tab-actions">' +
              '<button type="button" class="ds-sheet-tab-btn ds-sheet-page-prev" aria-label="Página anterior"' +
                (this.page <= 0 ? ' disabled' : '') + '>' + SVG.chevL + '</button>' +
              '<span class="ds-sheet-page-info" aria-live="polite">' + (this.page + 1) + ' / ' + this.totalPages() + '</span>' +
              '<button type="button" class="ds-sheet-tab-btn ds-sheet-page-next" aria-label="Próxima página"' +
                (this.page >= this.totalPages() - 1 ? ' disabled' : '') + '>' + SVG.chevR + '</button>' +
              '<button type="button" class="ds-sheet-tab-btn ds-sheet-download" aria-label="Exportar CSV">' + SVG.download + '</button>' +
            '</div>' +
          '</div>' +
          this.renderHint() +
          this.renderTable() +
        '</div>' +
        (o.sidebar ? this.renderSidebar() : '') +
      '</div>'
    );
  };

  HubfuSheet.prototype.renderSidebar = function () {
    return (
      '<aside class="ds-sheet-sidebar" aria-label="Ações do workflow">' +
        '<div class="ds-sheet-sidebar-head">' +
          '<span>Ações</span>' +
          '<button type="button" class="ds-sheet-sidebar-collapse" aria-label="Colapsar">' + SVG.sidebarChev + '</button>' +
        '</div>' +
        '<ol class="ds-sheet-steps">' +
          '<li class="ds-sheet-step"><span class="ds-sheet-step-icon scraper" aria-hidden="true"></span>Extrator de resultados</li>' +
          '<li><button type="button" class="ds-sheet-add" aria-label="Adicionar etapa">+</button></li>' +
          '<li class="ds-sheet-step"><span class="ds-sheet-step-icon enrich" aria-hidden="true"></span>Enriquecimento</li>' +
          '<li class="ds-sheet-step"><span class="ds-sheet-step-icon qualify" aria-hidden="true"></span>Qualificação</li>' +
          '<li><button type="button" class="ds-sheet-add" aria-label="Adicionar etapa">+</button></li>' +
        '</ol>' +
        '<div class="ds-sheet-toggles">' +
          '<label class="ds-sheet-toggle">Exportar <span class="ds-sheet-switch on" role="switch" aria-checked="true" tabindex="0"></span></label>' +
          '<label class="ds-sheet-toggle">Agendar execução <span class="ds-sheet-switch" role="switch" aria-checked="false" tabindex="0"></span></label>' +
        '</div>' +
      '</aside>'
    );
  };

  HubfuSheet.prototype.render = function () {
    if (this.opts.variant === 'mini') {
      this.root.classList.add('ds-sheet-mini');
      this.root.innerHTML = this.renderHint() + this.renderTable();
      this.root.setAttribute('data-hubfu-sheet', 'mini');
    } else {
      this.root.classList.add('ds-sheet');
      this.root.innerHTML = this.renderChrome();
      this.root.setAttribute('data-hubfu-sheet', 'full');
    }
  };

  HubfuSheet.prototype.refreshTable = function () {
    var wrap = this.root.querySelector('.ds-sheet-table-wrap');
    if (!wrap) return;
    wrap.outerHTML = this.renderTable();
    this.bindTableEvents();
  };

  HubfuSheet.prototype.refreshPagination = function () {
    var prev = this.root.querySelector('.ds-sheet-page-prev');
    var next = this.root.querySelector('.ds-sheet-page-next');
    var info = this.root.querySelector('.ds-sheet-page-info');
    if (prev) prev.disabled = this.page <= 0;
    if (next) next.disabled = this.page >= this.totalPages() - 1;
    if (info) info.textContent = (this.page + 1) + ' / ' + this.totalPages();
  };

  HubfuSheet.prototype.bindColumnResize = function () {
    if (!this.opts.resizable) return;
    var self = this;
    this.root.querySelectorAll('.col-resize-handle').forEach(function (handle) {
      handle.addEventListener('mousedown', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var colIdx = parseInt(handle.dataset.col, 10);
        var table = self.root.querySelector('.ds-sheet-table');
        if (!table) return;
        var colEl = table.querySelectorAll('colgroup col')[colIdx + 1];
        var th = handle.closest('th');
        var startX = e.clientX;
        var startW = th ? th.offsetWidth : self.colWidths[colIdx];
        var guide = document.createElement('div');
        guide.className = 'ds-sheet-resize-guide';
        document.body.appendChild(guide);

        function positionGuide(clientX) {
          guide.style.left = clientX + 'px';
        }
        positionGuide(startX);

        handle.classList.add('active');
        document.body.style.cursor = 'col-resize';
        document.body.style.userSelect = 'none';

        function onMove(ev) {
          var w = Math.max(48, startW + (ev.clientX - startX));
          if (colEl) colEl.style.width = w + 'px';
          self.colWidths[colIdx] = w;
          positionGuide(ev.clientX);
        }
        function onUp() {
          handle.classList.remove('active');
          document.body.style.cursor = '';
          document.body.style.userSelect = '';
          if (guide.parentNode) guide.parentNode.removeChild(guide);
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
        }
        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    });
  };

  HubfuSheet.prototype.ensureToastHost = function () {
    if (!this._toastHost) {
      this._toastHost = document.createElement('div');
      this._toastHost.className = 'hubfu-toast-host';
      this._toastHost.setAttribute('aria-live', 'polite');
      document.body.appendChild(this._toastHost);
    }
    return this._toastHost;
  };

  HubfuSheet.prototype.showToast = function (msg, type) {
    var host = this.ensureToastHost();
    var el = document.createElement('div');
    el.className = 'hubfu-toast hubfu-toast--' + (type || 'error');
    el.textContent = msg;
    host.appendChild(el);
    setTimeout(function () {
      el.classList.add('hubfu-toast--out');
      setTimeout(function () {
        if (el.parentNode) el.parentNode.removeChild(el);
      }, 200);
    }, 3500);
  };

  HubfuSheet.prototype.setRowSyncing = function (tr, syncing) {
    if (!tr) return;
    tr.classList.toggle('row-syncing', !!syncing);
  };

  HubfuSheet.prototype.saveCellOptimistic = function (cell, originalValue) {
    var self = this;
    if (!this.opts.editable || this.opts.optimisticSave === false) return;

    var tr = cell.closest('tr');
    if (!tr) return;

    var globalRow = parseInt(tr.dataset.row, 10) - 1;
    var colIdx = parseInt(cell.dataset.col, 10);
    if (isNaN(globalRow) || isNaN(colIdx)) return;

    var newValue = cell.textContent.trim();
    if (newValue === originalValue) return;

    if (self.opts.rows[globalRow]) {
      self.opts.rows[globalRow][colIdx] = newValue;
    }

    self.setRowSyncing(tr, true);

    var key = globalRow + ':' + colIdx;
    if (self._saveTimers[key]) clearTimeout(self._saveTimers[key]);

    self._saveTimers[key] = setTimeout(function () {
      var fail = Math.random() < (self.opts.saveFailRate || 0);
      self.setRowSyncing(tr, false);
      if (fail) {
        if (self.opts.rows[globalRow]) {
          self.opts.rows[globalRow][colIdx] = originalValue;
        }
        cell.textContent = originalValue;
        self.showToast('Falha ao salvar — valor revertido', 'error');
      }
      delete self._saveTimers[key];
    }, self.opts.saveDebounceMs || 300);
  };

  HubfuSheet.prototype.bindCellEdit = function () {
    if (!this.opts.editable) return;
    var self = this;
    this.root.querySelectorAll('.ds-sheet-table td[data-editable]').forEach(function (cell) {
      cell.addEventListener('focus', function () {
        cell.classList.add('cell-active');
        cell._origValue = cell.textContent.trim();
      });
      cell.addEventListener('blur', function () {
        cell.classList.remove('cell-active');
        self.saveCellOptimistic(cell, cell._origValue != null ? cell._origValue : '');
      });
      cell.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          cell.blur();
        }
      });
    });
  };

  HubfuSheet.prototype.bindKeyboardNav = function () {
    if (!this.opts.keyboardNav || !this.opts.editable) return;
    var self = this;
    this.root.addEventListener('keydown', function (e) {
      var active = document.activeElement;
      if (!active || !active.hasAttribute('data-editable')) return;
      if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Tab'].indexOf(e.key) === -1) return;

      var cells = Array.prototype.slice.call(
        self.root.querySelectorAll('.ds-sheet-table td[data-editable]')
      );
      var idx = cells.indexOf(active);
      if (idx === -1) return;

      var cols = self.opts.columns.length;
      var next = idx;
      if (e.key === 'ArrowRight' || (e.key === 'Tab' && !e.shiftKey)) next = idx + 1;
      else if (e.key === 'ArrowLeft' || (e.key === 'Tab' && e.shiftKey)) next = idx - 1;
      else if (e.key === 'ArrowDown') next = idx + cols;
      else if (e.key === 'ArrowUp') next = idx - cols;

      if (next >= 0 && next < cells.length) {
        e.preventDefault();
        cells[next].focus();
      }
    });
  };

  HubfuSheet.prototype.bindToggles = function () {
    this.root.querySelectorAll('.ds-sheet-switch').forEach(function (sw) {
      function toggle() {
        var on = sw.classList.toggle('on');
        sw.setAttribute('aria-checked', on ? 'true' : 'false');
      }
      sw.addEventListener('click', toggle);
      sw.addEventListener('keydown', function (e) {
        if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); toggle(); }
      });
    });
  };

  HubfuSheet.prototype.exportCsv = function () {
    var cols = this.opts.columns.map(function (c) { return c.label; });
    var lines = [cols.join(',')];
    this.opts.rows.forEach(function (row) {
      lines.push(row.map(function (v) {
        var s = String(v == null ? '' : v).replace(/"/g, '""');
        return '"' + s + '"';
      }).join(','));
    });
    var blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'hubfu-sheet.csv';
    a.click();
    URL.revokeObjectURL(a.href);
  };

  HubfuSheet.prototype.bindTableEvents = function () {
    this.bindColumnResize();
    this.bindCellEdit();
    this.bindKeyboardNav();
  };

  HubfuSheet.prototype.bindEvents = function () {
    var self = this;
    this.bindTableEvents();
    this.bindToggles();

    this.root.addEventListener('click', function (e) {
      if (e.target.closest('.ds-sheet-page-prev')) {
        if (self.page > 0) { self.page--; self.refreshTable(); self.refreshPagination(); }
      } else if (e.target.closest('.ds-sheet-page-next')) {
        if (self.page < self.totalPages() - 1) { self.page++; self.refreshTable(); self.refreshPagination(); }
      } else if (e.target.closest('.ds-sheet-download')) {
        self.exportCsv();
      }
    });
  };

  HubfuSheet.presets = { specimen: defaults, mini: miniDefaults, SPECIMEN_ROWS: SPECIMEN_ROWS, CRM_MINI_ROWS: CRM_MINI_ROWS };

  global.HubfuSheet = HubfuSheet;
})(typeof window !== 'undefined' ? window : this);
