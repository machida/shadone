# frozen_string_literal: true

class Api::PracticesController < ApplicationController
  def create
    @practice = Practice.find_or_initialize_by(practice_params)

    respond_to do |format|
      if @practice.save
        format.json { redirect_to 'top', status: :created, location: @practice }
      else
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def practice_params
    params.require(:practice).permit(:user_id, :practice_id, :url, :duration, :practice_on)
  end
end
