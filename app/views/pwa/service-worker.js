const CACHE_NAME = "schedulite-v1"
const OFFLINE_URL = "/404.html"

// Cache key static assets on install
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([OFFLINE_URL])
    })
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

// Network-first strategy for navigation, cache fallback for offline
self.addEventListener("fetch", (event) => {
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match(OFFLINE_URL)
      })
    )
  }
})

// Handle push notifications
self.addEventListener("push", async (event) => {
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
