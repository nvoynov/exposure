/* src/js/mosaic.js - Главный дирижер генеративной мозаики */
import { MosaicCurator } from './mosaic/curators.js';
import { getColumnProportions, renderMosaicGrid, runRevealChoreography } from './mosaic/layout.js';

document.addEventListener('DOMContentLoaded', () => {
  const gridContainer = document.getElementById('mosaic-grid');
  if (!gridContainer) return;

  const AUTO_REFRESH_INTERVAL = 13500;
  const FADE_OUT_DURATION = 900;

  let curator = null;
  let refreshTimer = null;
  let isHovered = false;
  let isTransitioning = false;
  let playlistCursor = 0;

  const getDynamicBaseUrl = () => {
    const isGitHubPages = window.location.hostname.includes('github.io');
    const pathParts = window.location.pathname.split('/').filter(Boolean);
    if (isGitHubPages && pathParts.length > 0) {
      return `/${pathParts[0]}`;
    }
    return "";
  };

  const baseUrl = getDynamicBaseUrl();

  const mapPhotoRecord = (albumSlug, filename, metaObj = {}) => ({
    slug: albumSlug,
    filename: filename,
    capturedAt: metaObj.captured_at || null,
    thumbUrl: `${baseUrl}/assets/series/${albumSlug}/thumb/${filename}`,
    fullUrl: `${baseUrl}/assets/series/${albumSlug}/full/${filename}`
  });

  function preloadThumbnails(photos) {
    const promises = photos.map(photo => new Promise(resolve => {
      if (photo.aspectRatio) {
        resolve();
        return;
      }
      const img = new Image();
      img.onload = () => {
        photo.aspectRatio = (img.naturalHeight && img.naturalWidth)
          ? (img.naturalHeight / img.naturalWidth)
          : 0.67;
        resolve();
      };
      img.onerror = () => {
        photo.aspectRatio = 0.67;
        resolve();
      };
      img.src = photo.thumbUrl;
    }));
    return Promise.all(promises);
  }

  fetch(`${baseUrl}/seriesmap.json`)
    .then(response => {
      if (!response.ok) throw new Error("Failed to load gallery manifest target");
      return response.json();
    })
    .then(payload => {
      const rawSeries = payload.series || {};
      const pool = [];

      Object.entries(rawSeries).forEach(([albumSlug, photosObj]) => {
        const entries = Object.entries(photosObj || {});
        const albumSharedRef = entries.map(([filename, meta]) => mapPhotoRecord(albumSlug, filename, meta));

        entries.forEach(([filename, meta]) => {
          const record = mapPhotoRecord(albumSlug, filename, meta);
          record.albumPhotosRef = albumSharedRef;
          pool.push(record);
        });
      });

      if (pool.length > 0) {
        curator = new MosaicCurator(pool);
        renderNextScene(true);
        startAutoRefreshLoop();
      }
    })
    .catch(err => console.error("==> [Mosaic Engine] Critical failure:", err));

  async function renderNextScene(isInitial = false) {
    if (isTransitioning || !curator) return;
    isTransitioning = true;

    // Плейлист драматургии: Хаос -> Серии -> Серии -> Сезон (если есть даты) -> Хаос...
    const playlist = curator.hasSeasonData
      ? ['chaos', 'series', 'series', 'season']
      : ['chaos', 'series', 'series'];

    const currentStrategy = playlist[playlistCursor % playlist.length];
    playlistCursor++;

    const isDesktop = window.innerWidth > 767;
    const colWeights = getColumnProportions(isDesktop);
    const columnPhotoLists = curator.curateColumns(currentStrategy, colWeights.length);

    // Собираем уникальные кадры, которые реально понадобятся для предзагрузки
    const photosToPreload = Array.from(new Set(columnPhotoLists.flatMap(list => list.slice(0, 8))));

    if (!isInitial) {
      const currentCards = Array.from(gridContainer.querySelectorAll('.mosaic-item'));
      currentCards.forEach(card => {
        card.style.transitionDelay = `${Math.random() * 250}ms`;
        card.classList.remove('revealed');
      });

      await Promise.all([
        preloadThumbnails(photosToPreload),
        new Promise(resolve => setTimeout(resolve, FADE_OUT_DURATION))
      ]);
    } else {
      await preloadThumbnails(photosToPreload);
    }

    const createdCards = renderMosaicGrid(gridContainer, columnPhotoLists, colWeights, isDesktop, 'default');

    requestAnimationFrame(() => {
      runRevealChoreography(gridContainer, createdCards);
      isTransitioning = false;
    });
  }

  function startAutoRefreshLoop() {
    if (refreshTimer) clearInterval(refreshTimer);

    refreshTimer = setInterval(() => {
      const lightbox = document.getElementById('lightbox');
      const isLightboxOpen = lightbox && lightbox.style.display === 'flex';

      if (document.hidden || isLightboxOpen || isHovered) return;

      renderNextScene(false);
    }, AUTO_REFRESH_INTERVAL);
  }

  gridContainer.addEventListener('mouseenter', () => { isHovered = true; });
  gridContainer.addEventListener('mouseleave', () => { isHovered = false; });
});
