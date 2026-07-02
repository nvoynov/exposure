% CHANGELOG

### Planned changes (Unreleased)

__Site Design__

- [ ] redesign `/index` for mobile phones - when there is no place for main Todd Hido like mosaic, the page should present ...

__Ruby Design__

- [ ] redesign `Task::BuildSite` according to "Pipes and Filters"
- [ ] improve image metadata describing process
  - [ ] establish a strategy to serve SEO effectively
  - [ ] maybe, build an AI Agent to serve the purpose
  - [ ] add hints into the initial ALBUM.md, ALBUM.yml, that will serve as a hint only and to affect the exsiting import process; maybe use poetic_time.rb from this repo

__Repo Design__ (analyst)

- [ ] discuss the content and design some Architecture Design Document
- [ ] extend /spec/SPEC.md by providing function requirement example 
### [v0.1.1] — 2026-07-02

- fixed series Series storyboard wrong order after import
- fixed lost images which was in site/assets/gallery but was removed form the album source.
- added thin white border for Series collage on ``/series`
- added Caching:
  - `Task::BuildManifest` renders `assets-manifest.json`
  - integrated dymnamic (*Path-Agnostic*) Service Worker providing *Cache-First* strategy for images.
- added series order on `/series` based on the latest `Image#created_at` of album.
- changed album `slug` based on dashing `Album#title`

### 2026-06-30

- redesigned README.md, described the project Intent
- proposed initial Content Caching strategy (AI)
- designend specs/USER-STORIES.md
- renamed `Ports::Adapters` into `Ports::Context`
- designed site caching strategy (see assumptions document)

### [v0.1.0] - 2026-06-29

- Designed final brandmark, glyph, and watermark
- Ruby redesigned to follow Tne Clean Architecture
- Added Google Analytics code
- Redesigned CSS layer into SCSS for including pag-specific styles 
- Fixed Open Graph image links
- Fixed favicon
- Deployed the second preview

Known issues:

- lost "lens/avatar" image on `/about`
- SEO for album images (manual describing albums and images)
- series collage 5 images breacks vertially on mobile phone

### 2026-06-19

- Designed `/home`, `/series`, and `/about` pages
- Designed site deplymment mechanic
- Designed basic Ruby script for the source gallery import
- Designed rake tesks photo:import, site:serve, site:deploy
- Deployed the very fist preview 

### 2026-06-14

**Initial User Story**

As an amateur photographer, I want to build a simple, personal web gallery for my top photos with near-zero maintenance and hosting costs, so that I can establish a sustainable digital home and a single source of truth without financial overhead."

**Pre-development Research & Constraints:**

1. Curated collection capped at 200–300 best photographs.
2. All images compressed to high-quality WebP format, limited to 1080px on the short side (maintaining native 3:2 and 4:3 aspect ratios).
3. Static deployment via GitHub Pages to eliminate server-side costs and database dependencies.
