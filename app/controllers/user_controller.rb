class UserController < ApplicationController
    def login
        result = User.authenticate_by_account_number_and_password params[:accountNumber], params[:accessPassword]
        render json: result
    end

    def create
        result = User.register params[:name]
        render json: {
            access_password: result[:access_password], 
            account_number: result[:account_number]
        }
    end
end
