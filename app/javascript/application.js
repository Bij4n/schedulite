import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import AppointmentController from "./controllers/appointment_controller"
import DelayController from "./controllers/delay_controller"
import ToastController from "./controllers/toast_controller"
import SearchController from "./controllers/search_controller"
import StripeCardController from "./controllers/stripe_card_controller"
import InstallPromptController from "./controllers/install_prompt_controller"

// Register service worker for PWA
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker").catch(() => {
      // Silent fail — service worker is progressive enhancement
    })
  })
}

const application = Application.start()
application.register("appointment", AppointmentController)
application.register("delay", DelayController)
application.register("toast", ToastController)
application.register("search", SearchController)
application.register("stripe-card", StripeCardController)
application.register("install-prompt", InstallPromptController)
