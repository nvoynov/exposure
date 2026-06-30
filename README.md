% Personal Exposure
% Nikolay Voynov
% June 2026

## Introduction

This project is a personal, independent initiative designed with a **"zero-cost, zero-maintenance"** philosophy. 

* **The Purpose:** It serves as a sustainable, dedicated digital home and a single "source of truth" to showcase a curated portfolio of an amateur photographer without any ongoing financial overhead.
* **Zero Infrastructure Cost:** The architecture relies entirely on static deployment (hosted for free via GitHub Pages). There are no databases, no server-side processing, and no hidden subscriptions.
* **Designed for Efficiency:** To stay safely within GitHub's free tier limits (100 GB monthly bandwidth), the gallery is optimized for a strict scale—hosting a maximum of 200–300 curated works. 
* **Asset Optimization:** All images are carefully compressed to the WebP format, capped at 1080px on the short side, maintaining an optimal balance between visual quality (averaging ~600 KB per full image) and performance.

If you are looking to reuse or contribute to this code, please keep this minimalist, ultra-lean approach in mind. It is built to be lightweight, simple, and financially free.

- **Capacity Summary:** Preliminary calculations indicate that under this approach, the website can seamlessly serve around 7,500 visitors per month (averaging 250 daily users viewing ~20 high-quality photos per session) while staying safely within GitHub Pages' free tier limits. Applying Client-Side Caching and assuming a healthy mix of 40% new and 60% returning traffic, the effective capacity scales to **15,000–20,000 sessions per month**, safely below the threshold.

Initial intent of the project can be get in [Specification](/docs/SPEC.md)

---

## Usage

### 1. Preparing the Source Directory

Organize your raw photographic master archives on your hard drive outside the repository scope using the following structure:

```text
source_photos/
├── ablum/
│   ├── frame_01.tif   # Master image assets
│   └── frame_02.tif
│
├── another/           
│   ├── frame_01.tif 
│   └── frame_02.tif
```

### 2. Preparing Container Environment

**Exposure** is fully containerized to run safely inside a rootless **Podman** or Docker container, removing any requirement to manage local system runtimes.

1. Build the local secure container image:
   ```bash
   podman build -t web-exposure:latest .
   ```
2. Launch the orchestrator environment:
   ```bash
   podman compose up
   ```
   *On your initial execution, the pipeline will interactively prompt you for your absolute local `source_photos/` hard drive path, and securely save it in a `.gitignore`-protected `.env` and `local_config.yml` file for all subsequent sessions.*

### 3. Rake Command Interface

All routine deployment and management behaviors are managed via the `rake` suite inside the container workspace:

*   **`rake gallery:import`**
    Synchronizes the external source photo tree. Automatically parses Pandoc metadata headers, extracts EXIF fields, processes raw `.tif` files into optimized FullHD `.webp` sheets and 600px preview thumbnails, and purges obsolete or deleted media assets.
*   **`rake site:serve`**
    Launches the local embedded development server. Mounts file watchers in real-time, hosting your layout preview locally at `http://localhost:4000`. This task runs by default on `podman compose up`.
*   **`rake site:clean`**
    Completely flushes all generated static files, Jekyll internal compiler caches, transient markdown compilation entries, and optimized WebP photo assets (`assets/gallery/*`). Run this command locally before making Git commits to ensure your `main` branch code tree remains absolutely pure and free from binary media artifacts.
*   **`rake site:deploy`**
    Compiles the dynamic code under a strict `production` environment (enabling live tracking pipelines like Google Analytics and valid XML sitemaps) and force-pushes the static artifact bundle straight into your isolated repository `gh-pages` branch on GitHub.

---

### 4. Photo describing routine

TODO: present here the work for describing albums and providing image metadata (ALBUM.md, ALBUM.yml)

## Structure

TODO: epxlain here the project repository structure

```
- specs        # requirements specifications and other artifactx
- guides       # some guides
- site         # site directory, Jekyll
- lib          # Ruby
- test         # Ruby tests
```

## Design

TODO: design and reference here the Architecture Design Document docs/ARCH.md

## Techs

- Ruby (YARD)
- Pandoc Markdown
- Github Pages, Jekyll
- Geminy AI
