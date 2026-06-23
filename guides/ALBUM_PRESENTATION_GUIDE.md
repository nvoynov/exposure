% User Guide: Album Documentation and Curation Metadata Specification
% Nikolay Voynov
% June 2026

## Introduction

This guide defines the standards for documenting and curating a fine-art
photographic series using the **web-exposure** workflow pipeline. Metadata
architecture is managed via two explicit, human-readable layout documents
placed directly within each raw photography directory on your hard drive:
`ALBUM.md` (the artistic narrative) and `ALBUM.yml` (the technical and
indexing ledger).

---

## 1. Document Specifications

### ALBUM.md (Artistic Narrative)

This file contains the *Artist Statement*, gallery exhibition commentary,
or short conceptual prose associated with the series. It uses the strict
**Pandoc Markdown** metadata line header syntax. 

The content must remain entirely free of custom HTML tags or inline
structural wrapping code to prevent parsing conflicts.

```markdown
% Almaznoe
% tags: landscape, winter, melancholy

This text serves as the main editorial commentary column on the website.
Write your thoughts, stories behind the frames, or technical notes here.
Use standard markdown formatting for paragraphs, list groups, or dividers.
```

### ALBUM.yml (Technical and Indexing Ledger)

This configuration file is generated automatically on your first import
sequence and is structured using clean **Symbol Keys** under the hood. It
separates global aggregate attributes from individual image metadata
parameters and establishes the manual *storyboard timeline sequence*.

```yaml
# Global Album Metadata Context
album_title: "Almaznoe"
cover_image_filename: "frame_01.webp"
seo_description: "This album archives photographs captured between March 2020 and April 2026."
global_keywords: "landscape, winter, зимний пейзаж, зимовий пейзаж"
global_genre: "landscape"
global_location: "Kyiv, Ukraine"

# Custom Storyboard Order: Edit this layout grid sequence manually
# Lower items will be automatically appended to the bottom trail of the queue
manual_storyboard_order:
  - "frame_01.tif"
  - "frame_02.tif"
  - "frame_05.tif" # Manually reordered to appear before frame 04
  - "frame_04.tif"
  - "frame_03.tif"

# Individual Images Catalog Block Ledger
images_catalog:
  frame_01:
    exif_title: "The First Frost"
    exif_time: "2026:01:05 11:20:00"
    exif_description: "Captured during a sudden drop in ambient temperature."
    keywords: "frost, ice, туман, паморозь"
    genre: "landscape"
    location: "Almaznoe Lake"
```

---

## 2. Structural Vocabulary Indexes

To ensure cross-border discovery across search engines without maintaining
multiple heavy localized versions of the website, use the **Hybrid
Multi-Lingual String Method**. Inject English, Russian, and Ukrainian
keywords directly into a flat string separated by commas.

### Popular Fine-Art Photography Genres

Use these canonical descriptors inside the `global_genre` and image `genre`
attribute lines:

*   **`landscape`** — Standard nature, terrain, and weather captures.
*   **`urban-landscape`** — City architecture, streets, industrial patterns,
    and geometries.
*   **`minimalism`** — Compositions dominated by massive negative space,
    lines, and textures.
*   **`street-photography`** — Unstaged, candid moments reflecting human
    presence or traces.
*   **`portrait`** — Fine-art human studies and lighting explorations.
*   **`macro`** — Close-up examinations of surface textures, ice structures,
    and details.

### Standard Descriptive Structural Keywords

Combine these core conceptual terms inside the flat string configurations
line:

*   **`nature, природа`**
*   **`architecture, архитектура, архітектура`**
*   **`geometry, геометрия, геометрія`**
*   **`monochrome, ЧБ, чорно-біле`**
*   **`silence, тишина, тиша`**
*   **`isolation, изоляция, ізоляція`**
*   **`light and shadow, свет и тень, світло і тінь`**

### Ambient Mood and Atmosphere Vocabulary

Google Images struggles to translate abstract mental states and atmospheric
moods natively. Use these explicit multi-lingual string pairs to anchor the
emotional weight of your prints:

*   **`melancholy, меланхолия, меланхолія`** — Quiet, reflective, and
    contemplative moods.
*   **`solitude, одиночество, самотність`** — Solitary elements, lonely trees,
    abandoned tracks.
*   **`mist, туман`** — Dense atmospheric fog, hidden objects, soft horizons.
*   **`dusk, сумерки, сутінки`** — Transitional evening twilight or early
    morning light shifts.
*   **`serenity, умиротворение, спокій`** — Still water, clean horizons,
    unhurried spaces.
*   **`gloom, хмурость, похмурість`** — Heavy overcast dark skies, storm
    fronts, winter density.
*   **`emptiness, пустота, порожнеча`** — Wide vacant fields, empty roads,
    quiet benches.
*   **`nostalgia, ностальгия, ностальгія`** — Timeless aesthetics, vintage
    optical textures.
*   **`bleakness, суровость, суворість`** — Hard cold conditions, stark winter
    fields.
*   **`ephemeral, мимолетность, швидкоплинність`** — Melting frost, drifting
    fog, shifting lights.
