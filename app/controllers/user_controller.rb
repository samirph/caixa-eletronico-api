# frozen_string_literal: true

class UserController < ApplicationController
  def login
    result = User.authenticate_by_account_number_and_password params[:account_number], params[:access_password]
    render json: result
  rescue StandardError => e
    render json: { message: e.message }, status: 400
  end

  def create
    result = User.register params[:name]
    render json: {
      access_password: result[:access_password],
      account_number: result[:account_number]
    }
  rescue ActiveRecord::RecordInvalid => e
    render status: 400, message: e.message
  end
end
