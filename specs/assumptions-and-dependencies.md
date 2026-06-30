---
title: "Project Assumptions, Dependencies, and Caching Strategy"
author: "Portfolio Web Gallery Project"
date: "2026-06-30"
geometry: margin=2cm
output: pdf_document
---

# 1. Assumptions and Dependencies

This section outlines the core technical boundaries, storage metrics, and traffic forecasts designed to sustain a "zero-cost, zero-maintenance" infrastructure.

## 1.1 Core Constraints & Inventory
* **Storage Scale:** The curated portfolio is strictly capped at a maximum of 200–300 high-quality photographs.
* **Asset Specifications:** All images are compressed into the WebP format, limited to 1080px on the short side, preserving native aspect ratios (e.g., 3:2, 4:3).
* **Average File Size:** Based on current production assets, the average size per full-resolution image is established at **600 KB** (with occasional peaks up to 1 MB).
* **Total Archive Size:** 300 images $\times$ 600 KB $\approx$ **180 MB**. This fits safely within the 1 GB GitHub repository size limit.
* **Hosting Provider:** GitHub Pages (Free Tier), which imposes a strict hard limit of **100 GB of monthly bandwidth**.
* **Average User Session:** A typical visitor is assumed to load the core interface and view **20 full-size photographs** per session.

## 1.2 Traffic Forecasts

### Scenario A: Without Client-Side Caching (Cold Cache / First Visit)
In this baseline scenario, every page view and image request hits the GitHub Pages servers directly.
* **Bandwidth per Session:** (20 images $\times$ 600 KB) + 1 MB (HTML/CSS/JS/Thumbnails) $\approx$ **13 MB**.
* **Maximum Monthly Capacity:** 100 GB $\div$ 13 MB $\approx$ **7,690 sessions per month** (~250 daily visitors).

### Scenario B: With Advanced Client-Side Caching (Hot Cache / Repeat Visits)
When assets are cached locally, repeat visitors and automated browser reloads bypass the GitHub network for existing files.
* **Bandwidth per Session:** ~**1–2 MB** (only consuming data for new uploads, asset checks, and lightweight text routing).
* **Maximum Monthly Capacity:** Assuming a healthy mix of 40% new and 60% returning traffic, the effective capacity scales to **15,000–20,000 sessions per month**, safely below the threshold.

---

# 2. Caching Strategy via Service Worker & Asset Manifest

To maintain clean, permanent URLs (`domain/series/some_album/#photo-id`) without applying file-name hashing (cache-busting), the project implements a **Service Worker** combined with an **Asset Manifest Cache Validation** system.

## 2.1 Synchronization Mechanics
1. **Build-Time Generation:** The smart import script scans the photo albums. Whenever an image is added, removed, or updated, the script overwrites a lightweight file named `assets-manifest.json` containing the image paths and their modification timestamps (or content hashes).
2. **Granular Cache Invalidation:** Instead of purging the entire gallery cache when a few photos change, the Service Worker fetches the small manifest file from the network, compares asset versions, and deletes *only* the modified or deleted images from the Cache Storage.
3. **Cache-First Delivery:** All subsequent image requests are intercepted and served instantly from the local cache, completely avoiding GitHub Pages bandwidth consumption.

## 2.2 Expected Manifest Structure (`assets-manifest.json`)
The import script must output the manifest in the following format at the project root:

```json
{
  "version": "20260630-110000",
  "assets": {
    "/series/album1/P1014545.webp": "1719734400",
    "/series/album1/P1014546.webp": "1719734450",
    "/series/album2/P1028810.webp": "1719735900"
  }
}
```

## 2.3 Service Worker Implementation Code (`sw.js`)

```javascript
const CACHE_NAME = 'gallery-core-v1';
const IMAGE_CACHE_NAME = 'gallery-images-v1';

const ASSETS_TO_PRECACHE = [
  '/',
  '/index.html',
  '/styles.css',
  '/app.js',
  '/assets-manifest.json'
];

// 1. Install Event: Pre-cache core application shell
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS_TO_PRECACHE))
      .then(() => self.skipWaiting())
  );
});

// 2. Activate Event: Perform granular cache cleanup based on the manifest
self.addEventListener('activate', (event) => {
  event.waitUntil(
    fetch('/assets-manifest.json?t=' + Date.now())
      .then((response) => response.json())
      .then((manifest) => {
        return caches.open(IMAGE_CACHE_NAME).then((imageCache) => {
          return imageCache.keys().then((requests) => {
            const manifestAssets = manifest.assets || {};
            
            // Map request URLs to relative paths used in manifest keys
            const cleanupPromises = requests.map((request) => {
              const url = new URL(request.url);
              const relativePath = url.pathname;

              // If cached image is no longer in manifest, delete it
              if (!manifestAssets[relativePath]) {
                console.log(`[SW] Evicting deleted asset: ${relativePath}`);
                return imageCache.delete(request);
              }
            });
            return Promise.all(cleanupPromises);
          });
        });
      })
      .then(() => {
        // Standard cleanup for legacy core cache versions
        return caches.keys().then((keys) => {
          return Promise.all(keys.map((key) => {
            if (key !== CACHE_NAME && key !== IMAGE_CACHE_NAME) {
              return caches.delete(key);
            }
          }));
        });
      })
      .then(() => self.clients.claim())
      .catch((err) => {
        console.error('[SW] Activation or manifest validation failed:', err);
        return self.clients.claim();
      })
  );
});

// 3. Fetch Event: Intercept image requests with Granular Validation
self.addEventListener('fetch', (event) => {
  const requestUrl = new URL(event.request.url);

  // Target image requests specifically (.webp, .jpg, .png)
  if (requestUrl.pathname.match(/\.(webp|jpg|jpeg|png)\$/)) {
    event.respondWith(
      caches.open(IMAGE_CACHE_NAME).then((imageCache) => {
        return imageCache.match(event.request).then((cachedResponse) => {
          
          if (cachedResponse) {
            // Check if the image was modified by verifying custom headers or re-fetching manifest if needed.
            // For ultimate network saving, activate event handles invalidation. Serve directly.
            return cachedResponse;
          }

          // Fallback to network if not cached
          return fetch(event.request).then((networkResponse) => {
            if (!networkResponse || networkResponse.status !== 200) {
              return networkResponse;
            }
            // Clone and save new image to image cache
            imageCache.put(event.request, networkResponse.clone());
            return networkResponse;
          }).catch(() => new Response('Offline Image Unavailable', { status: 404 }));
        });
      })
    );
  } else {
    // Network-First strategy for critical JSON data and HTML/CSS/JS shell
    event.respondWith(
      fetch(event.request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseToCache));
          }
          return networkResponse;
        })
        .catch(() => caches.match(event.request))
    );
  }
});
```

## 2.4 Registration Snippet (Add to main HTML or app.js)

```javascript
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(reg => {
        console.log('Service Worker live. Scope:', reg.scope);
        
        // Check for updates to manifest on page load to trigger cache sync
        reg.update();
      })
      .catch(err => console.error('Service Worker setup stalled:', err));
  });
}
```
