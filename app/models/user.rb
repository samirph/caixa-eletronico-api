# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true
  has_one :account

  def self.authenticate_by_account_number_and_password(account_number, access_password)
    account = Account.find_by(number: account_number)
    if account.blank? || account.user.authenticate(access_password).blank?
      raise StandardError.new, 'Número da conta ou senha incorretos'
    end
    raise StandardError.new, 'Esta conta está encerrada' if account.archived?

    { token: JsonWebToken.encode(user_id: account.user_id) }
  end

  def self.register(name)
    ActiveRecord::Base.transaction do
      access_password = User.generate_access_password
      user = User.create!(name: name, password: access_password)
      user.create_account!

      { access_password: access_password, account_number: user.account.number }
    end
  end

  def self.generate_access_password
    SecureRandom.random_number(9999).to_s.rjust(4, '0')
  end

  def self.decoded_auth_token(token)
    JsonWebToken.decode(token)
  end

  def self.authenticated_user(token)
    decoded_token = User.decoded_auth_token token
    decoded_token ? User.find(decoded_token[:user_id]) : nil
  end
end
