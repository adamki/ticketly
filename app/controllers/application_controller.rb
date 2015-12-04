class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authorize!
  before_action :set_cart
  helper_method :format_url_name, :count_of_trips,
                :pursuits_in_cart, :current_user, :current_vendor?


  def current_permission
    @current_permission ||= PermissionService.new(current_user)
  end

  def set_cart
    @cart = Cart.new(session[:cart])
  end

  def current_vendor?
    current_user && current_user.vendor_admin?
  end

  def format_url_name(name)
    name.downcase.gsub(" ", "_")
  end

  def find_category_by_name(name)
    formatted_name = name.tr("_"," ").titleize
    Category.find_by_name(formatted_name)
  end

  def count_of_trips
    @cart.total_trips
  end

  def current_user
    @user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_admin
    render file: "./test/public/404" unless current_admin
  end

  def authorize!
      unless authorized?
      flash[:auth] = "you are not authorized to view this content."
      redirect_to root_url
    end
  end

  def authorized?
    current_permission.allow?(params[:controller], params[:action])
  end
end
