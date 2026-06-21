---
layout: default
title: Series
permalink: /series/
---

{::options parse_block_html="false" /}

<div class="collections-sketchbook">
  {% for album in site.series %}
    {% unless album.hidden == true %}
      <a href="{{ album.url | relative_url }}" class="album-cloud-canvas" aria-label="Open {{ album.title }}">
        
        <div class="cloud-photos-wrapper">
          <!-- SLOT 1: Base photo -->
          {% assign p = album.preview_photos[0] %}
          <div class="cloud-pic pic-base">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>
          
          <!-- SLOT 2: Offset photo one -->
          {% assign p = album.preview_photos[1] %}
          <div class="cloud-pic pic-offset-one">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>

          <!-- SLOT 3: Offset photo two -->
          {% assign p = album.preview_photos[2] %}
          <div class="cloud-pic pic-offset-two">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>

          <!-- SLOT 4: Offset photo three -->
          {% assign p = album.preview_photos[3] %}
          <div class="cloud-pic pic-offset-three">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>

          <!-- SLOT 5: Offset photo four -->
          {% assign p = album.preview_photos[4] %}
          <div class="cloud-pic pic-offset-four">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>
        </div>

        <div class="cloud-title-block">
          <h3>{{ album.title }}</h3>
        </div>

      </a>
    {% endunless %}
  {% endfor %}
</div>

<style>
  /* Sketchbook container layout holding the scattered clouds */
  .collections-sketchbook {
    max-width: 900px;
    margin: 0 auto;
    padding: 3rem 1rem;
    display: flex;
    flex-direction: column;
    gap: 6rem; /* Large gaps between clouds to give them breathing room */
  }

  /* Base bounding container for an individual cloud collage */
  .album-cloud-canvas {
    display: block;
    position: relative;
    width: 100%;
    max-width: 500px; /* Constrains the cloud to a controlled rectangular workspace */
    height: 380px;
    text-decoration: none;
    transition: transform 0.4s ease;
  }

  /* 
     SCATTER EFFECT: 
     Shifts odd and even clouds horizontally and tilts them slightly 
     to achieve a non-linear, sketch-like layout structure.
  */
  .album-cloud-canvas:nth-child(odd) {
    align-self: flex-start;
    transform: rotate(-1deg);
  }
  .album-cloud-canvas:nth-child(even) {
    align-self: flex-end;
    transform: rotate(1.5deg);
    margin-right: 5%;
  }

  /* Gentle hover interaction for the entire collage cluster */
  .album-cloud-canvas:hover {
    transform: scale(1.02) rotate(0deg) !important;
  }

  /* Internal wrapper that anchors absolute-positioned stacked photographs */
  .cloud-photos-wrapper {
    position: relative;
    width: 100%;
    height: 100%;
    z-index: 1;
  }

  /* Shared rules for individual overlapping photo items inside the cloud */
  .cloud-pic {
    position: absolute;
    background-color: #fcfcfc;
    box-shadow: 0 4px 15px rgba(0,0,0,0.04); /* Soft analog print drop shadow */
    overflow: hidden;
    aspect-ratio: 3 / 2;
    transition: transform 0.3s ease, z-index 0s;
  }
  .cloud-pic img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  /* 
     THE CHAOTIC CLOUD OVERLAP PATTERN:
     Strictly mapped coordinate distribution to simulate messy stacked prints on a desk.
  */
  .pic-base {
    width: 55%;
    left: 20%;
    top: 15%;
    z-index: 10;
    transform: rotate(-2deg);
  }

  .pic-offset-one {
    width: 45%;
    left: 5%;
    top: 5%;
    z-index: 5;
    transform: rotate(4deg);
  }

  .pic-offset-two {
    width: 42%;
    right: 5%;
    top: 8%;
    z-index: 8;
    transform: rotate(-5deg);
  }

  .pic-offset-three {
    width: 48%;
    left: 12%;
    bottom: 5%;
    z-index: 12;
    transform: rotate(3deg);
  }

  .pic-offset-four {
    width: 44%;
    right: 10%;
    bottom: 12%;
    z-index: 7;
    transform: rotate(-3deg);
  }

  /* Lift the specific hovered photo to the top of the local stack */
  .cloud-pic:hover {
    z-index: 50;
    transform: scale(1.04) rotate(0deg);
    box-shadow: 0 10px 25px rgba(0,0,0,0.08);
  }

  /* Album title typography and placement */
  .cloud-title-block {
    position: absolute;
    z-index: 20; /* Keep title text above the image stacks */
    bottom: -30px;
    left: 5%;
    pointer-events: none; /* Let clicks pass straight through to the link */
  }

  /* Pull title to the right side on mirrored even cloud canvases */
  .album-cloud-canvas:nth-child(even) .cloud-title-block {
    left: auto;
    right: 5%;
    text-align: right;
  }

  .cloud-title-block h3 {
    margin: 0;
    font-weight: 300;
    font-size: 1.05rem;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: #1a1a1a;
    background-color: rgba(251, 251, 251, 0.85); /* Semi-transparent baseline safety tint */
    padding: 5px 10px;
    display: inline-block;
  }
</style>
