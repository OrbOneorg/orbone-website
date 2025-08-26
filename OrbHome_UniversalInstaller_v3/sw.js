const CACHE = 'orbhome-v3';
const ASSETS = [
  './','./index.html','./app.js','./manifest.webmanifest',
  './icons/icon-192.png','./icons/icon-512.png'
];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.map(k => k!==CACHE ? caches.delete(k) : null))));
});
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  e.respondWith(
    caches.match(e.request).then(hit => hit || fetch(e.request).then(resp => {
      if (url.origin === location.origin) caches.open(CACHE).then(c => c.put(e.request, resp.clone()));
      return resp;
    }).catch(()=>caches.match('./index.html')))
  );
});