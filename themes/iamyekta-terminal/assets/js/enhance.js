// Progressive enhancements: copy-to-clipboard, reading progress, back-to-top,
// and a tiny shutdown easter egg. Everything works without it.
(function () {
  'use strict';

  function initCopyButtons() {
    document.querySelectorAll('.code-copy').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var block = btn.closest('.code-block');
        var code = block && block.querySelector('.chroma');
        if (!code) return;
        var text = code.innerText.replace(/\n$/, '');

        var done = function () {
          btn.classList.add('copied');
          btn.setAttribute('title', 'Copied!');
          setTimeout(function () {
            btn.classList.remove('copied');
            btn.setAttribute('title', 'Copy');
          }, 1600);
        };

        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(done).catch(function () {});
        } else {
          var ta = document.createElement('textarea');
          ta.value = text;
          ta.style.position = 'fixed';
          ta.style.opacity = '0';
          document.body.appendChild(ta);
          ta.select();
          try { document.execCommand('copy'); done(); } catch (e) {}
          document.body.removeChild(ta);
        }
      });
    });
  }

  function initScrollExtras() {
    var bar = document.querySelector('.reading-progress span');
    var toTop = document.querySelector('.to-top');
    if (!bar && !toTop) return;
    if (toTop) toTop.hidden = false;

    var ticking = false;
    function update() {
      ticking = false;
      var doc = document.documentElement;
      var max = doc.scrollHeight - doc.clientHeight;
      var y = window.scrollY || doc.scrollTop;
      if (bar) {
        var pct = max > 0 ? (y / max) * 100 : 0;
        bar.style.width = pct.toFixed(2) + '%';
      }
      if (toTop) toTop.classList.toggle('visible', y > 500);
    }
    function onScroll() {
      if (!ticking) { ticking = true; requestAnimationFrame(update); }
    }
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll, { passive: true });
    update();

    if (toTop) {
      toTop.addEventListener('click', function () {
        var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' });
      });
    }
  }

  // Easter egg: the red "close" dot on the home window "shuts down" the machine.
  function initShutdown() {
    var dot = document.querySelector('.hero .window-bar .dot-close');
    if (!dot) return;
    dot.addEventListener('click', function () {
      window.alert('It is now safe to turn off your computer.');
      window.location.href = 'https://www.google.com';
    });
  }

  // Light / dark toggle. The mode is applied pre-paint by the inline script in
  // head.html; here we just wire the button and persist the choice.
  function initThemeToggle() {
    var btn = document.querySelector('.theme-toggle');
    if (!btn) return;
    var root = document.documentElement;
    var meta = document.querySelector('meta[name="theme-color"]');

    function sync() {
      var dark = root.getAttribute('data-theme') === 'dark';
      btn.setAttribute('aria-label', dark ? 'Switch to light theme' : 'Switch to dark theme');
      btn.setAttribute('aria-pressed', String(dark));
      if (meta) meta.setAttribute('content', dark ? '#1f201a' : '#f7f9fb');
    }
    sync();

    btn.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) {}
      sync();
    });
  }

  function init() {
    initCopyButtons();
    initScrollExtras();
    initShutdown();
    initThemeToggle();
  }

  if (document.readyState !== 'loading') {
    init();
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }
})();
