import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkInButton", "completeButton"]
  static values = { id: Number }

  async checkIn() {
    await this.performAction(`/appointments/${this.idValue}/check_in`)
  }

  async complete() {
    await this.performAction(`/appointments/${this.idValue}/status`, { status: "complete" })
  }

  async performAction(url, extraParams = {}) {
    const button = event.currentTarget
    const originalText = button.textContent
    button.textContent = "..."
    button.disabled = true

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const body = new URLSearchParams(extraParams)

      const response = await fetch(url, {
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
