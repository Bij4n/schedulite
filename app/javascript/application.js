import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import AppointmentController from "./controllers/appointment_controller"
import DelayController from "./controllers/delay_controller"
import ToastController from "./controllers/toast_controller"
import SearchController from "./controllers/search_controller"

const application = Application.start()
application.register("appointment", AppointmentController)
application.register("delay", DelayController)
application.register("toast", ToastController)
application.register("search", SearchController)
