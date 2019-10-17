require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "deposit value" do
    account = create(:account, balance: 0)
    assert_equal account.balance, 0
    assert_equal Transaction.count, 0
    account.deposit 100.45

    assert_equal account.balance, 100.45
    assert_equal Transaction.count, 1
  end

  test "withdraw value" do
    account = create(:account, balance: 100)
    assert_equal account.balance, 100
    assert_equal Transaction.count, 0
    account.withdraw 80

    assert_equal account.balance, 20
    assert_equal Transaction.count, 1
  end

  test "transfer value" do
    origin_account = create(:account, balance: 100)
    target_account = create(:account, balance: 100)
    assert_equal Transaction.count, 0
    transferred_value = 20
    origin_account.transfer target_account.number, transferred_value

    assert_equal Account.find(origin_account.id).balance.truncate, 80
    assert_equal Account.find(target_account.id).balance.truncate, 120
    assert_equal Transaction.count, 1
  end
end
