/* src/js/mosaic/curators.js - Кураторские стратегии отбора кадров */

export function shuffleArray(array) {
  const copy = array.slice();
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

// Фенологическая карта сезонов с учетом дня месяца (поддерживает пересечения)
function getSeasonsFromDateString(dateStr) {
  if (!dateStr || typeof dateStr !== 'string') return [];
  const match = dateStr.match(/^\d{4}-(\d{2})-(\d{2})/);
  if (!match) return [];

  const month = parseInt(match, 10);
  const day = parseInt(match, 10);
  const seasons = [];

  // Зима: декабрь – март
  if (month === 12 || month === 1 || month === 2 || month === 3) {
    seasons.push('winter');
  }

  // Весна: март – середина мая (до 15 мая включительно)
  if (month === 3 || month === 4 || (month === 5 && day <= 15)) {
    seasons.push('spring');
  }

  // Лето: середина мая (с 16 мая) – середина сентября (до 15 сентября)
  if ((month === 5 && day > 15) || month === 6 || month === 7 || month === 8 || (month === 9 && day <= 15)) {
    seasons.push('summer');
  }

  // Осень: вторая половина сентября (с 16 сентября) – ноябрь
  if ((month === 9 && day > 15) || month === 10 || month === 11) {
    seasons.push('autumn');
  }

  return seasons;
}

export class MosaicCurator {
  constructor(allPhotosPool) {
    this.allPhotos = allPhotosPool;
    this.recentSeriesSlugs = new Set();
    this.seasonOrder = ['autumn', 'winter', 'spring', 'summer'];
    this.seasonCursor = Math.floor(Math.random() * this.seasonOrder.length);

    this.seriesMap = new Map();
    allPhotosPool.forEach(photo => {
      photo.seasons = getSeasonsFromDateString(photo.capturedAt);
      if (!this.seriesMap.has(photo.slug)) {
        this.seriesMap.set(photo.slug, []);
      }
      this.seriesMap.get(photo.slug).push(photo);
    });

    this.fullSeriesSlugs = [];
    this.microSeriesSlugs = [];

    this.seriesMap.forEach((photos, slug) => {
      if (photos.length >= 6) {
        this.fullSeriesSlugs.push(slug);
      } else {
        this.microSeriesSlugs.push(slug);
      }
    });

    this.hasSeasonData = allPhotosPool.some(p => p.seasons.length > 0);
  }

  // Главный метод: возвращает массив колонок, где каждая колонка — массив фото [col0, col1, col2]
  curateColumns(strategyName, numCols) {
    if (strategyName === 'season' && this.hasSeasonData) {
      const seasonCols = this.curateBySeason(numCols);
      if (seasonCols) return seasonCols;
    }

    if (strategyName === 'series' && this.fullSeriesSlugs.length >= 2) {
      return this.curateBySeries(numCols);
    }

    return this.curateChaos(numCols);
  }

  // 1. Стратегия ХАОС: случайный микс из всего архива
  curateChaos(numCols) {
    const shuffled = shuffleArray(this.allPhotos);
    const columns = Array.from({ length: numCols }, () => []);
    const limit = Math.min(shuffled.length, 30);

    for (let i = 0; i < limit; i++) {
      columns[i % numCols].push(shuffled[i]);
    }
    return columns;
  }

  // 2. Стратегия ПОРЯДОК + ЗАРИСОВКИ: серии в колонках + колонка микро-альбомов
  curateBySeries(numCols) {
    // Выбираем серии, которые ещё не показывались в прошлых циклах
    let availableFull = this.fullSeriesSlugs.filter(s => !this.recentSeriesSlugs.has(s));
    if (availableFull.length < numCols) {
      this.recentSeriesSlugs.clear();
      availableFull = this.fullSeriesSlugs.slice();
    }

    const pickedFull = shuffleArray(availableFull).slice(0, numCols);
    pickedFull.forEach(slug => this.recentSeriesSlugs.add(slug));

    const columns = pickedFull.map(slug => shuffleArray(this.seriesMap.get(slug)));

    // На десктопе (3 колонки) с вероятностью 75% превращаем одну колонку в «колонку зарисовок»
    if (numCols === 3 && this.microSeriesSlugs.length > 0 && Math.random() < 0.75) {
      const sketchColIndex = Math.floor(Math.random() * numCols);
      const shuffledMicros = shuffleArray(this.microSeriesSlugs);
      const sketchPool = [];

      shuffledMicros.forEach(slug => {
        sketchPool.push(...shuffleArray(this.seriesMap.get(slug)));
      });

      if (sketchPool.length >= 4) {
        columns[sketchColIndex] = sketchPool;
      }
    }

    return columns;
  }

  // 3. Стратегия СЕЗОНЫ: мерцание времен года с сохранением гармонии внутри колонок
  curateBySeason(numCols) {
    // Пробуем найти следующий сезон, в котором достаточно снимков
    for (let attempt = 0; attempt < 4; attempt++) {
      const targetSeason = this.seasonOrder[this.seasonCursor % this.seasonOrder.length];
      this.seasonCursor++;

      const seasonPhotos = this.allPhotos.filter(p => p.seasons.includes(targetSeason));
      
      if (seasonPhotos.length < numCols * 3) continue;
      this.lastActiveSeason = targetSeason;

      // Группируем сезонные кадры по сериям, чтобы соседние кадры в колонке держали ритм
      const bySlug = new Map();
      shuffleArray(seasonPhotos).forEach(p => {
        if (!bySlug.has(p.slug)) bySlug.set(p.slug, []);
        bySlug.get(p.slug).push(p);
      });

      const columns = Array.from({ length: numCols }, () => []);
      let colIdx = 0;
      bySlug.forEach(group => {
        columns[colIdx % numCols].push(...group);
        colIdx++;
      });

      // Если какая-то колонка оказалась слишком короткой, добираем из общего пула сезона
      const fallbackPool = shuffleArray(seasonPhotos);
      columns.forEach(col => {
        if (col.length < 4) {
          col.push(...fallbackPool.slice(0, 6));
        }
      });

      return columns;
    }

    return null; // Если ни в одном сезоне не набралось кадров, откатываемся в series/chaos
  }
}

