# frozen_string_literal: true

class AdminGamificationScoreEventSerializer < ApplicationSerializer
  attributes :id, :user_id, :date, :points, :reason, :description, :created_at, :updated_at
end
