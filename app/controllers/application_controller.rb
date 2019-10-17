class ApplicationController < ActionController::API

    private

    def access_token
        @access_token = request.headers['Authorization']
    end

    def current_user
        User.authenticated_user access_token
    end

    def require_authorization
        if !current_user
            render json: {message: 'Não autorizado'}, status: 401
        end
    end
end
