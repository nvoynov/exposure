---
title: "Technical Specification: Unified UI/UX Architecture & Cross-Media Brand Identity"
author: "Project Engineering Team & Lead Designer"
date: "June 2026"
subject: "Exposure Gallery Integrated UI-Kit Specification"
tags: [spec, ui-kit, brand-identity, responsive-grid, imagemagick, svg, open-graph]
---

__NOTE__ error `xmlns` value for svg the correct one is `http://www.w3.org/2000/svg`


# UI/UX Visual Engineering & Design System Specification (UI/UX-SPEC)

## 1. Objective & Design Philosophy

This document defines the technical constraints, quality criteria, and architectural requirements for the Visual Design Phase (High-Fidelity UI/UX Specification). All future frontend developments and high-fidelity interface assets must comply with the layout architecture established in the low-fidelity wireframes (`main_layout.svg`, `main_portfolio_view.svg`, `series_view.svg`, `album_view.svg`, `lightbox_view.svg`, `about_view.svg`) and adhere to the strict rules outlined below.

The core philosophy relies on strict monochrome minimalism, high-density cinematic whitespace, and an integrated, cross-media visual thread. The design framework uses the concept of **Analog Photographic Optics** (Focus Screens, Viewfinders, Aperture Blades) to create a subtle yet authoritative signature across all platforms, from a browser tab icon to social media link presentation embeds.

---

## 2. Integrated Visual Identity & Identity Assets

The core brand asset is the **Vector Camera Focus Screen**. This dynamic glyph repeats across multiple scales and layout nodes to unify the platform's visual ecosystem.

### 2.1 Asset Node A: The Adaptive Favicon (`favicon.svg`)
The favicon provides the initial interface anchor inside the client's web browser environment.
* **Dimensions & Setup**: Strict square pixel container with explicitly bound XML schemas to enforce validation under rigid OS-level rendering contexts (such as macOS Finder, Ubuntu Eye of GNOME, and Nautilus file systems):
  ```xml
  <svg xmlns="http://w3.org" width="32" height="32" viewBox="0 0 32 32">
  ```
* **Visual Composition**: An optimized, horizontal cinematic rectangle frame (`width: 1px`, rounded corners `rx="1.5"`) with external focus ticks that touch the border but do not intersect the inner area. Centered with an embedded, widened vector typography stack for initials `NV` (`width: 2.5px`).
* **Cross-Theme Agnosticism**: Implements a redundant dual-layer stroke technique. A thick white background halo stroke (`width: 3px` or `5px`) sits directly underneath the dark primary artwork (`width: 1px` or `2.5px`). This creates an invisible outer outline on bright browser tabs but provides high-contrast neon readability on dark native tabs or private incognito sessions without executing custom DOM script hooks.

### 2.2 Asset Node B: The Header Logo & Structural Splitter
The focus screen asset transfers directly into the website's persistent top navigation zone (Header), serving as a graphic anchor and text separator.
* **Layout Rule**: Positioned inline immediately between the author’s name and the gallery taxonomy text block: `[ AUTHOR NAME ] <focus-screen-glyph> [ GALLERY TEXT ]`.
* **Aesthetic Integration**: Scaled downward uniformly to fit the exact font baseline bounding height (14px to 16px). It acts as a structural divider, echoing a classic analog film camera's viewfinder overlay grid.

### 2.3 Asset Node C: Automated Brand Watermarks (`og-watermark.svg`)
To protect ownership and establish brand authority over link shares, a specialized, high-definition standalone version of the focus screen glyph is rendered directly on social media previews.
* **Technical Spec**: Fixed dimensions of `64x64` pixels with explicit white paths (`stroke="#FFFFFF"`) embedded with partial opacity attributes (`-channel A -evaluate multiply 0.7`). It is automatically injected in the bottom-right corner (`-gravity southeast -geometry +30+30`) during image processing cycles.
---

## 3. Brand Color Palette & Typography Tokens

The Designer must deliver an interactive Design System (UI-Kit) containing components cross-referenced with CSS design tokens.

### 3.1 Color Tokens & Theme Agnosticism
* **Primary Canvas Surface**: High-purity white background (`#FFFFFF`) to mimic white-walled fine art gallery exhibitions.
* **Primary Text & Graphic Lines**: Charcoal deep tone (`#1A1A1A`), avoiding jarring pure blacks (`#000000`) to soften text readability.
* **Interactive Accent Token**: Muted crimson red sub-tone (`#E11D48`). Reserved strictly for interactive feedback triggers, matching an analog camera's recording indicators or active metering systems.

### 3.2 Typography Tokens
The font rendering system must utilize system-ui sans-serif stacks to prevent external font-loading network bottlenecks.
* **Header / Logo**: 22px / Weight: 300 (Light) / Tracking: 2px (Expanded letter-spacing).
* **Album & Section Titles**: 14px / Weight: 600 (Semi-Bold) / Tracking: 0.5px.
* **Body / Meta Text**: 11px / Weight: 400 (Regular) / Leading: 1.5 (Line height multiplier).

### 3.3 Interactive Element States (UI States)
Every micro-interaction icon (Full Screen `⛶`, Copy Link `🔗`, Close Slider `×`, Chevrons `❮` `❯`) must include distinct state declarations:
* **Default State**: Thin stroke (`1px` to `1.5px`), regular neutral tone.
* **Hover State (`:hover`)**: Triggered transition, color switch to Accent Crimson, smooth transform easing (`transition: color 0.2s ease`).
* **Active State (`:active`)**: Subtle scale-down transformation (`transform: scale(0.95)`).

---

## 4. Performance & Asset Optimization Requirements

The frontend architecture prioritizes raw performance, structural minimalism, and rapid Document Object Model (DOM) rendering.

### 4.1 Vector Assets (SVG) Constraints
* **Inline Vector Integration**: Brand assets, UI icons, and the core focus-screen identity icon must be embedded directly inline inside the HTML markup to minimize separate HTTP/HTTPS network handshakes.
* **Payload Muted Weight**: No standalone SVG component may exceed **1.5 KB** total raw payload. 
* **W3C Schema Integrity**: All structural tags must declare a strictly valid namespace structure explicitly positioned as the first attribute:
  ```xml
  <svg xmlns="http://w3.org" width="32" height="32" viewBox="0 0 32 32">
  ```
* **Structural Hygiene**: SVG nodes must be exported as clean paths, shapes, or basic lines. Embedded bitmaps, rasterized elements (`<image>`), base64 data streams, or redundant graphic editor metadata (e.g., Adobe Illustrator/Inkscape layer attributes) are strictly prohibited.
---

## 5. Grid System & Responsive Layout Adaptability

The gallery implements a fluid, content-first masonry and asymmetric row wrap engine.

### 5.1 Grid Breakpoint Matrix
The interface wraps dynamically through CSS Flexbox and Grid, omitting rigid pixel-locked containers:
* **Desktop / Large Screens ($\ge$ 1024px)**: Dual columns on *About Page*, 3-to-4 image columns on *Album Views*, horizontal staggered overlap on *Series Entries*, and multi-scale mosaic grids on the home view.
* **Tablets (768px - 1023px)**: Single column content text, fluid 2-to-3 image masonry layouts.
* **Mobile Devices ($\le$ 767px)**: Strict single-column stack layout. Scattered image collage stacks must stack vertically into centralized single-file viewports to prevent horizontal layout overflow (`overflow-x: hidden`).

### 5.2 Spatial Layout Rules
* **Asymmetric Alignment**: The layout relies on visual tension rather than rigid symmetries. When an image row lacks a completing thumbnail, it must float left, leaving an empty structural column placeholder.
* **Dynamic Wrapping**: Photographic thumbnails on the album view page must wrap gracefully below and around the description text block using adaptive flex-grow properties to guarantee full responsiveness across custom monitor resolutions.

---

## 6. Social Media Previews Architecture (Open Graph Engine)

To resolve the discrepancy between minimal on-site execution and external visual presentation, the automated asset import pipe must build high-impact Open Graph (`og:image`) assets. The imagery must be generated via server-side or local deployment workflows using command-line **ImageMagick** engines.

All outputs must match the official landscape specification ratio of **1.91:1** (`1200x630` pixels).

### 6.1 Global Main Gallery Preview: "The Exhibition Wall" (Todd Hido Style)
The primary preview for the home domain represents a structured yet dynamic mosaic grid, reminiscent of a museum gallery exhibition hang.
* **Layout Composition**: Divided into asymmetric multi-scale columns. Features a dominant vertical showcase frame (`400x570`) on the left side, contrasted against changing horizontal cinematic frames and small squares on the right side.
* **Separation Gaps**: Frames are separated by 4px white gutters (`stroke-width="4"`) acting as physical frame passpartouts.
* **Branding**: The high-definition white vector watermark layer is composited at 80% opacity in the absolute lower right-hand corner.
* **Automated ImageMagick Code Sequence**:
  ```bash
  magick convert -size 1200x630 xc:#FFFFFF \
     vertical1.jpg -resize x570 -gravity center -crop 400x570+0+0!  -geometry +30+30  -composite \
     landscape2.jpg -resize 450x -gravity center -crop 450x300+0+0!  -geometry +460+30 -composite \
     square3.jpg -resize 240x -gravity center -crop 240x240+0+0!  -geometry +460+360 -composite \
     landscape4.jpg -resize 220x -gravity center -crop 220x240+0+0!  -geometry +720+360 -composite \
     landscape5.jpg -resize 480x -gravity center -crop 480x270+0+0!  -geometry +690+50 -composite \
     og-watermark.svg -channel A -evaluate multiply 0.8  -gravity southeast -geometry +40+40 -composite \
    og-main-preview.jpg
  ```

### 6.2 Individual Album Previews: "The Scattered Prints Portfolio"
Individual series links avoid boring square thumbnails, opting to replicate the live chaotic grid collage layout built into the website's portfolio page.
* **Layout Composition**: 5 distinctive photographs chosen programmatically from the target sub-album. Images are scattered across a neutral canvas surface (`#FAFAFA`), using custom scaling and asymmetrical rotations.
* **Layer Z-Index Simulation**: 4 base layers overlap loosely around the edges, while 1 main hero print settles directly in the absolute optical center, anchoring the pile.
* **Physical Realism**: Every print block contains a white frame edge border (`-border 6`) and an algorithmic drop shadow backdrop projection (`-shadow`) to emphasize realistic physical print sheets on a desk.
* **Branding**: Imprints the global white watermark at 70% opacity in the lower-right margin.
* **Automated ImageMagick Code Sequence**:
  ```bash
  magick convert -size 1200x630 xc:#FAFAFA \
     img1.jpg -resize 350x -bordercolor white -border 6 -shadow 60x5+2+2 -background none -rotate -4  -geometry +150+100 -composite \
     img2.jpg -resize 320x -bordercolor white -border 6 -shadow 60x5+2+2 -background none -rotate 5  -geometry +650+80  -composite \
     img3.jpg -resize 360x -bordercolor white -border 6 -shadow 60x5+2+2 -background none -rotate -2  -geometry +200+300 -composite \
     img4.jpg -resize 340x -bordercolor white -border 6 -shadow 60x5+2+2 -background none -rotate 3  -geometry +700+280 -composite \
     main.jpg -resize 450x -bordercolor white -border 8 -shadow 80x8+4+4 -background none -rotate -1  -geometry +380+110 -composite \
     og-watermark.svg -channel A -evaluate multiply 0.7  -gravity southeast -geometry +30+30 -composite \
    og-series-preview.jpg
  ```

---

## 7. Responsive Image Resolution Framework (Asset Sizing Guidelines)

To enforce instantaneous page loading speeds, content images must be pre-rendered on the server into multiple layout-optimized responsive breakpoints utilizing HTML5 `<picture>` tags or `srcset` source attributes.

The following data matrix defines the concrete dimensions required for deployment (based on standard 2:3 aspect ratio portrait/landscape exposures):

| Device Category | Screen Breakpoint | Recommended Image Sizing | Layout Context / Sizing | Target File Size (WebP/AVIF) |
| :--- | :--- | :--- | :--- | :--- |
| **Mobile (Previews)** | $\le$ 767px | **600px $\times$ 400px** | Tiny responsive column grids / Mobile feed masonry | $\le$ 80 KB |
| **Tablets & Monos** | 768px - 1023px | **1024px** (Short edge) | Native resolution matching mobile/tablet viewports | $\le$ 350 KB |
| **Desktop Monitors** | $\ge$ 1024px | **1024px $\times$ 1536px** | Full scale native desktop presentation (Soft quality) | $\le$ 500 KB |

### 7.1 Image Optimization Processing Policies
1. **Modern Formats Compression**: Next-generation web image encodings (**WebP** and **AVIF**) are mandatory. Legacy formats (JPEG, PNG) must only serve as conditional fallback parameters.
2. **Exif Scrubbing**: All photographic images must have their non-critical camera metadata strings, GPS parameters, and thumbnail header tracks fully scrubbed via backend utility tools (`exiftool` / pipeline scripts) before deployment to optimize byte delivery over mobile cellular networks. Color space profiles (sRGB) must be carefully preserved.
