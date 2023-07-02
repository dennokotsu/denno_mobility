import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

export default class extends Controller {
  // 更新間隔
  interval = 1000 * 15;

  // 座標送信処理
  update_timer_id = null;
  geo_update = () => {
    // console.log("geo_update!" + new Date());
    if (document.hasFocus()) {
      // ※ブラウザ非アクティブの状態で geolocation.getCurrentPosition を呼び出すと座標が取得されないが、
      // アクティブになった瞬間に一気にまとめて取得処理成功時の処理が呼ばれてしまうので非アクティブ時は取得しないようにしておく。
      navigator.geolocation.getCurrentPosition(
        this.geo_success,
        this.geo_error,
        { enableHighAccuracy: true }
      );
    } else {
      // 非アクティブ状態では位置情報を取得しない。
      // console.log("非アクティブ状態では位置情報を取得しない。")
    }
  };

  initialize() {}

  connect() {
    this.update_timer_id = setInterval(this.geo_update, this.interval);
  }

  disconnect() {
    clearInterval(this.update_timer_id);
  }

  geo_success(position) {
    let lat = position.coords.latitude; // 緯度の取得
    let lng = position.coords.longitude; // 経度の取得
    // console.log("位置情報の取得成功 lat:" + lat + " lng:" + lng)

    // 座標情報送信
    post("/api/geo", {
      body: JSON.stringify({
        lat: lat,
        lng: lng,
      }),
    });
  }

  geo_error(error) {
    // console.log("位置情報を取得不可：" + error);
  }
}
