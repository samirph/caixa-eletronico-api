class Transaction < ApplicationRecord
  belongs_to :origin_account, class_name: 'Account', optional: true
  belongs_to :target_account, class_name: 'Account', optional: true
end
