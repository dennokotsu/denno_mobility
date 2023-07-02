import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["message", "picture", "file_icon", "file_btn"];

  initialize() {}

  connect() {}

  disconnect() {}

  // メッセージ送信
  reset_form() {
    // console.log("chat_controller.js reset_form()");
    // console.log(this.messageTarget.value)
    // console.log(this.pictureTarget.value)
    this.messageTarget.value = "";
    this.pictureTarget.value = "";
    this.file_iconTarget.classList.add("fa-file");
    this.file_iconTarget.classList.remove("fa-file-image");
    this.file_btnTarget.classList.add("msg_send_btn");
    this.file_btnTarget.classList.remove("msg_send_btn_selected");

    // 少し待ってメッセージフォームをスクロールと画像チェック
    setTimeout(function () {
      window.scroll(0, document.getElementById("msg_history").scrollHeight);
    }, 1000);
  }

  pic_check() {
    // console.log("chat_controller.js pic_check()")
    // console.log(this.file_iconTarget)
    if (this.pictureTarget.value == "") {
      // console.log("画像が空")
      this.file_iconTarget.classList.add("fa-file");
      this.file_iconTarget.classList.remove("fa-file-image");
      this.file_btnTarget.classList.add("msg_send_btn");
      this.file_btnTarget.classList.remove("msg_send_btn_selected");
    } else if (this.pictureTarget.value == null) {
      // console.log("画像がnull")
    } else {
      // console.log("画像は " + this.pictureTarget.value)
      this.file_iconTarget.classList.add("fa-file-image");
      this.file_iconTarget.classList.remove("fa-file");
      this.file_btnTarget.classList.add("msg_send_btn_selected");
      this.file_btnTarget.classList.remove("msg_send_btn");
    }
  }
}
