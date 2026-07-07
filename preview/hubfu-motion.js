/**
 * HubFU motion controller — HTML-first animations (GSAP + CSS + vanilla).
 * Port target: Framer Motion in Next.js (see motion-shadcn-guide.md).
 */
(function (global) {
  'use strict';

  var reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;

  function qs(sel, root) {
    return (root || document).querySelector(sel);
  }
  function qsa(sel, root) {
    return Array.prototype.slice.call((root || document).querySelectorAll(sel));
  }

  var HubfuMotion = {
    reduced: reduced,

    init: function () {
      this.initPageEntrance();
      this.initIntegrationStagger();
      this.initTabTransitions();
      this.initButtonRipple();
      this.initShadcnDemos();
      this.initSonnerHost();
      this.hookChatAnimations();
      this.initWorkflowPulse();
    },

    gsapFrom: function (targets, vars) {
      if (reduced || typeof gsap === 'undefined') return;
      gsap.from(targets, vars);
    },

    gsapFromTo: function (targets, fromVars, toVars) {
      if (reduced || typeof gsap === 'undefined') return;
      gsap.fromTo(targets, fromVars, toVars);
    },

    initPageEntrance: function () {
      var container = qs('[data-motion-entrance]');
      if (!container) return;
      var targets = container.querySelectorAll('.motion-box');
      if (!targets.length) return;
      if (reduced) {
        targets.forEach(function (el) {
          el.style.opacity = '1';
        });
        return;
      }
      this.gsapFrom(targets, {
        opacity: 0,
        y: 20,
        duration: 0.55,
        stagger: 0.07,
        ease: 'power3.out',
        clearProps: 'transform',
      });
    },

    replayStagger: function (selector) {
      var boxes = qsa(selector + ' .motion-box');
      if (!boxes.length) return;
      if (reduced) return;
      this.gsapFromTo(
        boxes,
        { opacity: 0, y: 16, scale: 0.9 },
        { opacity: 1, y: 0, scale: 1, duration: 0.55, stagger: 0.08, ease: 'power3.out' }
      );
    },

    initIntegrationStagger: function () {
      var grid = qs('#int-v2-showcase');
      if (!grid) return;
      grid.classList.add('hubfu-int-stagger');
      if (reduced) {
        grid.classList.add('is-visible');
        return;
      }
      if (typeof IntersectionObserver === 'undefined') {
        grid.classList.add('is-visible');
        return;
      }
      var obs = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              entry.target.classList.add('is-visible');
              obs.unobserve(entry.target);
            }
          });
        },
        { threshold: 0.15 }
      );
      obs.observe(grid);
    },

    initTabTransitions: function () {
      var wrap = qs('#tab-demo');
      if (!wrap) return;
      var panel = qs('#tab-panel');
      var btns = qsa('.tab-btn', wrap);
      var labels = [
        'Pipeline kanban com filtros e cards arrastáveis.',
        'Tabela de estoque com badges OK/warn.',
        'Chat IA com action chips.',
        'Gráfico de barras financeiro.',
      ];
      var indicator = qs('#tab-indicator');
      var self = this;

      function moveIndicator(idx) {
        if (!indicator) return;
        var w = 100 / btns.length;
        if (reduced) {
          indicator.style.transform = 'translateX(' + idx * 100 + '%) scaleX(1)';
          indicator.style.width = w + '%';
        } else if (typeof gsap !== 'undefined') {
          gsap.to(indicator, {
            x: idx * (indicator.parentElement.offsetWidth / btns.length),
            scaleX: 1,
            duration: 0.45,
            ease: 'power2.out',
            overwrite: true,
          });
        }
      }

      btns.forEach(function (btn, i) {
        btn.addEventListener('click', function () {
          btns.forEach(function (b) {
            b.classList.remove('active');
          });
          btn.classList.add('active');
          if (panel) {
            if (!reduced && typeof gsap !== 'undefined') {
              gsap.to(panel, {
                opacity: 0.88,
                duration: 0.12,
                onComplete: function () {
                  panel.textContent = labels[i];
                  panel.classList.add('hubfu-tab-panel-enter');
                  gsap.to(panel, { opacity: 1, duration: 0.35, ease: 'power2.out' });
                  setTimeout(function () {
                    panel.classList.remove('hubfu-tab-panel-enter');
                  }, 350);
                },
              });
            } else {
              panel.textContent = labels[i];
            }
          }
          moveIndicator(i);
        });
      });

      if (indicator && btns.length) indicator.style.width = 100 / btns.length + '%';
    },

    initButtonRipple: function () {
      qsa('.hubfu-btn-ripple').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
          if (reduced) return;
          var rect = btn.getBoundingClientRect();
          var dot = document.createElement('span');
          dot.className = 'hubfu-ripple-dot';
          dot.style.left = e.clientX - rect.left - 4 + 'px';
          dot.style.top = e.clientY - rect.top - 4 + 'px';
          btn.appendChild(dot);
          setTimeout(function () {
            if (dot.parentNode) dot.parentNode.removeChild(dot);
          }, 560);
        });
      });
    },

    hookChatAnimations: function () {
      var orig = global._hubfuAppendChatBubble;
      if (typeof orig !== 'function') {
        setTimeout(function () {
          HubfuMotion.hookChatAnimations();
        }, 100);
        return;
      }
      global._hubfuAppendChatBubble = function (thread, text, outgoing, isProduct) {
        orig(thread, text, outgoing, isProduct);
        var row = thread.lastElementChild;
        if (row) {
          row.classList.add('hubfu-chat-enter');
          setTimeout(function () {
            row.classList.remove('hubfu-chat-enter');
          }, 400);
        }
      };
    },

    initWorkflowPulse: function () {
      qsa('.hubfu-flow-node').forEach(function (node) {
        node.addEventListener('mouseenter', function () {
          if (reduced) return;
          node.classList.add('hubfu-node-pulse');
        });
        node.addEventListener('mouseleave', function () {
          node.classList.remove('hubfu-node-pulse');
        });
      });
    },

    initSonnerHost: function () {
      if (qs('.hubfu-sonner-host')) return;
      var host = document.createElement('div');
      host.className = 'hubfu-sonner-host';
      host.setAttribute('aria-live', 'polite');
      document.body.appendChild(host);
      this._sonnerHost = host;
    },

    showSonnerToast: function (title, desc, type) {
      var host = this._sonnerHost || qs('.hubfu-sonner-host');
      if (!host) return;
      var icons = {
        success:
          '<svg class="hubfu-sonner-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="M22 4 12 14.01l-3-3"/></svg>',
        error:
          '<svg class="hubfu-sonner-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="m15 9-6 6M9 9l6 6"/></svg>',
      };
      var el = document.createElement('div');
      el.className = 'hubfu-sonner-toast hubfu-sonner-toast--' + (type || 'success');
      el.innerHTML =
        (icons[type] || icons.success) +
        '<div class="hubfu-sonner-body"><strong>' +
        title +
        '</strong><span>' +
        (desc || '') +
        '</span></div>';
      host.appendChild(el);
      setTimeout(function () {
        el.classList.add('is-leaving');
        setTimeout(function () {
          if (el.parentNode) el.parentNode.removeChild(el);
        }, 180);
      }, 3800);
    },

    initShadcnDemos: function () {
      this.initDialogDemo();
      this.initDropdownDemo();
      this.initShadcnTabs();
      this.initCommandPalette();
    },

    initDialogDemo: function () {
      var dlg = qs('#hubfu-shadcn-dialog');
      if (!dlg) return;
      qsa('[data-dialog-open="hubfu-shadcn-dialog"]').forEach(function (btn) {
        btn.addEventListener('click', function () {
          if (typeof dlg.showModal === 'function') dlg.showModal();
        });
      });
      qsa('[data-dialog-close="hubfu-shadcn-dialog"]').forEach(function (btn) {
        btn.addEventListener('click', function () {
          dlg.close();
        });
      });
    },

    initDropdownDemo: function () {
      qsa('[data-dropdown]').forEach(function (wrap) {
        var trigger = qs('[data-dropdown-trigger]', wrap);
        var menu = qs('.hubfu-dropdown-menu', wrap);
        if (!trigger || !menu) return;
        trigger.addEventListener('click', function (e) {
          e.stopPropagation();
          var open = menu.classList.contains('is-open');
          qsa('.hubfu-dropdown-menu.is-open').forEach(function (m) {
            m.classList.remove('is-open');
          });
          if (!open) menu.classList.add('is-open');
        });
        qsa('.hubfu-dropdown-item', menu).forEach(function (item) {
          item.addEventListener('click', function () {
            menu.classList.remove('is-open');
          });
        });
      });
      document.addEventListener('click', function () {
        qsa('.hubfu-dropdown-menu.is-open').forEach(function (m) {
          m.classList.remove('is-open');
        });
      });
    },

    initShadcnTabs: function () {
      qsa('[data-shadcn-tabs]').forEach(function (root) {
        var triggers = qsa('.hubfu-tabs-shadcn-trigger', root);
        var panels = qsa('.hubfu-tabs-shadcn-panel', root);
        triggers.forEach(function (trigger, i) {
          trigger.addEventListener('click', function () {
            triggers.forEach(function (t) {
              t.classList.remove('is-active');
            });
            panels.forEach(function (p) {
              p.hidden = true;
              p.classList.remove('is-entering');
            });
            trigger.classList.add('is-active');
            if (panels[i]) {
              panels[i].hidden = false;
              panels[i].classList.add('is-entering');
              setTimeout(function () {
                panels[i].classList.remove('is-entering');
              }, 300);
            }
          });
        });
      });
    },

    initCommandPalette: function () {
      var root = qs('#hubfu-command-demo');
      if (!root) return;
      var input = qs('.hubfu-command-input', root);
      var items = qsa('.hubfu-command-item', root);
      if (!input) return;
      input.addEventListener('input', function () {
        var q = input.value.trim().toLowerCase();
        items.forEach(function (item) {
          var label = (item.dataset.label || item.textContent).toLowerCase();
          item.hidden = q.length > 0 && label.indexOf(q) === -1;
        });
      });
      input.addEventListener('keydown', function (e) {
        if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
        e.preventDefault();
        var visible = items.filter(function (it) {
          return !it.hidden;
        });
        if (!visible.length) return;
        var idx = visible.findIndex(function (it) {
          return it.classList.contains('is-highlighted');
        });
        visible.forEach(function (it) {
          it.classList.remove('is-highlighted');
        });
        if (e.key === 'ArrowDown') idx = idx < visible.length - 1 ? idx + 1 : 0;
        else idx = idx > 0 ? idx - 1 : visible.length - 1;
        visible[idx].classList.add('is-highlighted');
      });
    },
  };

  global.HubfuMotion = HubfuMotion;

  function boot() {
    HubfuMotion.init();
    var replay = qs('#motion-replay');
    if (replay) {
      replay.addEventListener('click', function () {
        HubfuMotion.replayStagger('#motion-stagger');
      });
      HubfuMotion.replayStagger('#motion-stagger');
    }
    var replayFramer = qs('#motion-framer-replay');
    if (replayFramer) {
      replayFramer.addEventListener('click', function () {
        HubfuMotion.replayStagger('#motion-framer-stagger');
      });
      HubfuMotion.replayStagger('#motion-framer-stagger');
    }
    var sonnerBtn = qs('#hubfu-sonner-demo-btn');
    if (sonnerBtn) {
      sonnerBtn.addEventListener('click', function () {
        HubfuMotion.showSonnerToast('Integração conectada', 'Slack sincronizado com o CRM.', 'success');
        setTimeout(function () {
          HubfuMotion.showSonnerToast('Exportação concluída', 'CSV de leads baixado.', 'success');
        }, 400);
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})(window);
