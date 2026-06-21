---
layout: default
title: Home
---

{::options parse_block_html="false" /}

<!-- Container for the dynamic, randomized photo mosaic -->
<div class="canvas-wrapper">
  <div id="mosaic-grid" class="mosaic-grid"></div>
</div>

<!-- Hidden data block: injects all photos from all collections into JavaScript -->
<script type="application/json" id="raw-library-data">
  [
    {% for album in site.series %}
      {
        "album_slug": "{{ album.slug }}",
        "photos": [
          {% for photo in album.photos %}
            {
              "filename": "{{ photo.filename }}",
              "title": "{% if photo.title != photo.filename and photo.title != "" %}{{ photo.title }}{% endif %}"
            }{% unless forloop.last %},{% endunless %}
          {% endfor %}
        ]
      }{% unless forloop.last %},{% endunless %}
    {% endfor %}
  ]
</script>

<!-- Include the global shared lightbox component layout -->
{% include lightbox.html %}

<style>
  /* Prevents any scrolling on the main landing page to mimic a solid canvas */
  .canvas-wrapper {
    width: 100%;
    height: calc(100vh - 180px);
    overflow: hidden; 
    position: relative;
  }

  /* Dynamic Mosaic Grid Styles */
  .mosaic-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    grid-auto-rows: minmax(140px, auto);
    gap: 25px;
    max-width: 1000px;
    margin: 0 auto;
    height: 100%;
  }

  .mosaic-item {
    background-color: transparent;
    overflow: hidden;
    cursor: pointer;
    position: relative;
    opacity: 0;
    transform: scale(0.99);
    transition: opacity 1.5s ease, transform 1.5s ease;
  }

  .mosaic-item.revealed {
    opacity: 1;
    transform: scale(1);
  }

  .mosaic-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: opacity 0.2s ease;
  }

  .mosaic-item:hover img {
    opacity: 0.85;
  }

  /* Structural Pattern Classes */
  .size-normal { grid-column: span 1; grid-row: span 1; }
  .size-wide   { grid-column: span 2; grid-row: span 1; }
  .size-tall   { grid-column: span 1; grid-row: span 2; }
  .size-large  { grid-column: span 2; grid-row: span 2; }

  @media (max-width: 768px) {
    .canvas-wrapper { height: auto; overflow: visible; }
    .mosaic-grid { grid-template-columns: repeat(2, 1fr); height: auto; }
    .size-wide, .size-tall, .size-large { grid-column: span 1; grid-row: span 1; }
  }
</style>

<!-- Injecting the dynamic baseurl from Jekyll into a global JavaScript variable BEFORE the raw block -->
<script>
  window.siteBaseUrl = "{{ site.baseurl }}";
</script>

{% raw %}
<script>
  document.addEventListener('DOMContentLoaded', () => {
    const gridContainer = document.getElementById('mosaic-grid');
    const baseUrl = window.siteBaseUrl || "";
    
    const sizeClasses = [
      'size-normal', 'size-normal', 'size-normal', 
      'size-tall', 'size-tall', 
      'size-wide', 
      'size-large', 
      'spacer', 'spacer'
    ];
    
    let activeStreamPhotos = [];

    // 1. Extract raw configuration data injected by Jekyll
    const rawData = JSON.parse(document.getElementById('raw-library-data').textContent);
    let allPhotosPool = [];

    rawData.forEach(album => {
      album.photos.forEach(photo => {
        allPhotosPool.push({
          "slug": album.album_slug,
          "filename": photo.filename,
          "thumbUrl": `${baseUrl}/assets/gallery/${album.album_slug}/thumbs/${photo.filename.replace('.webp', '_thumb.webp')}`,
          "title": photo.title
        });
      });
    });

    // 2. Random shuffle engine
    function shuffleArray(array) {
      for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
      }
      return array;
    }

    // 3. Main wall layout generator
    function buildDynamicCanvas() {
      const shuffledPool = shuffleArray([...allPhotosPool]);
      gridContainer.innerHTML = '';
      activeStreamPhotos = [];

      const maxViewportHeight = gridContainer.parentElement.clientHeight;
      let poolIndex = 0;
      
      while (poolIndex < shuffledPool.length) {
        const item = document.createElement('div');
        const randomSize = sizeClasses[Math.floor(Math.random() * sizeClasses.length)];
        
        if (randomSize === 'spacer') {
          item.className = 'mosaic-item size-normal';
          item.style.visibility = 'hidden'; 
          item.style.pointerEvents = 'none';
          gridContainer.appendChild(item);
        } else {
          const photo = shuffledPool[poolIndex];
          item.className = `mosaic-item ${randomSize}`;
          
          item.innerHTML = `<img src="${photo.thumbUrl}" alt="" loading="lazy">`;
          
          gridContainer.appendChild(item);

          if (gridContainer.scrollHeight > maxViewportHeight && poolIndex > 4) {
            gridContainer.removeChild(item);
            break;
          }

          activeStreamPhotos.push(photo);
          
          const targetSlug = photo.slug;
          const targetFilename = photo.filename;
          
          item.addEventListener('click', () => {
            const parentAlbum = rawData.find(a => a.album_slug === targetSlug);
            if (!parentAlbum) return;
            
            // Explicitly pass the source collection spec with the active context flag set to 'home'
            const contextSeriesPhotos = parentAlbum.photos.map(p => ({
              "fullUrl": `${baseUrl}/assets/gallery/${targetSlug}/full/${p.filename}`,
              "title": p.title,
              "filename": p.filename,
              "slug": targetSlug,
              "context": "home" 
            }));
            
            const targetFullIndex = parentAlbum.photos.findIndex(p => p.filename === targetFilename);
            window.openLightboxWithIndex(targetFullIndex !== -1 ? targetFullIndex : 0, contextSeriesPhotos);
          });

          poolIndex++;
        }
        
        if (gridContainer.scrollHeight > maxViewportHeight) {
          break;
        }
      }

      const injectedCards = Array.from(gridContainer.querySelectorAll('.mosaic-item'))
                                 .filter(card => card.style.visibility !== 'hidden');
                                 
      injectedCards.forEach((card, index) => {
        setTimeout(() => {
          card.classList.add('revealed');
        }, index * 300);
      });
    }

    buildDynamicCanvas();
  });
</script>
{% endraw %}
