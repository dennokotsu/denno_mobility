import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "pickup_point_radio_direct",
    "pickup_point_radio_select",
    "pickup_point_direct",
    "pickup_point_select",
    "getoff_point_radio_direct",
    "getoff_point_radio_select",
    "getoff_point_direct",
    "getoff_point_select",
    "relay_point_radio_direct",
    "relay_point_radio_select",
    "relay_point_direct",
    "relay_point_select",
  ];

  initialize() {}

  connect() {}

  disconnect() {}

  // 迎車
  pickup_point_input_change() {
    // console.log("slip_controller.js pickup_point_input_change")
    if (this.pickup_point_radio_directTarget.checked) {
      // console.log("slip_controller.js pickup_point_input_change DIRECT")
      this.pickup_point_directTarget.style.display = "block";
      this.pickup_point_selectTarget.style.display = "none";
      this.pickup_point_directTarget.removeAttribute("disabled");
      this.pickup_point_selectTarget.setAttribute("disabled", true);
      this.pickup_point_directTarget.value = "";
    }
    if (this.pickup_point_radio_selectTarget.checked) {
      // console.log("slip_controller.js pickup_point_input_change SELECT")
      this.pickup_point_directTarget.style.display = "none";
      this.pickup_point_selectTarget.style.display = "block";
      this.pickup_point_directTarget.setAttribute("disabled", true);
      this.pickup_point_selectTarget.removeAttribute("disabled");
      this.pickup_point_selectTarget.value = "";
    }
  }

  // 実車
  getoff_point_input_change() {
    // console.log("slip_controller.js getoff_point_input_change")
    if (this.getoff_point_radio_directTarget.checked) {
      // console.log("slip_controller.js getoff_point_input_change DIRECT")
      this.getoff_point_directTarget.style.display = "block";
      this.getoff_point_selectTarget.style.display = "none";
      this.getoff_point_directTarget.removeAttribute("disabled");
      this.getoff_point_selectTarget.setAttribute("disabled", true);
      this.getoff_point_directTarget.value = "";
    }
    if (this.getoff_point_radio_selectTarget.checked) {
      // console.log("slip_controller.js getoff_point_input_change SELECT")
      this.getoff_point_directTarget.style.display = "none";
      this.getoff_point_selectTarget.style.display = "block";
      this.getoff_point_directTarget.setAttribute("disabled", true);
      this.getoff_point_selectTarget.removeAttribute("disabled");
      this.getoff_point_selectTarget.value = "";
    }
  }

  // 降車(完了)
  relay_point_input_change() {
    // console.log("slip_controller.js relay_point_input_change")
    if (this.relay_point_radio_directTarget.checked) {
      // console.log("slip_controller.js relay_point_input_change DIRECT")
      this.relay_point_directTarget.style.display = "block";
      this.relay_point_selectTarget.style.display = "none";
      this.relay_point_directTarget.removeAttribute("disabled");
      this.relay_point_selectTarget.setAttribute("disabled", true);
      this.relay_point_directTarget.value = "";
    }
    if (this.relay_point_radio_selectTarget.checked) {
      // console.log("slip_controller.js relay_point_input_change SELECT")
      this.relay_point_directTarget.style.display = "none";
      this.relay_point_selectTarget.style.display = "block";
      this.relay_point_directTarget.setAttribute("disabled", true);
      this.relay_point_selectTarget.removeAttribute("disabled");
      this.relay_point_selectTarget.value = "";
    }
  }
}
