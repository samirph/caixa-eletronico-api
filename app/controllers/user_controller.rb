class UserController < ApplicationController
    def login
        begin
            result = User.authenticate_by_account_number_and_password params[:account_number], params[:access_password]
            render json: result
        rescue StandardError => e 
            puts e.message
            puts e.backtrace
            render json: {message: e.message},status: 400
        end
    end

    def create
        begin
            result = User.register params[:name]
            render json: {
                access_password: result[:access_password], 
                account_number: result[:account_number]
            }
        rescue ActiveRecord::RecordInvalid => e 
            render status: 400, message: e.message
        end
    end
end
