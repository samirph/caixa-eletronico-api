# frozen_string_literal: true

class AccountController < ApplicationController
  before_action :require_authorization
  before_action :authenticate_operation, only: %i[withdraw transfer]

  def show
    render json: current_user.to_json(include: :account)
  end

  def withdraw
    current_user.account.withdraw params[:withdraw_value].to_d
    render json: { message: 'Saque efetuado' }, status: :ok
  rescue ActiveRecord::RecordInvalid
    render json: { message: 'Saldo insuficiente' }, status: :bad_request
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def deposit
    current_user.account.deposit params[:deposit_value].to_d
    render json: { message: 'Depósito efetuado' }, status: :ok
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def transfer
    if params[:accountNumber].blank? || params[:transferValue].blank?
      render json: { message: 'Dados necessários não informados' }, status: :bad_request
      return
    end

    begin
      current_user.account.transfer params[:accountNumber], params[:transferValue].to_d
      render json: { message: 'Transferência efetuada' }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { message: 'Número de conta inválido' }, status: :bad_request
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end

  def archive
    current_user.account.archived!
    render json: { message: 'Conta encerrada' }, status: :ok
  end

  private

  def authenticate_operation
    User.authenticate_by_account_number_and_password current_user.account.number, params[:accessPassword]
  rescue StandardError
    render json: { message: 'Não autorizado' }, status: :unauthorized
  end
end
