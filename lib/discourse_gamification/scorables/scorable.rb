# frozen_string_literal: true
module ::DiscourseGamification
  class Scorable
    class << self
      def enabled?
        score_multiplier > 0
      end

      def scorable_category_list
        SiteSetting.scorable_categories.split("|").map { _1.to_i }.join(", ")
      end

      def reason
        ""
      end

      def insert_events(since_date)
        DB.exec(<<~SQL, since: since_date, reason: reason)
          DELETE FROM gamification_score_events
          WHERE description = :reason AND date >= :since;

          INSERT INTO gamification_score_events (user_id, date, points, description)
          #{query}
        SQL
      end
    end
  end
end
