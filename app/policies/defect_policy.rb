class DefectPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    require pry;binding.pry
    @model = model
  end

  # def index?
  #   # @current_user.admin?
  #   true
  # end

  # def show?
  #   # @current_user.admin? or 
  #   @current_user == @user
  # end

  # def update?
  #   # @current_user.admin?
  # end

  # def destroy?
  #   # return false if @current_user == @user
  #   # @current_user.admin?
  # end

  def create_comments?
    require 'pry';binding.pry
    true
  end

end