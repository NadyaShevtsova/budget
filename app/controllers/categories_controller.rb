class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]
  layout 'modal', only: [:new, :edit]
  load_and_authorize_resource

  def index
    @categories = current_user.categories.page(params[:page])
  end

  def edit
  end

  def new
    @category = Category.new
  end

  def create
    @category = current_user.categories.build(category_params)
    if @category.save
      render json: { success: "Category was successfully created.", id: @category.id, name: @category.name }, status: 201, layout: 'modal'
    else
      render json: { errors: @category.errors }, status: 422
    end
  end

  def update
    if @category.update(category_params)
      render json: { success: "Category was successfully updated." , id: @category.id, name: @category.name }, status: 200, layout: 'modal'
    else
      render json: { errors: @category.errors }, status: 422
    end
  end

  def destroy
    if @category.destroy
      render json: { success: "Category was successfully destroyed." }, status: 200
    else
      render json: { error: @category.errors.full_messages.to_sentence }, status: 422
    end
  end

  def sort
    params[:category].each_with_index do |id, index|
      Category.find(id).update_column :position, index+1
    end
    render nothing: true
  end

  private
    def set_category
      @category = current_user.categories.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :user_id)
    end
end
