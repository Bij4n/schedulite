import { Controller } from "@hotwired/stimulus"

// Captures the beforeinstallprompt event and shows a custom install button
// for browsers that support PWA installation (Chrome, Edge, etc.)
export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.deferredPrompt = null

    window.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault()
      this.deferredPrompt = e
      if (this.hasButtonTarget) {
        this.buttonTarget.classList.remove("hidden")
      }
    })

    window.addEventListener("appinstalled", () => {
      if (this.hasButtonTarget) {
        this.buttonTarget.classList.add("hidden")
      }
    })
  }

  install() {
    if (!this.deferredPrompt) return

    this.deferredPrompt.prompt()
    this.deferredPrompt.userChoice.then(() => {
      this.deferredPrompt = null
      if (this.hasButtonTarget) {
        this.buttonTarget.classList.add("hidden")
      }
    })
  }
}
