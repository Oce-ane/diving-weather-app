class DiveSite < ActiveRecord::Base
  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name

  belongs_to :country
end
