# frozen_string_literal: true

class Account < ApplicationRecord
  enum status: %i[active archived]
  belongs_to :user
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
  before_create :generate_account_number

  def deposit(value)
    if value <= 0
      raise StandardError.new, 'Valor da transação deve ser maior que zero'
    end

    ActiveRecord::Base.transaction do
      Transaction.create!(
        target_account: self,
        operation_value: value,
        previous_target_balance: balance,
        operation_type: 'deposit'
      )
      update!(balance: balance + value)
    end
  end

  def withdraw(value)
    if value <= 0
      raise StandardError.new, 'Valor da transação deve ser maior que zero'
    end

    ActiveRecord::Base.transaction do
      Transaction.create!(
        origin_account: self,
        operation_value: value,
        previous_origin_balance: balance,
        operation_type: 'withdraw'
      )
      update!(balance: balance - value)
    end
  end

  def transfer(account_number, value)
    if value <= 0
      raise StandardError.new, 'Valor da transação deve ser maior que zero'
    end

    ActiveRecord::Base.transaction do
      target_account = Account.find_by!(number: account_number)
      if target_account.id == id
        raise StandardError.new, 'Não pode realizar uma transferência de uma conta para ela mesma'
      end

      Transaction.create!(
        target_account: target_account,
        origin_account: self,
        operation_value: value,
        previous_origin_balance: balance,
        previous_target_balance: target_account.balance,
        operation_type: 'transfer'
      )
      update!(balance: balance - value)
      target_account.update!(balance: target_account.balance + value)
    end
  end

  def transactions
    Transaction.where('origin_account_id = ? OR target_account_id = ?', id, id)
  end

  private

  def generate_account_number
    number = nil
    loop do
      number = SecureRandom.random_number(99_999_999)
      break if Account.find_by(number: number).blank?
    end
    self.number = number
  end
end
