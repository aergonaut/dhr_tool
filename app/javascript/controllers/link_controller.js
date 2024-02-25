import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="link"
export default class extends Controller {
  static targets = ["url"];

  connect() {}

  clear(event) {
    event.preventDefault();
    this.urlTarget.value = "";
  }
}
