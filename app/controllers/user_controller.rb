class UserController < ApplicationController
    def login
        begin
            result = User.authenticate_by_account_number_and_password params[:accountNumber], params[:accessPassword]
            render json: result
        rescue => e
            render json: {message: e.message}, status: 422
        end
    end

    def create
        result = User.register params[:name]
        render json: {
            access_password: result[:access_password], 
            account_number: result[:account_number]
        }
    end
end
