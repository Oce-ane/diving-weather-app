class Country < ActiveRecord::Base
  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name

  has_many :dive_sites
end
