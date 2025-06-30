# frozen_string_literal: true

module ::DiscourseGamification
  class GamificationScoreEvent < ::ActiveRecord::Base
    self.table_name = "gamification_score_events"

    belongs_to :user

    after_commit :increment_score, on: :create
    after_commit :update_score, on: :update
    after_commit :decrement_score, on: :destroy

    validates :reason, presence: true

    def self.record!(user_id:, points:, date: Date.today, reason:, description: nil)
      create!(user_id: user_id, points: points, date: date, reason: reason, description: description)
    end

    private

    def increment_score
      GamificationScore.adjust_score(user_id: user_id, date: date, points: points)
    end

    def update_score
      diff = points - points_before_last_save
      return if diff == 0

      GamificationScore.adjust_score(user_id: user_id, date: date, points: diff)
    end

    def decrement_score
      GamificationScore.adjust_score(user_id: user_id, date: date, points: -points)
    end
  end
end

# == Schema Information
#
# Table name: gamification_score_events
#
#  id          :bigint           not null, primary key
#  user_id     :integer          not null
#  date        :date             not null
#  points      :integer          not null
#  description :text
#  reason      :string           default("")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_gamification_score_events_on_date              (date)
#  index_gamification_score_events_on_user_id_and_date  (user_id,date)
#
