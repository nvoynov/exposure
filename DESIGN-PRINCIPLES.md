# Web-Exposure: Design & Layout Principles

This document serves as a conceptual reference and design manifesto for the **web-exposure** photo archive engine. It captures the artistic and technical decisions made to transition from a rigid digital catalog to a quiet, cinematic, and analog-feeling digital art space.

---

## Part 1. Aesthetics & "Photographic" Nature of the Home Page

The main objective of the landing page is to break away from commercial portfolios or sequential blogs. The interface acts as a physical table where high-quality photographic prints are laid out by hand.

### 1. Fixed Canvas Context (No Scroll)
*   **The Implementation:** The main layout wrapper is locked vertically inside the boundaries of the viewport height (`height: calc(100vh - 180px)`), and any native page scrolling is strictly disabled (`overflow: hidden`).
*   **The Artistic Effect:** The page ceases to feel like an endless social media timeline. Instead, it presents itself as a solid, matte photo mount (passpartout). Images at the bottom boundary are cropped "live", mimicking a natural, uncropped desktop layout.

### 2. The Dynamic "Uzor" (Randomized Mosaic)
*   **The Implementation:** We rejected monotonous grid boxes. A core JavaScript algorithm shuffles all photos from all collections on every page refresh (F5) and assigns them to one of four organic CSS Grid size variations:
    *   `.size-normal` (Standard 3:2 frame)
    *   `.size-wide` (Cinematic panorama 3:1)
    *   `.size-tall` (Vertical portrait crop 3:4)
    *   `.size-large` (A dominant 4-cell focal point maintaining a 3:2 ratio)
*   **The Artistic Effect:** Asymmetry removes industrial technicality. The viewer’s eye does not scan the screen like a text document; it wanders freely, guided by rhythmic shifts in scale.

### 3. Structural Weight & Visual Anchors
*   **The Implementation:** Size distribution probabilities are intentionally unbalanced. Small (`normal`) and delicate vertical frames (`tall`) appear frequently, while massive focal blocks (`large`) and panoramas (`wide`) are rare.
*   **The Artistic Effect:** Only one or two large images appear on the screen at a time. They act as distinct visual protagonists of the current exposition, preventing spatial overcrowding.

### 4. Negative Spaces (Intentional Gaps)
*   **The Implementation:** Invisible placeholder blocks (`spacer`) are injected directly into the randomized size array matrix.
*   **The Artistic Effect:** The grid is no longer a solid wall of bricks. "Air" is introduced into the layout. Images cluster organically into distinct constellations, replicating the empty spaces left on a physical desk.

### 5. Contemplative Staggered Appearance (Fade-in)
*   **The Implementation:** Long-duration CSS state transitions (`transition: opacity 1.5s`) paired with a calculated JavaScript timeout lag loop (300ms intervals between sequential items).
*   **The Artistic Effect:** Upon landing, the viewer faces a clean, silent, off-white canvas. Images do not pop up abruptly; they gently emerge one after another from top to bottom. This mirrors the slow alchemy of photographic paper developing under chemistry in a darkroom.

---

## Part 2. The Evolution of Album Layouts (Editorial wrapping)

To accommodate textual stories from a collection's `README.md` alongside 3:2 horizontal photo tiles, the project went through four structural iterations of modern web layout engineering:

### Iteration 1: CSS Grid with Strict Row Spanning (`grid-row: span 2`)
*   **The Defect:** The editorial text module was locked into a rigid row space. If the story grew long (e.g., 3–4 paragraphs of lorem ipsum), it pushed the grid rows down, leaving huge, empty horizontal black holes below the first two images because the grid structure couldn't wrap text adaptively.

### Iteration 2: Classic Floating Containers (`float: left`)
*   **The Defect:** A legacy web layout methodology. Due to fractional pixel rounding inaccuracies across Linux/Ubuntu rendering engines, sub-pixel rounding errors (`calc(33.333% - 20px)`) caused the third image card to occasionally slide down, breaking rows into pairs instead of neat triplets.

### Iteration 3: Flexible Flexbox Elements (`display: flex; flex-wrap: wrap`)
*   **The Defect:** Flexbox forces elements into uniform horizontal baselines. The text block simply stretched its container vertically, forcing adjacent photos in that row to distort into giant empty squares, warping their pristine 3:2 proportions.

### Iteration 4: The Final Solution — CSS Multi-column Layout
*   **The Implementation:** The magazine container is broken into a three-column column layout flow (`column-count: 3; column-gap: 30px`). The text takes up the first left column slot natively. Photos naturally flow into columns 2 and 3.
*   **The Smart Behavior:** Because elements flow vertically down columns, as soon as the text block finishes (regardless of whether it's a short one-paragraph description or a deep multi-paragraph essay), the subsequent photo tiles immediately begin filling **column 1 directly underneath the text**.
*   **The Artistic Effect (Masonry):** Because text height rarely aligns perfectly with image increments, rows below the story text naturally acquire a soft, staggered vertical offset (resembling a refined brick masonry wall). Photo aspect ratios are protected, empty space is filled, and the layout becomes completely responsive to any text volume without hand-crafted code adjustments.
