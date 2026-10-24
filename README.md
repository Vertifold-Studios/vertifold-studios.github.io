# Vertifold Studios

A responsive, static website for Vertifold Studios and its graph-inspired mobile games. The production files are committed at the repository root, ready for GitHub Pages. No npm packages, JavaScript runtime, database, or build service is required to serve the site.

## Pages

| Game | Overview | Social / download link | Support | Privacy policy |
| --- | --- | --- | --- | --- |
| Color Surge | `/color-surge.html` | `/color-surge-download.html` | `/color-surge-support.html` | `/color-surge-privacy.html` |
| Traffic Tangle | `/traffic-tangle.html` | `/traffic-tangle-download.html` | `/traffic-tangle-support.html` | `/traffic-tangle-privacy.html` |
| Cover Command | `/cover-command.html` | `/cover-command-download.html` | `/cover-command-support.html` | `/cover-command-privacy.html` |

The studio homepage is `/`. Shared support and privacy hubs are `/support.html` and `/privacy.html`. A custom `404.html`, sitemap, robots file, favicon, and social sharing image are included.

Color Surge links directly to its published [App Store](https://apps.apple.com/app/id6757683749) and [Google Play](https://play.google.com/store/apps/details?id=com.jordanturley.colorsurge) listings. The other games clearly show **In development**; no speculative download or preorder links are included. Cover Command’s description presents its intended concept, rather than claiming its copied Traffic Tangle mechanics are a finished product. Graph artwork is an illustration, not a screenshot.

## Theme and logo

The site uses a dark navy palette with blue, cyan, and violet accents, inspired by the earlier Vertex Gaming websites. The header and favicon use a transparent cutout of the connected-node mark from the supplied `vertifold.png`; the original image is preserved.

PNG icons are included at 16, 32, 48, 192, and 512 pixels, plus a 180-pixel Apple touch icon. The root `favicon.ico` bundles the 16/32/48-pixel crops. All pages reference the new icons, including the nested-path 404 page.

The transparent master is `assets/logo-transparent.png`. To regenerate the icon sizes on macOS, run `swift scripts/favicon.swift` from the repository root, then `python3 scripts/build.py` to regenerate the ICO and pages. PNG and ICO icons preserve transparency; no dark background is added.

## Edit and preview

Shared templates, copy, store links, privacy text, support email, dates, and game details are in `scripts/build.py`. Layout and responsive styling are in `assets/site.css`. Generated HTML is checked in for GitHub Pages; edit the generator and regenerate so later builds preserve changes.

```sh
python3 scripts/build.py
python3 scripts/check.py
# Optional macOS JavaScript behavior check:
swift scripts/check-tabs.swift
python3 -m http.server 8000
```

Open `http://localhost:8000` to preview. Check narrow and wide screens, keyboard navigation, expanded FAQs, mail links, download pages, and a missing URL before launch. The automated check validates static navigation and metadata; it is not a browser or accessibility audit.

Game overview pages use a small local script for accessible in-place Overview, Download, Support, and Privacy policy tabs. Arrow keys, Home/End, and browser Back/Forward are supported. Each additional panel links to its standalone page, and hero download buttons remain direct links. Without JavaScript, the same navigation links open the standalone pages normally. The standalone download, support, and privacy pages render without JavaScript. Assets and fonts are served locally, there are no trackers or forms, and reduced-motion preferences disable the decorative graph animation. The site uses system fonts.

`assets/social-card.png` is a committed 1200 × 630 social preview. Its optional macOS source is `scripts/social-card.swift`; regenerate with:

```sh
swift scripts/social-card.swift assets/social-card.png
```

## Publish on GitHub Pages

1. Commit and push these files to the repository’s default branch.
2. In GitHub **Settings → Pages**, select **Deploy from a branch**, the default branch, and **/(root)**. There is no required Actions workflow. `.nojekyll` lets Pages serve the files directly.
3. Configure and, preferably, verify `vertifold.studio` in the organization’s Pages settings. The committed `CNAME` contains `vertifold.studio` and the canonical/social URLs use that domain.
4. At the DNS provider, follow [GitHub’s custom-domain instructions](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site). An apex ALIAS/ANAME record may target `vertifold-studios.github.io`; alternatively use the current GitHub Pages A records documented there. Add an optional `www` CNAME to `vertifold-studios.github.io`. Keep unrelated email records intact.
5. Once DNS and the certificate are ready, enable **Enforce HTTPS** in Pages settings and check the live URLs.

Files have been prepared locally. Creating `CNAME` does not itself configure DNS, GitHub Pages settings, or HTTPS. To use only the `github.io` address, remove `CNAME` and change `SITE` in `scripts/build.py`, then regenerate.

## Publishing and privacy handoff

The policies were drafted from the app source and the official guidance linked below. They include developer identity, contact information, local saves and backups, advertising SDK data, sharing, retention, deletion and consent withdrawal, children’s privacy, and policy updates. These website pages alone do **not** implement app consent, change store disclosures, or guarantee approval.

Before using the pages in app submissions:

- **Contact:** The site uses `ztizzlegaming@gmail.com`, the existing public Color Surge support address. Confirm that this is the address to use for all three games, or change `EMAIL` in `scripts/build.py` and regenerate. No unverified domain mailbox was invented.
- **Operator and retention:** Confirm the public identity “Jordan Turley, operating as Vertifold Studios” and the proposed policy of deleting support correspondence within 12 months after resolution (subject to earlier requests, legal retention, or disputes). Follow the retention policy operationally. Change it before publication if this does not match your practice.
- **Actual release behavior:** Verify the policy against each shipping binary, SDK version, any mediation partners, advertising configuration, target audience, and territories. Traffic Tangle and Cover Command policies identify their development status; review them again for release. Cover Command currently has no iOS build.
- **In-app links:** Replace the old `ztizzle.com` / `vertexgaming.org` privacy links in the app projects with the corresponding `https://vertifold.studio/<game>-privacy.html` URL. Include accessible support and privacy links in the apps. The game repositories have not been changed by this website work. In particular, the existing `<game>.html` path is now the overview; the explicit `-privacy.html` URL is the policy.
- **Store metadata:** Set each app’s marketing URL to its overview page, Support URL to its support page, and Privacy Policy URL to its privacy page. The dedicated download URL is for Instagram, social bios, QR codes, and other promotional links. Make all URLs public over HTTPS before submitting.
- **Disclosures:** Review App Store Connect App Privacy and Google Play Data safety answers for the exact SDK configuration. Advertising SDK collection counts even when gameplay saves remain on the device. Do not declare “no data collected” just because there is no studio backend.
- **Consent:** The inspected iOS projects contain ATT permission code. No UMP consent flow or regional privacy-options entry point was found in the supplied app source. Evaluate and implement the required regional ad consent/withdrawal controls before distribution where needed; ATT and the website policy are not substitutes. The public policies describe existing device/provider controls and do not claim an in-app consent screen already exists.
- **Children:** Confirm the intended audience, content rating, child-directed treatment, and advertising configuration. “General audience” wording is not a substitute for Google Families or Apple Kids Category requirements if those apply.
- **Advertising:** Replace sample ad-unit IDs before monetizing the upcoming games. If AdMob requests `app-ads.txt`, copy the exact authorized-seller snippet from your AdMob account to a root `app-ads.txt` and use the studio domain as the developer website. No seller authorization was guessed.

There are no player accounts, so the policies explain removal of local data, backups, correspondence, and provider-held data separately. They do not invent an account deletion system. If accounts are added, implement the relevant in-app and web deletion processes and update the policies.

## Reference material

Checked October 24, 2026:

- [Apple App Review Guidelines, including support and privacy requirements](https://developer.apple.com/app-store/review/guidelines/)
- [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Google Mobile Ads Android data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
- [Google Mobile Ads iOS data disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure)
- [Google Privacy Policy](https://policies.google.com/privacy)
- [GitHub General Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement)
