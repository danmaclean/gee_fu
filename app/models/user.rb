class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :last_name, :first_name, :affiliation, :role, :admin

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_paper_trail
end