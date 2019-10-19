class AccountController < ApplicationController
    before_action :require_authorization
    before_action :authenticate_operation, only: [:withdraw, :transfer]

    def show
        render json: current_user.to_json(:include => :account)
    end

    def withdraw
        begin
            current_user.account.withdraw params[:withdraw_value].to_d
            render json: {message: 'Saque efetuado'}, status: 200
        rescue ActiveRecord::RecordInvalid => e
            render json: {message: 'Saldo insuficiente'}, status: 400
        rescue => e
            render json: {message: e.message}, status: 422
        end
    end

    def deposit
        begin
            current_user.account.deposit params[:deposit_value].to_d
            render json: {message: 'Depósito efetuado'}, status: 200
        rescue => e
            render json: {message: e.message}, status: 422
        end
    end

    def transfer
        if params[:accountNumber].blank? || params[:transferValue].blank?
            render json: {message: 'Dados necessários não informados'}, status: 400
            return
        end
       
        begin
            current_user.account.transfer params[:accountNumber], params[:transferValue].to_d
            render json: {message: 'Transferência efetuada'}, status: 200
        rescue ActiveRecord::RecordNotFound=> e
            render json: {message: 'Número de conta inválido'}, status: 400
        rescue => e
            render json: {message: e.message}, status: 422
        end
    end

    def archive
        current_user.account.archived!
        render json: {message: 'Conta encerrada'}, status: 200
    end

    private

    def authenticate_operation
        begin
            User.authenticate_by_account_number_and_password current_user.account.number, params[:accessPassword] 
        rescue StandardError => e
            render json: {message: 'Não autorizado'}, status: 401
        end
    end
end
