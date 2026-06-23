% Project Development History: Web-Exposure
% Nikolay Voynov
% June 2026

## Introduction

This document tracks the architectural progression, design milestones, and engineering iterations of the **web-exposure** project from its initial conception to a fully automated, containerized art platform.

---

## Session 1: The Core Foundation & Media Pipeline

### Objectives

*   Establish a lightweight, static alternative to heavy CMS engines for a private photo archive.
*   Solve the master asset transformation problem (converting huge `.tif` files into high-performance web formats while preserving metadata).
*   Formulate a dynamic layout framework representing the aesthetics of contemporary art photography.

### Engineering & Architecture Milestones

1.  **Jekyll Ecosystem Choice:** Selected Jekyll as a fast, secure static engine that compiles raw templates directly into raw HTML/CSS without dependencies on backend databases.
2.  **Ruby Automation Blueprint:** Wrote the initial procedural script to synchronize directories. Implemented automated invocation of `imagemagick` to export master assets into two targeted WebP sheets: sharp FullHD targets for large displays (`quality: 82`) and lightweight 600px grids for card previews (`quality: 75`).
3.  **Batch EXIF Extraction:** Implemented a high-speed batch execution method using `exiftool` to scrape timestamps (`DateTimeOriginal`), titles, and captions straight out of binary TIFF arrays into structured metadata.
4.  **The Cinematic Canvas (HidoZero):** Built the initial prototype of the homepage. Designed a strict bounding grid workspace (`100vh`) with disabled page scrolling. Implemented a JavaScript layout driver that shuffles photos on every visit and distributes them into asymmetrical structural grid sizes (`normal`, `wide`, `tall`, `large`), mirroring Todd Hido's physical workspace print spreads.
5.  **Sequential Proving Effect:** Injected a delayed execution transition interval (300ms) to trigger opacity scales. Upon entry, photos slowly "emerge" top-to-bottom onto an off-white canvas, replicating analog paper immersion in chemistry.

---

## Session 2: Modular Engineering, Containerization & Layout Tuning

### Objectives

*   Transition from a procedural script structure to an advanced engineering workspace.
*   Resolve structural bugs and grid holes on editorial album layers.
*   Isolate code dependencies from the local host OS.

### Engineering & Architecture Milestones

1.  **The Airy Canvas Optimization:** Tuned the homepage layout driver weights to favor delicate normal and vertical frames. Injected invisible layout placeholders (`spacer`), creating deliberate negative spaces and empty gaps to let the random photo clusters breathe.
2.  **Editorial Flow Evolution (The Search for the Grid):**
    *   *Grid Approach:* Failed due to rigid row-span boundaries creating massive blank holes when editorial commentary text grew too large.
    *   *Flexbox Approach:* Failed because horizontal constraints caused images to stretch vertically, distorting pristine 3:2 frame geometry.
    *   *Column & Float Approach:* Finalized a fluid, flowing editorial block layout using a calibrated `float: left` and negative horizontal layout margin padding. Photos now read sequentially from **left to right** in a strict chronological sequence, beautifully wrapping underneath the text column without an elite single pixel of blank space.
3.  **Project Root Purification:** Completely separated infrastructure from presentation. Moved all Jekyll system files, configurations, and themes into an isolated `site/` subdirectory.
4.  **Rake Library Automation Framework (`rakelib/`):** Abandoned scattered script files. Restructured code tasks across formal modular files inside `rakelib/`: `photo.rake` for data ingesting and `site.rake` for local server and deployment management.
5.  **Podman/Docker Containerization:** Created a secure `Dockerfile` and `docker-compose.yml` stack to packetize Ruby 3.2-slim, Imagemagick, Vips, and ExifTool. Resolved container network routing limitations by forcing binding to `--host 0.0.0.0`. Implemented a `.env` interactive pipeline cache that automatically prompts for the local master disk path once and locks it silently.

---

## Session 3: Fine-Art Presentation, Data Sovereignty & Deployment Core

### Objectives

*   Unify naming schemas and data models under a dedicated vocabulary.
*   Implement advanced fine-art presentation framing rules inside pliant lightboxes.
*   Enforce SEO standards, data privacy, and separate release-artifact git streams.

### Engineering & Architecture Milestones

1.  **The Series Transition:** Replaced all administrative references to "collections" and "albums" with the professional art term **`series`** across all internal Ruby configurations, liquid templates, and file tree scopes (`_series/`).
2.  **Pandoc Header Syntax Parser:** Advanced the Ruby engine to parse Pandoc Markdown conventions. The script now reads lines starting with `%` as safe titles, silently filters out author/date meta blocks, and injects individual tag keys (`% tags: ...`) into the Jekyll runtime model.
3.  **Hidden Standalone Pools:** Implemented a system where directories prefixed with an underscore (e.g., `_singles/`) remain omitted from public list directories but seamlessly feed individual snapshots into the homepage random mosaic.
4.  **Shared Multi-Environment Lightbox:** Abstracted the distinct duplicate lightbox elements into a single shared file (`site/_includes/lightbox.html`), leveraging `window.openLightboxWithIndex` hooks to safely exchange arrays. Fixed browser inline text element vertical font alignment bugs by switching container frameworks to Flexbox.
5.  **Persistent Storage Session States:** Tied background toggles to native browser `localStorage`. Chosen environments now stick consistently across different browser tabs, series views, and future return visits.
6.  **The 4-Way Art Frame Design:** Designed a fully scaling 3D matte presentation frame system relying on relative viewport units (`vw`).
    *   *Classic Mode (Default):* Pure minimal layout. The print is presented on a clean white board with equal 1.5vw borders on all sides, floating over a mid-grey wall with deep ambient shadows.
    *   *Museum Mode:* Adds a thick solid wood profile, wide mat boards, and a crisp 2px core beveled cut highlight.
    *   *Light & Dark Rooms:* Soft linen/ivory pastel setups for day viewing, and high-contrast glowing white mats against midnight blue velvet backgrounds to prevent eye strain at night.
7.  **SEO, Analytics & Pure Git Deployment:** Installed `jekyll-sitemap` and `jekyll-seo-tag`. Hardened tracking privacy by wrapping Google Analytics inside conditional production flags (`JEKYLL_ENV == "production"`). Wrote a secure `site:clean` task to wipe media caches, ensuring the `main` branch holds code only, while the `site:deploy` pipeline builds a separate Git instance to force-push flat static web files directly onto the GitHub Pages `gh-pages` branch.

---

## Session 4: Global UX Polish, Blind Debossing Design & Launch Production

### Objectives

*   Abstract duplication and centralize configurations for data privacy.
*   Resolve multi-device responsive bugs and layout geometry issues.
*   Implement automatic repository security defenses and push the application live.

### Engineering & Architecture Milestones

1.  **Shared State Synchronization:** Refactored the core script arrays. The homepage template now dynamically extracts individual photo footprints from the hidden JSON catalog, computes full resolution parent addresses, and safely forces the lightbox to browse through the entire *original parent series collection timeline* instead of just cycling through the random home wall assets.
2.  **Impeccable Floating Geometry:** Fixed cross-browser `inline-block` vertical font rendering bugs (ghost space) inside the `Classic` lightbox by aggressively converting the inner presentation layers to an active `Flexbox` matrix. Re-calibrated the editorial float math inside `series.html` down to precise percentage budgets (`31.333%` and `3%` gap margins) combined with a horizontal track container wrap. Photos now line up cleanly from **left to right** and fold underneath text with seamless fluid continuity.
3.  **Contrast & Typography Upgrade:** Proportions were adjusted to elevate legibility on calibrated monitors. Brand identity text moved to absolute high-contrast deep black (`#000000`), while the main navigation items were raised to a sharp charcoal tint (`#444444`).
4.  **Blind Debossing Artist Statement:** Completely rebuilt `about.md` to use clean Kramdown Markdown structures without embedded code. Abstracted a hand-drawn vector SVG sketch layout directly into the system template engine. The non-linear blueprint frame is rotated at `-3.5deg` to simulate hanging from a single wire, serving as a subtle watermark layered underneath the text layout.
5.  **Global Identity Isolation:** Centralized the author's name, geographical location, and email contact links into global `site.*` variables inside `_config.yml`, protecting layout templates from static text duplication.
6.  **Git Pre-Commit Security Defense:** Wrote an automated shell hook script inside `.git/hooks/pre-commit` backed by execution rights (`chmod +x`). The system intercepts code commitments to the `main` branch and runs `rake site:clean` ahead of sequence, ensuring un-optimized images, cache stacks, or temporary metadata can never leak into the repository.
7.  **Production Release Execution:** Shifted local repositories over secure SSH protocol anchors (`git@github.com`). Successfully compiled the final deployment bundle under production spec environments and force-pushes it live onto the `gh-pages` tracking node. The photo archive is live, sitemaps are verified, and independent custom Google Analytics streaming metrics are active.

---

## Session 5: Deep Linking Infrastructure, Data Isolation & Conceptual Placeholders

### Objectives

*   Implement persistent, granular deep-linking URL schemes for individual photographs.
*   Mitigate layout broken states caused by low-asset count thresholds in short series.
*   Refine data privacy parameters and fix cross-browser routing asset collisions.

### Engineering & Architecture Milestones

1.  **Granular Hash Routing Architecture:** Designed a comprehensive inbound and outbound URL interception matrix using native browser `history.replaceState` and `window.location.hash` pipelines. The application now encodes individual filename anchors into the URL string (e.g., `#frame_03`) smoothly during routine gallery browsing without page refreshes.
2.  **Autonomous Cross-Context Share Generator:** Resolved an architectural routing conflict between the dynamic home mosaic stream and strict collection page layouts. The common lightbox toolbar now intercepts sharing calls (`copy-link-btn`). If triggered from the randomized homepage stream, it programmatically computes the canonical origin, maps the underlying JSON ledger, and bakes an absolute direct pointer to the item's original source series node. Closing the player silently restores the baseline clean page path state.
3.  **Conceptual Stacking Placeholders:** Built a secure mechanism to defend the cloud-cloud canvas layout from short-series asset starvation. Developed an offline preset generation routine using direct TrueType binary mappings in ImageMagick (`DejaVu-Sans.ttf`) to bake a minimalist fine-art sheet named `blank_holder.webp` displaying the centered text *Awaiting Light*. The Ruby script now runs a padding loop to dynamically stuff arrays up to a strict 5-item threshold using this conceptual canvas if the source folder holds fewer than 5 files.
4.  **Cross-Browser Absolute Anchors:** Overrode localized browser vector parsing bugs (the Firefox/Tor gray globe error) by switching favicon hooks from technical relative paths to strict absolute URL pipelines (`| absolute_url`) compiled out of the base domain config.
5.  **Clean Functional Sorting Reconstruct:** Completely eliminated unsafe, volatile in-place mutating arrays (`sort_by!`) inside `rakelib/photo.rake`. Re-engineered the media catalog tracking tree using an immutable functional sequence handler (`sort_by`) driven by EXIF timestamps (`DateTimeOriginal`) or explicit system creation fallbacks (`File.mtime`), securing clean left-to-right chronological reading layers.

## - 2026-06-23

### Added
- Integrated full Hexagonal (Ports & Adapters) and Clean Architecture core layers.
- Introduced `Exposure::Model::Base` implementing reflection API, immutable value 
  object boundaries, and deep structural data tree serialization.
- Introduced `Exposure::Builder::Album` and `Exposure::Builder::UserAlbum` 
  standalone object aggregators utilizing modern Ruby 3.4 `it` block syntax.
- Introduced `Exposure::Presenter::UserAlbum` for compiling pristine, minimalist 
  human-readable metadata flat ledgers without structural Symbol points.
- Introduced `Exposure::Presenter::SiteAlbum` combined with the `SiteAlbum` 
  Decorator model layer to isolate and synthesize release monolithic Jekyll pages.
- Created `rakelib/gallery.rake` containing the isolated clean `:gallery` namespace 
  with a fail-fast OS binaries validation check hook stream.
- Implemented an interactive terminal Setup Wizard for configuring and caching 
  baseline file locations into an immutable `Exposure::ConfigData` instance.

### Changed
- Shifted the entire engine from loose procedural scripts to a decoupled, 
  highly testable, immutable Domain-Driven pipeline architecture.
- Refactored `Exposure::Config` into a thread-safe proxy Singleton delegating 
  parameters directly onto freeze-protected value objects.
- Normalized image timestamps processing to rely exclusively on strict web 
  standards via `DateTime.strptime` and `Time.iso8601` with time-zones retention.
- Re-aligned the main web header layout container layout to follow a minimalist, 
  axial museum-style central composition context.

### Removed
- Fully deleted the legacy monolithic procedural script `rakelib/photo.rake`.
- Discarded duplicate text-generation variables from Use Case interactors.

