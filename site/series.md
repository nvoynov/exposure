---
layout: default
title: Series
permalink: /series/
---

{::options parse_block_html="false" /}

<div class="collections-sketchbook">
  {% assign sorted_series = site.series | sort: "order" %}
  {% for album in sorted_series %}
    {% unless album.hidden == true %}
      <a href="{{ album.url | relative_url }}" class="album-cloud-canvas" aria-label="Open {{ album.title }}">
        
        <div class="cloud-photos-wrapper">
          <!-- SLOT 1 -->
          {% assign p = album.preview_photos[0] %}
          <div class="cloud-pic pic-base">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>
          
          <!-- SLOT 2 -->
          {% assign p = album.preview_photos[1] %}
          <div class="cloud-pic pic-offset-one">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>

          <!-- SLOT 3 -->
          {% assign p = album.preview_photos[2] %}
          <div class="cloud-pic pic-offset-two">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>

          <!-- SLOT 4 -->
          {% assign p = album.preview_photos[3] %}
          <div class="cloud-pic pic-offset-three">
            <img src="{% if p.is_placeholder %}{{ '/assets/presets/blank_holder.webp' | relative_url }}{% else %}{{ '/assets/gallery/' | relative_url }}{{ album.slug }}/thumbs/{{ p.filename | replace: '.webp', '_thumb.webp' }}{% endif %}" alt="" loading="lazy">
          </div>

          <!-- SLOT 5 -->
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
