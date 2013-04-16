class UsersController < ApplicationController
  def index
    opt = {}
    opt.merge!({order_var:  params[:order_var]})  if params[:order_var]
    opt.merge!({order_sort: params[:order_sort]}) if params[:order_sort]
    opt.merge!({start:      params[:start]})      if params[:start]
    opt.merge!({num:        params[:num]})        if params[:num]
    @users = User.top opt
    @no_side_bar = true
  end
  def show
    @user = User.find params[:id]
  end
end