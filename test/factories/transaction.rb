FactoryBot.define do
    factory :transaction do
        operation_value {1000.45}
        previous_balance {435}
        origin_account
        target_account
    end
end