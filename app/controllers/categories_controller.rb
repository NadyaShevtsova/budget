class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]

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
      redirect_to categories_url, notice: "Category was successfully created"
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_url, notice: "Category was successfully updated."
    else
      render :edit
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
