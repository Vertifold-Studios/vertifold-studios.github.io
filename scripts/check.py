#!/usr/bin/env python3
"""Check generated pages and local navigation without external dependencies."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import json
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links, self.errors, self.tags = [], [], []
        self.ids = set()
        self.h1 = self.title_count = self.main_count = 0
        self.description = self.viewport = self.canonical = False
        self.script_type = None
        self.schema = ''

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        self.tags.append((tag, a))
        if 'id' in a:
            if a['id'] in self.ids:
                self.errors.append('duplicate ID: ' + a['id'])
            self.ids.add(a['id'])
        self.h1 += tag == 'h1'
        self.title_count += tag == 'title'
        self.main_count += tag == 'main'
        self.description |= tag == 'meta' and a.get('name') == 'description' and bool(a.get('content'))
        self.viewport |= tag == 'meta' and a.get('name') == 'viewport'
        self.canonical |= tag == 'link' and a.get('rel') == 'canonical'
        if tag == 'img' and 'alt' not in a:
            self.errors.append('image missing alt attribute')
        if tag == 'script':
            self.script_type = a.get('type')
            if self.script_type != 'application/ld+json' and not (a.get('src') == 'assets/game-tabs.js' and 'defer' in a and not self.script_type):
                self.errors.append('unexpected executable or external script')
        for key in ('href', 'src'):
            if key in a:
                self.links.append(a[key])

    def handle_data(self, data):
        if self.script_type == 'application/ld+json':
            self.schema += data

    def handle_endtag(self, tag):
        if tag == 'script':
            self.script_type = None


def check():
    parsed = {}
    for file in sorted(ROOT.glob('*.html')):
        doc = Page()
        doc.feed(file.read_text(encoding='utf-8'))
        parsed[file.name] = doc
    errors = []
    for filename, doc in parsed.items():
        errors.extend(filename + ': ' + error for error in doc.errors)
        for count, label in [(doc.h1, 'h1'), (doc.title_count, 'title'), (doc.main_count, 'main')]:
            if count != 1:
                errors.append(f'{filename}: expected one {label}, found {count}')
        if not all([doc.description, doc.viewport, doc.canonical]):
            errors.append(filename + ': missing page metadata')
        if doc.schema:
            json.loads(doc.schema)
        for link in doc.links:
            url = urlsplit(link)
            if url.scheme or url.netloc:
                continue
            target_name = unquote(url.path).lstrip('/') if url.path else filename
            if not target_name:
                target_name = 'index.html'
            target = ROOT / target_name
            if not target.exists():
                errors.append(filename + ': missing local target ' + link)
            if url.fragment and target_name in parsed and url.fragment not in parsed[target_name].ids:
                errors.append(filename + ': missing fragment ' + link)
    for game in ('color-surge', 'traffic-tangle', 'cover-command'):
        for suffix in ('', '-download', '-support', '-privacy'):
            if game + suffix + '.html' not in parsed:
                errors.append('Missing required game page: ' + game + suffix)
        overview = parsed[game + '.html']
        tab_links = {attrs['data-tab']: attrs for tag, attrs in overview.tags if 'data-tab' in attrs}
        panels = {attrs['data-panel']: attrs for tag, attrs in overview.tags if 'data-panel' in attrs}
        expected = {'overview': '', 'download': '-download', 'support': '-support', 'privacy': '-privacy'}
        if set(tab_links) != set(expected) or set(panels) != set(expected):
            errors.append(game + ': missing tab links or panels')
        else:
            for key, suffix in expected.items():
                if tab_links[key].get('href') != game + suffix + '.html':
                    errors.append(game + ': tab fallback URL is incorrect: ' + key)
                if ('hidden' in panels[key]) != (key != 'overview'):
                    errors.append(game + ': incorrect initial panel visibility: ' + key)
            for key in ('download', 'support', 'privacy'):
                if not any(tag == 'a' and attrs.get('class') == 'button' and attrs.get('href') == game + '-' + key + '.html' for tag, attrs in overview.tags):
                    errors.append(game + ': missing standalone page button: ' + key)
        if not any(tag == 'script' and attrs.get('src') == 'assets/game-tabs.js' for tag, attrs in overview.tags):
            errors.append(game + ': tab enhancement script missing')
        download = (ROOT / (game + '-download.html')).read_text()
        if game == 'color-surge':
            for store in ('https://apps.apple.com/app/id6757683749', 'https://play.google.com/store/apps/details?id=com.jordanturley.colorsurge'):
                if store not in download:
                    errors.append('Missing official Color Surge store link')
        elif 'class="store-button"' in download or 'In development' not in download:
            errors.append('Unreleased game has incorrect download status: ' + game)
    if (ROOT / 'CNAME').read_text().strip() != 'vertifold.studio':
        errors.append('Unexpected custom domain')
    for name, size in [('favicon-16.png', 16), ('favicon-32.png', 32), ('favicon-48.png', 48), ('favicon-192.png', 192), ('favicon-512.png', 512), ('apple-touch-icon.png', 180)]:
        data = (ROOT / 'assets' / name).read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', data[16:24]) != (size, size):
            errors.append('Invalid icon size: ' + name)
    if (ROOT / 'favicon.ico').read_bytes()[:6] != struct.pack('<HHH', 0, 1, 3):
        errors.append('Invalid ICO favicon directory')
    png = (ROOT / 'assets/social-card.png').read_bytes()
    if png[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', png[16:24]) != (1200, 630):
        errors.append('Social preview must be a 1200 × 630 PNG')
    sitemap = ET.parse(ROOT / 'sitemap.xml')
    ns = {'s': 'http://www.sitemaps.org/schemas/sitemap/0.9'}
    urls = [x.text for x in sitemap.findall('.//s:loc', ns)]
    if len(urls) != len(parsed) - 1:
        errors.append('Sitemap should include every page except 404')
    for url in urls:
        name = urlsplit(url).path.lstrip('/') or 'index.html'
        if name not in parsed:
            errors.append('Invalid sitemap page: ' + url)
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'PASS: {len(parsed)} pages; {sum(len(p.links) for p in parsed.values())} references checked.')
    print('Local targets, fragments, unique IDs, headings, metadata, image alt text, release status, store links, social image, and sitemap verified.')

if __name__ == '__main__':
    check()
