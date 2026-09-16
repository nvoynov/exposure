/* src/js/mosaic.js - Sharp Generative Mosaic Engine */
document.addEventListener('DOMContentLoaded', () => {
  const gridContainer = document.getElementById('mosaic-grid');

  // LIVE AUTO-DETECTION: Чистый и надежный расчет пути
  const getDynamicBaseUrl = () => {
    const isGitHubPages = window.location.hostname.includes('github.io');
    const pathParts = window.location.pathname.split('/').filter(Boolean);
    
    // Если мы на GitHub и в массиве путей есть хоть один элемент (это имя репозитория)
    if (isGitHubPages && pathParts.length > 0) {
      return `/${pathParts[0]}`; // Гарантированно вернет "/exposure42"
    }
    return ""; // Локально вернет пустую строку
  };

  const baseUrl = getDynamicBaseUrl();
  
  // Clean configuration map replacing the repetitive flat array layout
  // Defines how many times a configuration token is stamped into the probability pool
  const SIZE_WEIGHTS = {
    'size-normal': 3,
    'size-tall': 2,
    'size-wide': 1,
    'size-large': 1,
    'spacer': 2
  };

  // Expand the weighted configurations dynamically into a clean execution pool
  const sizeClasses = Object.entries(SIZE_WEIGHTS).flatMap(([className, weight]) => 
    Array(weight).fill(className)
  );

  // Helper utility to compile structured photographic asset references safely
  const mapPhotoRecord = (albumSlug, filename) => ({
    slug: albumSlug,
    filename: filename,
    thumbUrl: `${baseUrl}/assets/series/${albumSlug}/thumb/${filename}`,
    fullUrl: `${baseUrl}/assets/series/${albumSlug}/full/${filename}`
  });

  // 1. Fetch the runtime gallery manifest compiled by the Rake pipeline
  fetch(`${baseUrl}/seriesmap.json`)
    .then(response => {
      if (!response.ok) throw new Error("Failed to load gallery manifest target");
      return response.json();
    })
    .then(payload => {
      // Инициализируем как объект, если данных нет, чтобы Object.entries не упал
      const rawSeries = payload.series || {}; 
      const allPhotosPool = [];

      // Перебираем объект серий: albumSlug — "almaznoe", photosObj — объект с фотографиями
      Object.entries(rawSeries).forEach(([albumSlug, photosObj]) => {
        
        // Получаем массив имен файлов для текущего альбома
        const filenames = Object.keys(photosObj);

        // Pre-compile sibling references: создаем массив всех фото альбома для лайтбокса
        const albumSharedRef = filenames.map(filename => mapPhotoRecord(albumSlug, filename));

        // Наполняем общий пул картинок для мозаики
        filenames.forEach(filename => {
          const record = mapPhotoRecord(albumSlug, filename);
          // Передаем ссылку на «соседей» по альбому для корректной навигации в Lightbox
          record.albumPhotosRef = albumSharedRef; 
          allPhotosPool.push(record);
        });
      });

      buildDynamicCanvas(allPhotosPool);
    })
    .catch(err => console.error("==> [Mosaic Engine] Critical failure:", err));

  // 2. Random shuffle engine
  function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }

  // 3. Dynamic height-bound wall layout generator
  function buildDynamicCanvas(allPhotosPool) {
    if (!gridContainer) return;

    const shuffledPool = shuffleArray([...allPhotosPool]);
    gridContainer.innerHTML = '';

    const maxViewportHeight = gridContainer.parentElement.clientHeight;
    const isDesktop = window.innerWidth > 767;
    const maxColumns = isDesktop ? 4 : 2;
    
    let poolIndex = 0;
    let currentColumnTrack = 0;
    let displayedImagesCount = 0;
    
    while (poolIndex < shuffledPool.length) {
      let randomSize = sizeClasses[Math.floor(Math.random() * sizeClasses.length)];
      
      if (isDesktop && currentColumnTrack === (maxColumns - 1)) {
        const restrictiveFilters = ['size-normal', 'size-tall', 'spacer'];
        randomSize = restrictiveFilters[Math.floor(Math.random() * restrictiveFilters.length)];
      }

      const columnSpan = (randomSize === 'size-wide' || randomSize === 'size-large') ? 2 : 1;
      const item = document.createElement('div');
      
      if (randomSize === 'spacer') {
        if (isDesktop) {
          item.className = 'mosaic-item size-normal';
          item.style.visibility = 'hidden'; 
          item.style.pointerEvents = 'none';
          gridContainer.appendChild(item);
        }
      } else {
        const photo = shuffledPool[poolIndex];
        item.className = `mosaic-item ${randomSize}`;

        // SHARP VISUAL FIX: Leveraging native responsive srcset descriptors.
        item.innerHTML = `
          <img src="${photo.thumbUrl}" 
               data-album-slug="${photo.slug}"
               srcset="${photo.thumbUrl} 400w, ${photo.fullUrl} 1200w" 
               sizes="(max-width: 767px) 50vw, 30vw"
               alt="" 
               loading="lazy">`;

        gridContainer.appendChild(item);

        if (isDesktop && maxViewportHeight > 0 && gridContainer.scrollHeight > maxViewportHeight && displayedImagesCount > 4) {
          gridContainer.removeChild(item);
          break;
        }

        if (!isDesktop && displayedImagesCount >= 6) {
          gridContainer.removeChild(item);
          break;
        }

        const targetSeriesArray = photo.albumPhotosRef;
        const localPhotoIndex = targetSeriesArray.findIndex(p => p.filename === photo.filename);

        item.addEventListener('click', () => {
          if (window.ExposureLightbox) {
            window.ExposureLightbox.open(localPhotoIndex >= 0 ? localPhotoIndex : 0, targetSeriesArray);
          }
        });

        poolIndex++;
        displayedImagesCount++;
      }
      
      currentColumnTrack = (currentColumnTrack + columnSpan) % maxColumns;
      
      if (isDesktop && maxViewportHeight > 0 && gridContainer.scrollHeight > maxViewportHeight) {
        break;
      }
    }

    const injectedCards = Array.from(gridContainer.querySelectorAll('.mosaic-item'))
                               .filter(card => card.style.visibility !== 'hidden');
                               
    injectedCards.forEach((card, index) => {
      setTimeout(() => {
        card.classList.add('revealed');
      }, index * 100);
    });
  }
});
