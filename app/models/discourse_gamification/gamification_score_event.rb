# frozen_string_literal: true

module ::DiscourseGamification
  class GamificationScoreEvent < ::ActiveRecord::Base
    self.table_name = "gamification_score_events"

    belongs_to :user

    after_create :update_scores

    private

    def update_scores
      DB.exec(<<~SQL, user_id: user_id, date: date, points: points)
        INSERT INTO gamification_scores (user_id, date, score)
        VALUES (:user_id, :date, :points)
        ON CONFLICT (user_id, date) DO UPDATE
        SET score = gamification_scores.score + EXCLUDED.score;
      SQL

      DiscourseGamification::LeaderboardCachedView.refresh_all
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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_gamification_score_events_on_date              (date)
#  index_gamification_score_events_on_user_id_and_date  (user_id,date)
#
