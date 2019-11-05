# frozen_string_literal: true

require 'test_helper'

class UserFlowTest < ActionDispatch::IntegrationTest
  test 'can create user' do
    post '/user/create',
         params: { name: 'Samir' }

    assert_equal '200', @response.code
    assert_equal 1, User.count
    assert_equal 'Samir', User.last.name
  end

  test 'can not create user without name' do
    post '/user/create',
         params: { name: nil }

    assert_equal '400', @response.code
    assert_equal 0, User.count
  end

  test 'can authenticate user' do
    user = create(:user, password: '123abc', account: create(:account))

    post '/user/login',
         params: { account_number: user.account.number, access_password: '123abc' }

    assert_equal '200', @response.code
  end

  test 'can not authenticate user' do
    user = create(:user, password: '123abc', account: create(:account))

    post '/user/login',
         params: { account_number: user.account.number, access_password: 'abc123' }

    assert_equal '400', @response.code
  end
end
