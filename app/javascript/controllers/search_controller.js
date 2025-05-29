import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.classList.add("hidden")
      return
    }

    this.timeout = setTimeout(() => this.fetchResults(query), 250)
  }

  async fetchResults(query) {
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(`/search?q=${encodeURIComponent(query)}`, {
        headers: { "Accept": "application/json", "X-CSRF-Token": token }
      })

      if (!response.ok) return

      const data = await response.json()
      this.renderResults(data.results)
    } catch (e) {
      // silently fail
    }
  }

  renderResults(results) {
    if (results.length === 0) {
      this.resultsTarget.innerHTML = `<div class="px-4 py-3 text-xs text-gray-400">No results found</div>`
      this.resultsTarget.classList.remove("hidden")
      return
    }

    const html = results.map(r => {
      const icon = r.type === "patient"
        ? `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 text-gray-400 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" /></svg>`
        : `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 text-gray-400 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" /></svg>`

      return `<a href="${r.url}" class="flex items-center gap-3 px-4 py-2.5 hover:bg-gray-100 dark:hover:bg-gray-700 transition">
        ${icon}
        <div class="min-w-0">
          <div class="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">${r.label}</div>
          <div class="text-xs text-gray-500 dark:text-gray-400 truncate">${r.sublabel}</div>
        </div>
      </a>`
    }).join("")

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.remove("hidden")
  }

  close() {
    setTimeout(() => {
      this.resultsTarget.classList.add("hidden")
    }, 200)
  }
}
