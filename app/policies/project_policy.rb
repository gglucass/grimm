class ProjectPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @project = model
  end

  def index?
    # @current_user.admin?
  end

  def show?
    @current_user.admin? or @project.users.include?(@current_user) or @project.publik?
  end

  def edit?
    @current_user.admin? or @project.users.include?(@current_user) or @project.publik?
  end

  def update?
    @current_user.admin? or @project.users.include?(@current_user) or @project.publik?
  end

  def destroy?
    # return false if @current_user == @user
    # @current_user.admin?
  end

  def toggle_comments?
    @project.users.include?(@current_user)
  end
end