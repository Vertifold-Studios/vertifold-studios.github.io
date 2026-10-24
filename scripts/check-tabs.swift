// Run the real tab script against a minimal DOM model to exercise interactions.
// macOS: swift scripts/check-tabs.swift
import Foundation
import JavaScriptCore
let context = JSContext()!
var failed = false
context.exceptionHandler = { _, exception in
    failed = true
    print("FAIL:", exception?.toString() ?? "JavaScript exception")
}
context.evaluateScript("""
const keys = ['overview', 'download', 'support', 'privacy'];
function element(dataset) {
  return { dataset, attrs: {}, handlers: {}, hidden: false, tabIndex: 0,
    setAttribute(k, v) { this.attrs[k] = v; },
    removeAttribute(k) { delete this.attrs[k]; },
    addEventListener(k, fn) { this.handlers[k] = fn; },
    focus() { this.focused = true; }
  };
}
const testTabs = keys.map(key => element({ tab: key }));
const testPanels = keys.map(key => element({ panel: key }));
const list = element({});
list.querySelectorAll = () => testTabs;
const root = { querySelector: () => list, querySelectorAll: () => testPanels };
const section = { closest: () => testPanels[3], scrollIntoView() { this.scrolled = true; } };
var document = { querySelector: () => root, getElementById: id => id === 'choices' ? section : null };
var location = { hash: '' };
var history = { entries: [], pushState(a, b, hash) { this.entries.push(hash); location.hash = hash; } };
var window = { handlers: {}, addEventListener(k, fn) { this.handlers[k] = fn; } };
function assert(value, message) { if (!value) throw new Error(message); }
function selected(key) {
  keys.forEach((k, i) => {
    assert(testTabs[i].attrs['aria-selected'] === String(k === key), 'ARIA selection: ' + k);
    assert(testTabs[i].tabIndex === (k === key ? 0 : -1), 'Roving focus: ' + k);
    assert(testPanels[i].hidden === (k !== key), 'Panel visibility: ' + k);
  });
}
function event(extra) {
  return Object.assign({ button: 0, preventDefault() { this.prevented = true; } }, extra);
}
""")
let source = try String(contentsOfFile: "assets/game-tabs.js", encoding: .utf8)
context.evaluateScript(source)
context.evaluateScript("""
selected('overview');
assert(list.attrs.role === 'tablist', 'Tablist role');
testTabs.forEach((tab, i) => {
  assert(tab.attrs.role === 'tab', 'Tab role');
  assert(tab.attrs['aria-controls'] === 'panel-' + keys[i], 'Panel relationship');
  assert(testPanels[i].attrs['aria-labelledby'] === 'tab-' + keys[i], 'Label relationship');
});
keys.forEach((key, index) => {
  const click = event({});
  testTabs[index].handlers.click(click);
  assert(click.prevented, 'Click must avoid page navigation');
  selected(key);
  assert(location.hash === '#' + key, 'Selection should be reflected in the URL');
});
const modified = event({ ctrlKey: true });
testTabs[1].handlers.click(modified);
assert(!modified.prevented, 'Modified clicks retain standalone-link behavior');
selected('privacy');
const right = event({ key: 'ArrowRight' });
testTabs[3].handlers.keydown(right);
selected('overview');
assert(right.prevented && testTabs[0].focused, 'Arrow wraps and moves focus');
testTabs[0].handlers.keydown(event({ key: 'ArrowLeft' }));
selected('privacy');
testTabs[3].handlers.keydown(event({ key: 'Home' }));
selected('overview');
testTabs[0].handlers.keydown(event({ key: 'End' }));
selected('privacy');
location.hash = '#support';
window.handlers.popstate();
selected('support');
location.hash = '#choices';
window.handlers.hashchange();
selected('privacy');
assert(section.scrolled, 'Policy anchors reveal their containing panel');
location.hash = '#%invalid';
window.handlers.hashchange();
selected('overview');
""")
if failed { exit(1) }
print("PASS: tab selection, visibility, ARIA, direct links, keyboard navigation, history, and policy anchors.")
