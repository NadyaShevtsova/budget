class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :destroy]

  def index
    @q = current_user.transactions.search(params[:q])
    @q.sorts = ['date desc'] if @q.sorts.empty?
    @transactions = @q.result.includes(:category).page(params[:page])
  end

  def new
    @transaction = Transaction.new
  end

  def edit
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_url, notice: 'Transaction was successfully created.'
    else
      render :new
    end
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_url, notice: 'Transaction was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_url, notice: 'Transaction was successfully destroyed.'
  end

  private
    def set_transaction
      @transaction = current_user.transactions.find(params[:id])
    end

    def transaction_params
      params.require(:transaction).permit(:user_id, :category_id, :income, :date, :amount, :description)
    end
end
