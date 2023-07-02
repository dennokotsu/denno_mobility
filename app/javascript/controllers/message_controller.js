import consumer from "channels/consumer";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reload"];

  // リロード時間
  interval = 1000 * 10;

  // 自動リロード処理
  reloadTimerId = null;
  chatReload = () => {
    // console.log("chat reload!" + new Date());
    chat_auto_reload = true;
    document.querySelector("#message_content").reload();
  };

  initialize() {
    // 自動リロード
    this.reloadTimerId = setInterval(this.chatReload, this.interval);

    // チャットの更新監視
    const company_id = document
      .getElementById("chat_channel_room")
      .getAttribute("company-id");
    let room_name = document
      .getElementById("chat_channel_room")
      .getAttribute("name");
    // console.log("room_name: " + room_name);
    consumer.subscriptions.create(
      { channel: "ChatChannel", company_id, room: room_name },
      {
        connected() {
          // console.log("consumer.subscriptions.create(" + room_name + ") connected()");
        },

        disconnected() {
          // console.log("consumer.subscriptions.create(" + room_name + ") disconnected()");
        },

        received(data) {
          // console.log("consumer.subscriptions.create(" + room_name + ") received()");
          document.querySelector("#message_content").reload();

          setTimeout(function () {
            window.scroll(
              0,
              document.getElementById("msg_history").scrollHeight
            );
          }, 1000);
        },

        message: function () {
          return this.perform("message");
        },
      }
    );

    // チャット要素の一番下へ移動
    setTimeout(function () {
      // document.getElementById('main').scrollIntoView(false);
      // document.getElementById('main').scrollIntoView({ behavior: "auto", block: "end" });
      // scrollTo(0, 999999);
      if (!chat_auto_reload) {
        window.scroll(0, document.getElementById("msg_history").scrollHeight);
      }
    }, 1000);
  }

  connect() {}

  disconnect() {
    // 自動リロード
    clearInterval(this.reloadTimerId);
  }

  // 手動リロード用
  reload() {
    // console.log("message_controller.js reload()");
    // this.reloadTarget.click();
    document.querySelector("#message_content").reload();
  }
}
