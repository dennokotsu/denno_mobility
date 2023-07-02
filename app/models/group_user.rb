class GroupUser < ApplicationRecord
  belongs_to :company
  belongs_to :group
  belongs_to :user
end
