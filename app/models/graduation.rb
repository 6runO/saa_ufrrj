class Graduation < ApplicationRecord
    has_many :periods, dependent: :destroy
end
