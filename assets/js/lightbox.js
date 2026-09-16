/* ==========================================================================
   RAWWW CORE LIGHTBOX ENGINE (CLEAN PARAMETER-DRIVEN INTERFACE)
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  const overlay = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  
  if (!overlay || !lightboxImg) return;

  const closeBtn = document.getElementById('lightbox-close-btn');
  const prevBtn = document.getElementById('lightbox-prev-btn');
  const nextBtn = document.getElementById('lightbox-next-btn');
  const fsBtn = document.getElementById('fullscreen-btn');
  const copyBtn = document.getElementById('copy-link-btn');
  const toast = document.getElementById('lightbox-toast');

  let photosPool = [];       
  let currentGalleryIndex = 0;

  // 1. Core Open View Trigger
  const openLightboxWithIndex = (index, customPhotosArray = null) => {
    // If a custom array is passed (from mosaic.js), slice it into memory, otherwise keep standard pool
    if (customPhotosArray) {
      photosPool = customPhotosArray;
    }
    
    if (photosPool.length === 0) return;
    currentGalleryIndex = index;
    updateLightboxView();
    overlay.style.display = 'flex';
  };

  // 2. Sync State & Target Image Content Source
  const updateLightboxView = () => {
    const photo = photosPool[currentGalleryIndex];
    if (!photo) return;
    lightboxImg.src = photo.fullUrl || photo.thumbUrl.replace('/thumb/', '/full/');
  };

  // 3. Navigation Controls
  const lightboxNext = () => {
    if (photosPool.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex + 1) % photosPool.length;
    updateLightboxView();
  };

  const lightboxPrev = () => {
    if (photosPool.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex - 1 + photosPool.length) % photosPool.length;
    updateLightboxView();
  };

  const closeLightbox = () => {
    overlay.style.display = 'none';
    // Cleanly wipe the '?img=' tracking parameters from the address bar without reload
    history.replaceState("", document.title, window.location.pathname + window.location.search.replace(/\?img=[^&]*/, '').replace(/^&/, '?'));
    
    if (document.fullscreenElement) {
      document.exitFullscreen().catch(() => {});
    }
  };

  // Bind Standard Click Targets
  if (closeBtn) closeBtn.addEventListener('click', closeLightbox);
  if (prevBtn)  prevBtn.addEventListener('click', lightboxPrev);
  if (nextBtn)  nextBtn.addEventListener('click', lightboxNext);

  // Keyboard controls
  document.addEventListener('keydown', (e) => {
    if (overlay.style.display !== 'flex') return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowRight') lightboxNext();
    if (e.key === 'ArrowLeft') lightboxPrev();
    if (e.key === 'f' || e.key === 'F') {
      e.preventDefault();
      if (!document.fullscreenElement) overlay.requestFullscreen().catch(() => {});
      else document.exitFullscreen();
    }
  });

  if (fsBtn) {
    fsBtn.addEventListener('click', () => {
      if (!document.fullscreenElement) overlay.requestFullscreen().catch(() => {});
      else document.exitFullscreen();
    });
  }

  // --- INTEGRATED PRODUCTION CLIPBOARD SHARE GENERATOR ---
  if (copyBtn) {
    copyBtn.addEventListener('click', () => {
      const photo = photosPool[currentGalleryIndex];
      if (!photo) return;

      const siteOrigin = window.location.origin;
      const pathParts = window.location.pathname.split('/').filter(Boolean);
      const isGitHubPages = window.location.hostname.includes('github.io');
      
      // FIXED: Strictly extract ONLY the first segment (the repository name) from the array 
      // instead of injecting the entire array object as a comma-separated string
      const rootPrefix = isGitHubPages && pathParts.length > 0 ? `/${pathParts[0]}` : '';
      
      const cleanName = photo.filename.split('.');
      const cleanSlug = (cleanName[0] || '').toLowerCase();

      let targetAlbumSlug = photo.slug;
      if (!targetAlbumSlug && photo.thumbUrl) {
        const urlSegments = photo.thumbUrl.split('/');
        const seriesIndex = urlSegments.indexOf('series');
        if (seriesIndex !== -1 && urlSegments[seriesIndex + 1]) {
          targetAlbumSlug = urlSegments[seriesIndex + 1];
        }
      }

      if (!targetAlbumSlug) targetAlbumSlug = 'unknown';

      // Constructs the precise absolute URL path link structure
      const shareUrl = `${siteOrigin}${rootPrefix}/series/${targetAlbumSlug}/${cleanSlug}.html`;

      navigator.clipboard.writeText(shareUrl).then(() => {
        if (!toast) return;
        toast.classList.add('visible');
        setTimeout(() => toast.classList.remove('visible'), 2000);
      }).catch(err => console.error('Share link copy failed:', err));
    });
  }

  // --- LAYER 2: STATIC HTML INITIAL DATA POOL SCANNER ---

  const initGalleryPool = () => {
    // Find all flatplan images
    const pageImages = Array.from(document.querySelectorAll('.flatplan_media_grid img, .flatplan_editorial_hero img'));
    if (pageImages.length === 0) return;

    const currentUrlParts = window.location.pathname.split('/').pop() || '';
    const pageAlbumSlug = currentUrlParts.replace('.html', '');

    photosPool = pageImages.map(img => {
      const currentSrc = img.src;
      const filename = currentSrc.split('/').pop() || '';

      let thumbUrl = currentSrc;
      let fullUrl = currentSrc;

      if (currentSrc.includes('/thumb/')) {
        fullUrl = currentSrc.replace('/thumb/', '/full/');
      } else if (currentSrc.includes('/full/')) {
        thumbUrl = currentSrc.replace('/full/', '/thumb/');
      } else {
        // Фоллбек на случай, если структура папок изменится
        fullUrl = currentSrc.replace('/assets/', '/assets/full/');
        thumbUrl = currentSrc.replace('/assets/', '/assets/thumb/');
      }

      return {
        "thumbUrl": thumbUrl,
        "fullUrl": fullUrl,
        "filename": filename,
        "slug": pageAlbumSlug,
        "title": img.alt || ""
      };
    });

    pageImages.forEach((img, currentIndex) => {
      img.style.cursor = 'pointer';
      img.style.pointerEvents = 'auto'; // Гарантируем прохождение клика сквозь параграфы Pandoc

      img.addEventListener('click', (e) => {
        e.preventDefault();
        openLightboxWithIndex(currentIndex);
      });
    });
  };


  // --- LAYER 3: DEEP LINK GATEWAY PARAMETER PARSER ---
  
  function resolveActivePhotoParameter() {
    // Standard interface hook reading query string parameter mappings: e.g., ?img=DP0Q0398
    const urlParams = new URLSearchParams(window.location.search);
    const targetImageName = urlParams.get('img');
    if (!targetImageName) return;

    // Probe the active context database pool for matching filename elements (case-insensitive check)
    const targetIndex = photosPool.findIndex(p => p.filename.toLowerCase().includes(targetImageName.toLowerCase()));

    if (targetIndex !== -1) {
      openLightboxWithIndex(targetIndex);
    }
  }

  // Export safe bridge hooks globally for asynchronous external injection execution (mosaic.js)
  window.ExposureLightbox = {
    open: openLightboxWithIndex
  };

  // Run native parsing loops sequentially
  initGalleryPool();
  resolveActivePhotoParameter();
});
