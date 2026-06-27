% Web-Exposure Application Documentation
% Nikolay Voynov
% June 2026

## Introduction

A minimalist, containerized static website engine and asset optimization pipeline built for photographic series.

Inspired by the cinematic, non-linear exhibition layouts of contemporary art photography, **exposure** acts as a silent digital passepartout canvas. It completely separates your raw production tools from the clean, static HTML deliverables deployed to GitHub Pages.

Initial intent of the project can be get in [Specification](/docs/SPEC.md)

---

## Features

*   **Dynamic Mosaic Canvas:** Shuffles all photos across all collections on every page visit, arranging them into an asymmetrical mosaic layout with contemplative, slow fade-in behavior and intentional negative space gaps.
*   **Editorial Magazine Grid:** Series layouts dynamically wrap around text commentary in a modern fluid layout, preserving original image geometry (3:2, 3:4, and vertical crops) natively without force-cropping or stretching.
*   **Artistic 4-Way Lightbox:** Features a progressive viewport engine that allows users to seamlessly switch background environments—from pure minimal photo paper edges on a gallery wall to full museum passepartout frame rendering with deep drop shadows.
*   **Smart Exif Importer:** Extracts EXIF data batch-wise using `exiftool`, converts raw source files (`.tif`) into high-performance web formats (`.webp`), and automatically creates localized thumbnail previews.
*   **Pandoc Header & Tag Parsing:** Directly extracts collection titles and custom metadata tagging keywords (e.g., `% tags: landscape, winter`) from standard Pandoc Markdown text files.
*   **Hidden Standalone Pools:** Allows directories starting with an underscore (e.g., `_singles/`) to remain hidden from the main listings, while their photos safely participate in the randomized homepage stream.

---

## Usage

### 1. Preparing the Source Directory

Organize your raw photographic master archives on your hard drive outside the repository scope using the following structure:

```text
source_photos/
├── almaznoe/
│   ├── README.md      # Pandoc Markdown config file
│   ├── frame_01.tif   # Master image assets
│   └── frame_02.tif
│
├── _singles/          # Directory starting with "_" remains hidden
│   ├── isolated_1.tif # Participates strictly in the home page pool
│   └── isolated_2.tif
```

The `README.md` file configuration should use the **Pandoc Markdown** metadata header standard:

```markdown
% Almaznoe
% tags: landscape, winter, melancholy, mist, Ukraine

This text will be rendered as the main editorial article column on the series page...
```

### 2. Setting Up the Container Environment

**web-exposure** is fully containerized to run safely inside a rootless **Podman** or Docker container, removing any requirement to manage local system runtimes.

1. Build the local secure container image:
   ```bash
   podman build -t web-exposure:latest .
   ```
2. Launch the orchestrator environment:
   ```bash
   podman compose up
   ```
   *On your initial execution, the pipeline will interactively prompt you for your absolute local `source_photos/` hard drive path, and securely save it in a `.gitignore`-protected `.env` and `local_config.yml` file for all subsequent sessions.*

### 3. Rake Command Reference

All routine deployment and management behaviors are managed via the `rake` suite inside the container workspace:

*   **`rake photo:import`**
    Synchronizes the external source photo tree. Automatically parses Pandoc metadata headers, extracts EXIF fields, processes raw `.tif` files into optimized FullHD `.webp` sheets and 600px preview thumbnails, and purges obsolete or deleted media assets.
*   **`rake site:serve`**
    Launches the local embedded development server. Mounts file watchers in real-time, hosting your layout preview locally at `http://localhost:4000`. This task runs by default on `podman compose up`.
*   **`rake site:clean`**
    Completely flushes all generated static files, Jekyll internal compiler caches, transient markdown compilation entries, and optimized WebP photo assets (`assets/gallery/*`). Run this command locally before making Git commits to ensure your `main` branch code tree remains absolutely pure and free from binary media artifacts.
*   **`rake site:deploy`**
    Compiles the dynamic code under a strict `production` environment (enabling live tracking pipelines like Google Analytics and valid XML sitemaps) and force-pushes the static artifact bundle straight into your isolated repository `gh-pages` branch on GitHub.

---

## Structure

The project repository structure


.
├── bin
│   └── console
├── CHANGELOG.md
├── docker-compose.yml
├── Dockerfile
├── docs
│   ├── assets (documentations assets)
│   │   ├── about_view.svg
│   │   ├── album_view.svg
│   │   ├── lightbox_view.svg
│   │   ├── main_layout.svg
│   │   ├── main_portfolio_view.svg
│   │   ├── series_view.svg
│   │   └── uikit_demo.svg
│   ├── SPEC.md (started software requirements specfication, mainly to fully expand the context of the project)
│   └── UI_UX_SPEC.md
├── Gemfile
├── Gemfile.lock
├── guides (preserves hlpful AI information)
│   ├── ALBUM_PRESENTATION_GUIDE.md
│   └── DESIGN-PRINCIPLES.md
├── HISTORY.md (contains the very first AI sessions log)
├── lib
│   ├── exposure
│   │   ├── adapters
│   │   │   ├── exif_tool_adapter.rb
│   │   │   └── image_magick_adapter.rb
│   │   ├── adapters.rb
│   │   ├── basic
│   │   │   └── time_extentions.rb
│   │   ├── basic.rb
│   │   ├── builder
│   │   │   ├── album.rb
│   │   │   ├── base.rb
│   │   │   └── user_album.rb
│   │   ├── builder.rb
│   │   ├── config.rb
│   │   ├── decorator
│   │   │   └── site_album.rb
│   │   ├── decorator.rb
│   │   ├── model
│   │   │   ├── album.rb
│   │   │   ├── base.rb
│   │   │   ├── description.rb
│   │   │   ├── gallery.rb
│   │   │   └── image.rb
│   │   ├── model.rb
│   │   ├── ports
│   │   │   ├── exif_metadata.rb
│   │   │   └── image_transformation.rb
│   │   ├── ports.rb
│   │   ├── presenter
│   │   │   ├── base.rb
│   │   │   ├── site_album.rb
│   │   │   └── user_album.rb
│   │   ├── presenter.rb
│   │   ├── tasks
│   │   │   ├── build_album.rb
│   │   │   ├── build_gallery.rb
│   │   │   ├── build_site_album.rb
│   │   │   └── build_site.rb
│   │   ├── tasks.rb
│   │   └── version.rb
│   └── exposure.rb
├── local_config.yml
├── Rakefile
├── rakelib
│   ├── gallery.rake
│   └── site.rake
├── README.md
├── resume-to-start.md
├── site
│   ├── about.md
│   ├── assets
│   │   ├── css
│   │   │   ├── main.scss
│   │   │   └── style.css
│   │   ├── gallery
│   │   └── presets
│   │       └── blank_holder.webp
│   ├── _config.yml
│   ├── _data
│   ├── _drafts
│   ├── favicon.svg
│   ├── focusing_screen.svg
│   ├── focusing_screen_tight.svg
│   ├── focus.svg
│   ├── _includes
│   │   ├── analytics.html
│   │   └── lightbox.html
│   ├── index.md
│   ├── _layouts
│   │   ├── default.html
│   │   └── series.html
│   ├── _posts
│   ├── robots.txt
│   ├── _sass
│   │   └── base.scss
│   ├── _series
│   │   ├── almaznoe.md
│   │   ├── bubbles.md
│   │   ├── svalovichi.md
│   │   └── vaseline.md
│   └── series.md
├── TODO.md (latest plans for the project advancement)


## Design

TODO: desing Architecture Design Document docs/ARCH.md and provide link

## Other techs

- Yard ruby documentation tool
- Jekyll and Github Pages
