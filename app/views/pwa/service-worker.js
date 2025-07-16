const CACHE_NAME = "schedulite-v2"
const OFFLINE_URL = "/404.html"
const PRECACHE_URLS = [OFFLINE_URL, "/manifest"]

// Cache key static assets on install
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_URLS))
  )
  self.skipWaiting()
})

// Clean up old caches on activate
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.filter((name) => name !== CACHE_NAME).map((name) => caches.delete(name))
      )
    })
  )
  self.clients.claim()
})

// Network-first for navigation, with cached fallback for offline
self.addEventListener("fetch", (event) => {
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          const copy = response.clone()
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy))
          return response
        })
        .catch(() => {
          return caches.match(event.request).then((cached) => cached || caches.match(OFFLINE_URL))
        })
    )
  }
})

// Handle push notifications
self.addEventListener("push", async (event) => {
  if (!event.data) return

  const { title, options } = await event.data.json()
  event.waitUntil(self.registration.showNotification(title, options))
})

self.addEventListener("notificationclick", (event) => {
  event.notification.close()
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      for (const client of clientList) {
        if (new URL(client.url).pathname === event.notification.data?.path && "focus" in client) {
          return client.focus()
        }
      }
      if (clients.openWindow && event.notification.data?.path) {
        return clients.openWindow(event.notification.data.path)
      }
    })
  )
})
