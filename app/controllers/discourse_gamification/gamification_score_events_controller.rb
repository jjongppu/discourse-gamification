# frozen_string_literal: true

class DiscourseGamification::GamificationScoreEventsController < ApplicationController
  requires_plugin DiscourseGamification::PLUGIN_NAME

  before_action :ensure_logged_in

  def attendance
    reason = SiteSetting.day_visited_score_reason
    event = DiscourseGamification::GamificationScoreEvent.find_by(
      user_id: current_user.id,
      date: Date.today,
      description: reason,
    )

    render json: { points: event&.points.to_i }
  end
end
