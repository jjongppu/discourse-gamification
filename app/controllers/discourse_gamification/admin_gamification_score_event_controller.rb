# frozen_string_literal: true

class DiscourseGamification::AdminGamificationScoreEventController < Admin::AdminController
  requires_plugin DiscourseGamification::PLUGIN_NAME

  def show
    params.permit(%i[id user_id date])

    events = DiscourseGamification::GamificationScoreEvent.limit(100)
    events = events.where(id: params[:id]) if params[:id]
    events = events.where(user_id: params[:user_id]) if params[:user_id]
    events = events.where(date: params[:date]) if params[:date]

    raise Discourse::NotFound unless events

    render_serialized({ events: events }, AdminGamificationScoreEventIndexSerializer, root: false)
  end

  def create
    params.require(%i[user_id date points reason])
    params.permit(:description)

    event = DiscourseGamification::GamificationScoreEvent.record!(
      user_id: params[:user_id],
      date: params[:date],
      points: params[:points],
      reason: params[:reason],
      description: params[:description],
    )

    render_serialized(event, AdminGamificationScoreEventSerializer, root: false)
  end

  def update
    params.require(%i[id points reason])
    params.permit(:description)

    event = DiscourseGamification::GamificationScoreEvent.find(params[:id])
    raise Discourse::NotFound unless event

    if event.update(points: params[:points], reason: params[:reason], description: params[:description] || event.description)
      render json: success_json
    else
      render_json_error(event)
    end
  end
end
