import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { appointmentId: Number }

  async setDelay(event) {
    const minutes = event.params.minutes
    const button = event.currentTarget
    const originalText = button.textContent
    button.textContent = "..."
    button.disabled = true

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const body = new URLSearchParams({
        status: "running_late",
        delay_minutes: minutes
      })

      const response = await fetch(`/appointments/${this.appointmentIdValue}/status`, {
        method: "PATCH",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": token,
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: body.toString()
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      } else {
        button.textContent = originalText
        button.disabled = false
      }
    } catch {
      button.textContent = originalText
      button.disabled = false
    }
  }
}
