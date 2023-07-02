import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reload"];

  // リロード時間
  interval = 1000 * 10;

  // 自動リロード処理
  reloadTimerId = null;
  chatsReload = () => {
    // console.log("chats reload!" + new Date());
    let element = document.querySelector("#chat-list");
    element.src = location.href;
    element.reload();
  };

  initialize() {}

  connect() {
    // 自動リロード開始
    this.reloadTimerId = setInterval(this.chatsReload, this.interval);
  }

  disconnect() {
    // 自動リロード停止
    clearInterval(this.reloadTimerId);
  }
}
