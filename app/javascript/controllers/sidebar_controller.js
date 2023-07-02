import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  sidebar = document.getElementById("sidebar-content");
  showSidebar = false;

  connect() {}

  disconnect() {}

  initialize() {}

  toggle() {
    // console.log("sidebar_controller.js toggle()")
    if (this.showSidebar) {
      this.close();
    } else {
      this.open();
    }
  }

  open() {
    // console.log("sidebar_controller.js open()")
    this.sidebar.style.cssText = "left: 0px";
    this.showSidebar = true;
  }

  close() {
    // console.log("sidebar_controller.js close()")
    this.sidebar.style.cssText = "left: -250px";
    this.showSidebar = false;
  }
}
