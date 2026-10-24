// Enhance ordinary standalone links into accessible, in-place game tabs.
(() => {
  const root = document.querySelector('[data-game-tabs]');
  if (!root) return;
  const list = root.querySelector('[data-tablist]');
  const tabs = Array.from(list.querySelectorAll('[data-tab]'));
  const panels = Array.from(root.querySelectorAll('[data-panel]'));
  list.setAttribute('role', 'tablist');
  tabs.forEach((tab) => {
    tab.setAttribute('role', 'tab');
    tab.setAttribute('aria-controls', `panel-${tab.dataset.tab}`);
    tab.removeAttribute('aria-current');
  });
  panels.forEach((panel) => {
    panel.setAttribute('role', 'tabpanel');
    panel.setAttribute('aria-labelledby', `tab-${panel.dataset.panel}`);
    panel.tabIndex = 0;
  });

  function select(key, { focus = false, remember = false } = {}) {
    if (!tabs.some((tab) => tab.dataset.tab === key)) return;
    tabs.forEach((tab) => {
      const selected = tab.dataset.tab === key;
      tab.setAttribute('aria-selected', String(selected));
      tab.tabIndex = selected ? 0 : -1;
      if (selected && focus) tab.focus();
    });
    panels.forEach((panel) => { panel.hidden = panel.dataset.panel !== key; });
    // History updates keep the hero and viewport in place; no page navigation.
    if (remember && location.hash !== `#${key}`) {
      history.pushState(null, '', `#${key}`);
    }
  }

  function fromLocation() {
    let fragment;
    try { fragment = decodeURIComponent(location.hash.slice(1)); }
    catch { fragment = ''; }
    if (tabs.some((tab) => tab.dataset.tab === fragment)) {
      select(fragment);
      return;
    }
    // A direct policy-section hash opens its containing panel before scrolling.
    const target = fragment ? document.getElementById(fragment) : null;
    const panel = target && target.closest('[data-panel]');
    select(panel ? panel.dataset.panel : 'overview');
    if (panel && target !== panel) target.scrollIntoView();
  }

  tabs.forEach((tab, index) => {
    tab.addEventListener('click', (event) => {
      // Preserve open-in-new-tab and modified-click behavior for the real URLs.
      if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      select(tab.dataset.tab, { remember: true });
    });
    tab.addEventListener('keydown', (event) => {
      let next;
      if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
      else if (event.key === 'ArrowLeft') next = (index - 1 + tabs.length) % tabs.length;
      else if (event.key === 'Home') next = 0;
      else if (event.key === 'End') next = tabs.length - 1;
      else return;
      event.preventDefault();
      select(tabs[next].dataset.tab, { focus: true, remember: true });
    });
  });
  window.addEventListener('popstate', fromLocation);
  window.addEventListener('hashchange', fromLocation);
  fromLocation();
})();
