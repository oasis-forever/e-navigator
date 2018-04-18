class InterviewsController < ApplicationController
  before_action :set_user, only: [:index, :new, :create]
  before_action :set_interview, only: [:edit, :update, :destroy, :approve]

  # GET /users/:user_id/interviews
  def index
    @interviews = @user.interviews.order(datetime: 'asc')
    @approved_interview = @interviews.find_by(status: 1)
  end

  # GET /users/:user_id/interviews/new
  def new
    @interview = Interview.new
  end

  # POST /users/:user_id/interviews
  def create
    unless current_user?(@user.id)
      flash[:notice] = "他のユーザーの面接日時の登録は許可されていません"
      redirect_to users_path
    else
      @interview = @user.interviews.new(interview_params)
      if @interview.save
        flash[:notice] = "面接日時を登録しました"
        redirect_to user_interviews_path
      else
        render :new
      end
    end
  end

  # GET /users/:user_id/interviews/:id/edit
  def edit
  end

  # PATCH /users/:user_id/interviews/:id
  def update
    unless current_user?(@interview.user.id)
      flash[:notice] = "他のユーザーの面接日時の変更は許可されていません"
      redirect_to users_path
    else
      @interview.update(interview_params)
      flash[:notice] = "面接日時を変更しました"
      redirect_to user_interviews_path
    end
  end

  # DELETE /users/:user_id/interviews/:id
  def destroy
    @interview.destroy
    flash[:notice] = "面接日時を削除しました"
    redirect_to user_interviews_path
  end

  # POST /users/:user_id/interviews/:id/approve
  def approve
    @interview.approved!
    # 以下、承認した日時以外を否認状態にする
    interviews = Interview.where(user_id: @interview.user_id).where.not(id: @interview.id)
    interviews.each do |interview|
      interview.declined!
    end
    flash[:notice] = "面接日時を承認しました"
    redirect_to user_interviews_path
  end

  private

    def set_user
      @user = User.find_by(id: params[:user_id])
    end

    def set_interview
      @interview = Interview.find(params[:id])
    end

    def interview_params
      params.require(:interview).permit(:datetime)
    end

    def current_user?(id)
      id == current_user
    end
end
