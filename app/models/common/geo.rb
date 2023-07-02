# :nocov:
module Common
  module Geo
    # 二点間の直線距離：単位はメートル
    def self.calc_distance(lat1, lng1, lat2, lng2)
      return 0 if lat1.blank? || lng1.blank? || lat2.blank? || lng2.blank?

      return 0 if lat1 == lat2 && lng1 == lng2

      y1 = lat1 * Math::PI / 180
      x1 = lng1 * Math::PI / 180
      y2 = lat2 * Math::PI / 180
      x2 = lng2 * Math::PI / 180
      earth_r = 6_378_140
      deg = Math.sin(y1) * Math.sin(y2) + Math.cos(y1) * Math.cos(y2) * Math.cos(x2 - x1)
      earth_r * (Math.atan(-deg / Math.sqrt(-deg * deg + 1)) + Math::PI / 2)
    end

    # 二点間の方角：西が0で時計回りに増加
    def self.calc_angle(lat1, lng1, lat2, lng2)
      return 0 if lat1.blank? || lng1.blank? || lat2.blank? || lng2.blank?

      return 0 if lat1 == lat2 && lng1 == lng2

      pos1 = [lat1, lng1]
      pos2 = [lat2, lng2]
      y1, x1, y2, x2 = [*pos1, *pos2].map { |v| v * Math::PI / 180 }
      y = Math.cos(x2) * Math.sin(y2 - y1)
      x = Math.cos(x1) * Math.sin(x2) - Math.sin(x1) * Math.cos(x2) * Math.cos(y2 - y1)

      (180 * Math.atan2(y, x) / Math::PI) % 360
    end
  end
end
# :nocov:
