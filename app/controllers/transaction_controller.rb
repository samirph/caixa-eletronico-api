# frozen_string_literal: true

class TransactionController < ApplicationController
  def index
    render json: current_user.account.transactions
  end
end
