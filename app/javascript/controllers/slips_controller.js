import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // リロード時間
  interval = 1000 * 10;

  // 自動リロード処理
  reloadTimerId = null;
  slipsReload = () => {
    // console.log("slips reload!" + new Date())
    // this.reloadTarget.click()
    this.element.requestSubmit();
  };

  initialize() {}

  connect() {
    // 自動リロード開始
    this.reloadTimerId = setInterval(this.slipsReload, this.interval);
  }

  disconnect() {
    // 自動リロード停止
    clearInterval(this.reloadTimerId);
  }

  date_select() {
    // console.log("slips_controller.js date_select()")
    this.element.requestSubmit();
  }
}
