(function () {
  function patch() {
    const avatar = document.querySelector('button[data-slot="dropdown-menu-trigger"] [data-slot="avatar"]');
    if (!avatar) return false;
    const avatarContainer = avatar.closest('button[data-slot="dropdown-menu-trigger"]')?.closest('.hidden.md\\:block');

    const moreBtn = document.querySelector('button[aria-label="More actions"]');
    const moreContainer = moreBtn?.closest('.hidden.md\\:block, .hidden.shrink-0.md\\:block');

    if (avatarContainer && moreContainer && moreContainer !== avatarContainer) {
      moreContainer.parentNode.replaceChild(avatarContainer, moreContainer);
    }

    var nav = document.querySelector('nav');
    if (nav && !nav.hasAttribute('data-webview-drag')) {
      nav.setAttribute('data-webview-drag', '');
    }

    return !!(nav && !moreContainer);
  }

  var style = document.createElement('style');
  style.textContent = `[data-radix-popper-content-wrapper]:has([data-slot="avatar-image"]) { 
    right: 8px !important; 
    left: auto !important; 
    transform: none !important; 
    top: 38px !important; 
  }
  
  div.md\\:flex:has(> a[href="/inbox"]) { 
    margin-left: 75px !important;
  }
  
  nav { 
    -webkit-user-select: none !important;
    padding-inline: calc(var(--spacing) * 1) !important; 
    padding-bottom: calc(var(--spacing) * 1.5) !important;
    -webkit-app-region: drag;
  }
  
  nav a, nav button { 
    -webkit-app-region: no-drag; 
  }
  
  .bg-card.rounded-xl.border { 
    border-radius: calc(var(--radius) - 1px) !important; 
  }
  
  nav a[data-slot="button"],
  nav a[draggable="true"] { 
    border-radius: calc(var(--radius) - 3px) !important; 
    height: calc(var(--spacing) * 6.5) !important; 
    font-size: 12px !important; 
  }
  
  button[data-slot="dropdown-menu-trigger"]:has([data-slot="avatar"]) { 
    outline-style: none !important; 
    -webkit-user-select: none !important;
    width: 24px !important;
    height: 24px !important;
    margin-right: 6px !important;
  }
  
  button[data-slot="dropdown-menu-trigger"] [data-slot="avatar"] {
    width: 24px !important;
    height: 24px !important;
  }`;

  document.documentElement.appendChild(style);

  new MutationObserver(function () {
    var input = document.querySelector('[cmdk-input]');
    if (input && !input.__webview_hooked) {
      input.__webview_hooked = true;
      input.addEventListener(
        'keydown',
        function (e) {
          if (e.key !== 'Enter') return;
          var val = input.value.trim();
          if (/^[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_.-]+$/.test(val)) {
            e.preventDefault();
            e.stopImmediatePropagation();
            document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
            history.pushState(null, '', '/' + val);
            window.dispatchEvent(new PopStateEvent('popstate'));
          }
        },
        true
      );
    }
  }).observe(document.documentElement, { childList: true, subtree: true });

  document.addEventListener(
    'keydown',
    function (e) {
      if ((e.metaKey || e.ctrlKey) && e.key === 'w') {
        e.preventDefault();
        document.dispatchEvent(new KeyboardEvent('keydown', { key: 'W', shiftKey: true, bubbles: true }));
      }
    },
    true
  );

  var target = document.documentElement;
  var config = { childList: true, subtree: true };

  var obs = new MutationObserver(function () {
    obs.disconnect();
    patch();
    obs.observe(target, config);
  });

  obs.observe(target, config);
})();
