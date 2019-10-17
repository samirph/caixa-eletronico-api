class Account < ApplicationRecord
  belongs_to :user
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
  before_create :generate_account_number

  def deposit value
    raise StandardError.new(), 'Valor da transação deve ser maior que zero' if value <= 0
    ActiveRecord::Base.transaction do
      Transaction.create!(
        target_account: self,
        operation_value: value,
        previous_target_balance: self.balance,
        operation_type: 'deposit')
      self.update!(balance: self.balance + value)
    end
  end

  def withdraw value
    raise StandardError.new(), 'Valor da transação deve ser maior que zero' if value <= 0
    ActiveRecord::Base.transaction do
      Transaction.create!(
        origin_account: self,
        operation_value: value,
        previous_origin_balance: self.balance,
        operation_type: 'withdraw')
      self.update!(balance: self.balance - value)
    end
  end

  def transfer account_number, value
    raise StandardError.new(), 'Valor da transação deve ser maior que zero' if value <= 0
    ActiveRecord::Base.transaction do
      target_account = Account.find_by!(number: account_number)
      raise StandardError.new(), 'Não pode realizar uma transferência de uma conta para ela mesma' if target_account.id == self.id
      Transaction.create!(
        target_account: target_account,
        origin_account: self,
        operation_value: value,
        previous_origin_balance: self.balance,
        previous_target_balance: target_account.balance,
        operation_type: 'transfer')
      self.update!(balance: self.balance - value)
      target_account.update!(balance: target_account.balance + value)
    end
  end

  def transactions
    Transaction.where("origin_account_id = ? OR target_account_id = ?", self.id, self.id)
  end

  private

  def generate_account_number
    number = nil
    loop do 
      number = SecureRandom.random_number(99999999)
      break if Account.find_by(number: number).blank?
    end
    self.number = number
  end
end
