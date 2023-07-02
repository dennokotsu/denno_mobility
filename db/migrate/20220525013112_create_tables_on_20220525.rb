class CreateTablesOn20220525 < ActiveRecord::Migration[7.0]
  def change
    # 事業者
    create_table :companies do |t|
      t.string "company_code", null: false
      t.string "name", null: false
      t.boolean "disabled", default: false, null: false
      t.json "data"
      t.json "setting_data"
      t.timestamps

      t.index ["company_code"], unique: true
    end

    # ユーザー
    create_table :users do |t|
      t.references :company, null: false, foreign_key: true
      t.string "identifier", null: false
      t.string "password_digest", null: false
      t.string "authentication_token"
      t.datetime "authenticated_at"
      t.json "authentication_data"
      t.string "name", null: false
      t.integer "role", null: false
      t.geometry "position"
      t.boolean "disabled", default: false, null: false
      t.json "data"
      t.timestamps

      t.index %w[company_id identifier], unique: true
    end

    # メッセージ
    create_table :messages do |t|
      t.references :company, null: false, foreign_key: true
      t.integer "from_user_id", null: false
      t.integer "to_user_id"
      t.integer "group_id"
      t.json "data"
      t.boolean "read", default: false, null: false
      t.boolean "disabled", default: false, null: false
      t.timestamps

      t.index %w[company_id from_user_id]
      t.index %w[company_id to_user_id]
      t.index %w[company_id from_user_id to_user_id]
      t.index %w[company_id group_id]
      t.index %w[company_id from_user_id group_id]
    end

    # 伝票
    create_table :slips do |t|
      t.references :company, null: false, foreign_key: true
      t.string "name", null: false
      t.integer "status", null: false
      t.datetime "targeted_at", null: false
      t.integer "rep_user_id"
      t.integer "created_user_id", null: false
      t.integer "updated_user_id", null: false
      t.json "data"
      t.timestamps

      t.index ["status"]
      t.index ["targeted_at"]
      t.index %w[company_id status]
      t.index %w[company_id targeted_at]
      t.index %w[company_id rep_user_id]
      t.index %w[company_id created_user_id]
      t.index %w[company_id updated_user_id]
    end

    # グループ
    create_table :groups do |t|
      t.references :company, null: false, foreign_key: true
      t.string "name", null: false
      t.boolean "disabled", default: false, null: false
      t.json "data"
      t.timestamps
    end

    # グループ - ユーザー
    create_table :group_users do |t|
      t.references :company, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps

      t.index %w[company_id group_id]
      t.index %w[company_id user_id]
    end
  end
end
