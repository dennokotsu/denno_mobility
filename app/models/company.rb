class Company < ApplicationRecord
  has_many :users
  has_many :groups
  has_many :slips
  has_many :messages

  def self.example_setting_data
    {
      # チャットタイプ
      # all:全員とチャット可能、limit:一般ユーザー同士のチャットを制限
      "chat_type" => "all",
      # ユーザーステータス
      "user_statuses" => %w[
        空車
        迎車
        実車
        回送
        休憩
      ],
      # ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ユーザー登録項目
      # ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      "user_attribute" => [
        {
          "name" => "name_text",
          "display_name" => "任意項目_テキスト",
          "type" => "text",
          "require" => true,
          "default" => "任意項目テキスト_デフォルト",
          "placeholder" => nil
        },
        {
          "name" => "name_text_area",
          "display_name" => "任意項目_テキストエリア",
          "type" => "text_area",
          "row" => 4,
          "require" => true,
          "default" => "任意項目テキストエリア_デフォルト",
          "placeholder" => nil
        },
        {
          "name" => "name_tel",
          "display_name" => "任意項目_電話番号",
          "type" => "tel",
          "require" => true,
          "default" => "09012345678",
          "placeholder" => "09012345678"
        },
        {
          "name" => "name_email",
          "display_name" => "任意項目_メールアドレス",
          "type" => "email",
          "require" => true,
          "default" => "user@example.com",
          "placeholder" => "example@example.com"
        },
        {
          "name" => "name_date",
          "display_name" => "任意項目_日付",
          "type" => "date",
          "require" => true,
          "default" => "2022-02-22",
          "placeholder" => nil
        },
        {
          "name" => "name_datetime",
          "display_name" => "任意項目_日時",
          "type" => "datetime",
          "require" => true,
          "default" => "2022-02-22T22:22:22.000+09:00",
          "placeholder" => nil
        },
        {
          "name" => "name_number_key_value",
          "display_name" => "任意項目_数値",
          "type" => "number",
          "require" => true,
          "default" => 9876,
          "placeholder" => nil
        },
        {
          "name" => "name_select",
          "display_name" => "任意項目_セレクト key:value",
          "type" => "select",
          "require" => true,
          "default" => "fuga",
          "placeholder" => nil,
          "data" => {
            "ほげ" => "hoge",
            "ふが" => "fuga",
            "ぴよ" => "piyo"
          },
          "multiple" => false
        },
        {
          "name" => "name_select_list",
          "display_name" => "任意項目_セレクト list",
          "type" => "select",
          "require" => true,
          "default" => "ぴよ",
          "placeholder" => nil,
          "data" => %w[
            ほげ
            ふが
            ぴよ
          ],
          "multiple" => false
        },
        {
          "name" => "name_select_multiple",
          "display_name" => "任意項目_セレクト 複数選択",
          "type" => "select",
          "require" => true,
          "default" => %w[
            ほげ
            ふが
          ],
          "placeholder" => nil,
          "data" => %w[
            ほげ
            ふが
            ぴよ
          ],
          "multiple" => true
        }
      ],
      # ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # 伝票登録項目
      # ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      "slip_attribute" => [
        {
          "name" => "name_text",
          "display_name" => "任意項目_テキスト",
          "type" => "text",
          "require" => true,
          "default" => "任意項目テキスト_デフォルト",
          "placeholder" => nil,
          "user_edit" => true
        },
        {
          "name" => "name_text_area",
          "display_name" => "任意項目_テキストエリア",
          "type" => "text_area",
          "row" => 4,
          "require" => true,
          "default" => "任意項目テキストエリア_デフォルト",
          "placeholder" => nil,
          "user_edit" => false
        },
        {
          "name" => "name_tel",
          "display_name" => "任意項目_電話番号",
          "type" => "tel",
          "require" => true,
          "default" => "090-1234-5678",
          "placeholder" => "09012345678",
          "user_edit" => false
        },
        {
          "name" => "name_email",
          "display_name" => "任意項目_メールアドレス",
          "type" => "email",
          "require" => true,
          "default" => "user@example.com",
          "placeholder" => "example@example.com",
          "user_edit" => false
        },
        {
          "name" => "name_map_text",
          "display_name" => "任意項目_地図_テキスト",
          "type" => "map_text",
          "require" => true,
          "default" => "徳島県徳島市川内町平石住吉209-5",
          "placeholder" => nil,
          "user_edit" => false
        },
        {
          "name" => "name_date",
          "display_name" => "任意項目_日付",
          "type" => "date",
          "require" => true,
          "default" => "2022-02-22",
          "placeholder" => nil,
          "user_edit" => false
        },
        {
          "name" => "name_datetime",
          "display_name" => "任意項目_日時",
          "type" => "datetime",
          "require" => true,
          "default" => "2022-02-22T22:22:22.000+09:00",
          "placeholder" => nil,
          "user_edit" => false
        },
        {
          "name" => "name_number_key_value",
          "display_name" => "任意項目_数値",
          "type" => "number",
          "require" => true,
          "default" => 9876,
          "placeholder" => nil,
          "user_edit" => true
        },
        {
          "name" => "name_select",
          "display_name" => "任意項目_セレクト key:value",
          "type" => "select",
          "require" => true,
          "default" => "fuga",
          "placeholder" => nil,
          "data" => {
            "ほげ" => "hoge",
            "ふが" => "fuga",
            "ぴよ" => "piyo"
          },
          "multiple" => false,
          "user_edit" => false
        },
        {
          "name" => "name_select_list",
          "display_name" => "任意項目_セレクト list",
          "type" => "select",
          "require" => true,
          "default" => "ぴよ",
          "placeholder" => nil,
          "data" => %w[
            ほげ
            ふが
            ぴよ
          ],
          "multiple" => false,
          "user_edit" => false
        },
        {
          "name" => "name_select_multiple",
          "display_name" => "任意項目_セレクト 複数選択",
          "type" => "select",
          "require" => true,
          "default" => %w[
            ほげ
            ふが
          ],
          "placeholder" => nil,
          "data" => %w[
            ほげ
            ふが
            ぴよ
          ],
          "multiple" => true,
          "user_edit" => false
        }
      ],
      "int_setting" => 1,
      "string_setting" => "すとりんぐ",
      "array_setting" => %w[
        array1
        array2
        array3
      ],
      "hash_setting" => {
        "hash1" => "hash_1",
        "hash2" => "hash_2",
        "hash3" => "hash_3"
      },
      "array_hash_setting" => [
        {
          "array_hash_1" => "array_hash_1_1",
          "array_hash_2" => "array_hash_1_2",
          "array_hash_3" => "array_hash_1_3"
        },
        {
          "array_hash_1" => "array_hash_2_1",
          "array_hash_2" => "array_hash_2_2",
          "array_hash_3" => "array_hash_2_3"
        }
      ],
      "hash_array_setting" => {
        "hash_array1" => %w[
          hash_array1_1
          hash_array1_2
          hash_array1_3
        ],
        "hash_array2" => %w[
          hash_array2_1
          hash_array2_2
          hash_array2_3
        ]
      }
    }
  end
end
