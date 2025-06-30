# frozen_string_literal: true

class DiscourseGamification::CheckInsController < ApplicationController
  requires_plugin DiscourseGamification::PLUGIN_NAME
  before_action :ensure_logged_in

  def create
    today = Date.current
    reason = SiteSetting.day_visited_score_reason

    existing = DiscourseGamification::GamificationScoreEvent.find_by(
      user_id: current_user.id,
      date: today,
      reason: reason,
    )

    if existing
      render json: { points_awarded: false, points: 0 }
    else
      event = DiscourseGamification::GamificationScoreEvent.record!(
        user_id: current_user.id,
        date: today,
        points: SiteSetting.day_visited_score_value,
        reason: reason,
      )

      render json: { points_awarded: true, points: event.points }
    end
  end
end
