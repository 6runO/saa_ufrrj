class Curriculo < ApplicationRecord
  has_many :periodos, dependent: :destroy
end
