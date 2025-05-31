import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cardElement", "errors", "submitButton"]
  static values = { key: String, url: String }

  connect() {
    if (!this.keyValue) {
      this.errorsTarget.textContent = "Stripe is not configured. Contact your administrator."
      this.errorsTarget.classList.remove("hidden")
      this.submitButtonTarget.disabled = true
      return
    }

    this.stripe = Stripe(this.keyValue)
    this.elements = this.stripe.elements()

    const style = {
      base: {
        fontSize: "14px",
        color: document.documentElement.classList.contains("dark") ? "#f3f4f6" : "#111827",
        "::placeholder": { color: "#9ca3af" }
      },
      invalid: { color: "#dc2626" }
    }

    this.card = this.elements.create("card", { style })
    this.card.mount(this.cardElementTarget)

    this.card.on("change", (event) => {
      if (event.error) {
        this.errorsTarget.textContent = event.error.message
        this.errorsTarget.classList.remove("hidden")
      } else {
        this.errorsTarget.classList.add("hidden")
      }
    })

    this.element.addEventListener("submit", (e) => this.handleSubmit(e))
  }

  async handleSubmit(event) {
    event.preventDefault()
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Saving..."

    const { paymentMethod, error } = await this.stripe.createPaymentMethod({
      type: "card",
      card: this.card
    })

    if (error) {
      this.errorsTarget.textContent = error.message
      this.errorsTarget.classList.remove("hidden")
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = "Save Card"
      return
    }

    // Submit to our server
    const token = document.querySelector('input[name="authenticity_token"]').value
    const form = document.createElement("form")
    form.method = "POST"
    form.action = this.urlValue

    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = token
    form.appendChild(csrfInput)

    const pmInput = document.createElement("input")
    pmInput.type = "hidden"
    pmInput.name = "payment_method_id"
    pmInput.value = paymentMethod.id
    form.appendChild(pmInput)

    document.body.appendChild(form)
    form.submit()
  }
}
