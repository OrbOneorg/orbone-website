/* Orb Home — Universal Installer v3 */
const ORB_URL = "";               // optional: set to live Orb URL
const APK_FALLBACK_URL = "";      // optional: set to hosted APK (direct link)

let deferredPrompt = null;
const statusEl = document.getElementById('status');
const appEl = document.getElementById('app');
const enterBtn = document.getElementById('enterBtn');
const installBtn = document.getElementById('installBtn');
const iosTip = document.getElementById('iosTip');
const apkBtn = document.getElementById('apkBtn');
const fill = document.getElementById('fill');

// Progress helper
function step(pct, msg){
  fill.style.width = pct + '%';
  statusEl.textContent = msg || '';
}

function isIOS(){ return /iphone|ipad|ipod/i.test(navigator.userAgent); }
function isStandalone(){
  return (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) || window.navigator.standalone;
}

// Register SW for offline
if ('serviceWorker' in navigator) {
  step(10, 'Preparing…');
  navigator.serviceWorker.register('./sw.js').then(()=>step(25,'Caching app…')).catch(()=>step(25));
} else {
  step(15,'Browser mode.');
}

// Handle PWA install prompt (Android/Chromium)
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  installBtn.classList.remove('ghost');
  step(40, 'Install ready.');
});

// APK fallback exposure
(function(){
  if (APK_FALLBACK_URL) {
    apkBtn.href = APK_FALLBACK_URL;
    apkBtn.classList.remove('ghost');
  }
})();

// Enter button
enterBtn.addEventListener('click', () => {
  step(65, 'Opening…');
  if (ORB_URL) {
    window.location.href = ORB_URL;
    return;
  }
  appEl.style.display = 'block';
  step(85, 'Loaded.');
  if (isIOS() && !isStandalone()) {
    iosTip.style.display = 'block';
  }
  step(100, 'Ready.');
});

// Install button
installBtn.addEventListener('click', async () => {
  if (deferredPrompt) {
    deferredPrompt.prompt();
    const choice = await deferredPrompt.userChoice;
    deferredPrompt = null;
    step(100, choice.outcome === 'accepted' ? 'Installed.' : 'Install dismissed.');
  } else if (isIOS() && !isStandalone()) {
    iosTip.style.display = 'block';
    step(90, 'Use Add to Home Screen.');
  } else {
    step(90, 'Install not available here. Use browser or APK fallback.');
  }
});

// Initial progress
step(5,'Loading…');