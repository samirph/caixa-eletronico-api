require 'test_helper'

class AccountFlowTest < ActionDispatch::IntegrationTest
  test "cannot withdraw from account more than the balance" do
    account = create(:account, balance: 0)
    token = JsonWebToken.encode(user_id: account.user.id)
    account.user.update(password: '123abc')
    post "/user/withdraw", 
      params: {withdraw_value: 100, accessPassword: '123abc'},
      headers: {'Authorization' => token}

      assert_equal '400', @response.code
    assert_equal 'Saldo insuficiente', @response.parsed_body['message']
  end

  test "can withdraw from account" do
    account = create(:account, balance: 100)
    account.user.update(password: '123abc')
    token = JsonWebToken.encode(user_id: account.user.id)

    post "/user/withdraw", 
      params: {withdraw_value: 50, accessPassword: '123abc'},
      headers: {'Authorization' => token}

    assert_equal '200', @response.code
    assert_equal 'Saque efetuado', @response.parsed_body['message']
  end

  test "unauthorized user cannot withdraw" do
    post "/user/withdraw", 
      params: {withdraw_value: 50},
      headers: {'Authorization' => nil}

    assert_equal '401', @response.code
    assert_equal 'Não autorizado', @response.parsed_body['message']
  end

  test "can deposit on account" do
    account = create(:account, balance: 0)
    token = JsonWebToken.encode(user_id: account.user.id)

    post "/user/deposit", 
      params: {deposit_value: 50},
      headers: {'Authorization' => token}

    assert_equal '200', @response.code
    assert_equal 'Depósito efetuado', @response.parsed_body['message']
  end

  test "cannot deposit zero on account" do
    account = create(:account, balance: 0)
    token = JsonWebToken.encode(user_id: account.user.id)

    post "/user/deposit", 
      params: {deposit_value: 0},
      headers: {'Authorization' => token}

    assert_equal '422', @response.code
    assert_equal 'Valor da transação deve ser maior que zero', @response.parsed_body['message']
  end

  test "can transfer to account" do
    account = create(:account, balance: 100)
    target_account = create(:account, balance: 0)
    token = JsonWebToken.encode(user_id: account.user.id)
    account.user.update(password: '123abc')
    post "/user/transfer", 
      params: {transferValue: 20, accountNumber: target_account.number, accessPassword: '123abc'},
      headers: {'Authorization' => token}

    assert_equal '200', @response.code
    assert_equal 'Transferência efetuada', @response.parsed_body['message']
  end

  test "handle transfer to invalid account" do
    account = create(:account, balance: 100)
    token = JsonWebToken.encode(user_id: account.user.id)
    account.user.update(password: '123abc')
    post "/user/transfer", 
      params: {transferValue: 20, accountNumber: '000000', accessPassword: '123abc'},
      headers: {'Authorization' => token}

    assert_equal '400', @response.code
    assert_equal 'Número de conta inválido', @response.parsed_body['message']
  end

  test "handle missing params in transfer to account" do
    account = create(:account, balance: 100)
    token = JsonWebToken.encode(user_id: account.user.id)
    account.user.update(password: '123abc')
    post "/user/transfer", 
      headers: {'Authorization' => token},
      params: {accessPassword: '123abc'}

    assert_equal '400', @response.code
    assert_equal 'Dados necessários não informados', @response.parsed_body['message']
  end
end
