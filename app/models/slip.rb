class Slip < ApplicationRecord
  belongs_to :company
  belongs_to :user, class_name: "User", foreign_key: "rep_user_id", optional: true

  validates :name, presence: true
  validates :targeted_at, presence: true
end
