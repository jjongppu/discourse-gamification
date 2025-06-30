module DiscourseGamification
  module EventHooks
    def self.attach
      Post.class_eval do
        after_commit :gamification_record_post, on: :create

        def gamification_record_post
          return if deleted_at.present? || self.topic&.archetype == Archetype.private_message || wiki || hidden

          category_ids = SiteSetting.scorable_categories.split("|").map(&:to_i)
          if category_ids.present? && !category_ids.include?(self.topic&.category_id)
            return
          end

          date = created_at.to_date

          if SiteSetting.post_created_score_value > 0
            DiscourseGamification::GamificationScoreEvent.create!(
              user_id: user_id,
              date: date,
              points: SiteSetting.post_created_score_value,
              description: SiteSetting.post_created_score_reason
            )
          end

          if post_number == 1 && SiteSetting.topic_created_score_value > 0
            DiscourseGamification::GamificationScoreEvent.create!(
              user_id: user_id,
              date: date,
              points: SiteSetting.topic_created_score_value,
              description: SiteSetting.topic_created_score_reason
            )
          elsif post_number != 1 && SiteSetting.first_reply_of_day_score_value > 0
            reason = SiteSetting.first_reply_of_day_score_reason
            unless DiscourseGamification::GamificationScoreEvent.exists?(user_id: user_id, date: date, description: reason)
              DiscourseGamification::GamificationScoreEvent.create!(
                user_id: user_id,
                date: date,
                points: SiteSetting.first_reply_of_day_score_value,
                description: reason
              )
            end
          end
        end
      end

      PostAction.class_eval do
        after_commit :gamification_record_like, on: :create

        def gamification_record_like
          return unless post_action_type_id == PostActionType.types[:like]

          post = self.post
          return if !post || post.deleted_at.present? || post.topic&.archetype == Archetype.private_message || post.wiki

          category_ids = SiteSetting.scorable_categories.split("|").map(&:to_i)
          if category_ids.present? && !category_ids.include?(post.topic&.category_id)
            return
          end

          date = created_at.to_date

          if SiteSetting.like_given_score_value > 0
            DiscourseGamification::GamificationScoreEvent.create!(
              user_id: user_id,
              date: date,
              points: SiteSetting.like_given_score_value,
              description: SiteSetting.like_given_score_reason
            )
          end

          if SiteSetting.like_received_score_value > 0
            DiscourseGamification::GamificationScoreEvent.create!(
              user_id: post.user_id,
              date: date,
              points: SiteSetting.like_received_score_value,
              description: SiteSetting.like_received_score_reason
            )
          end
        end
      end

      UserVisit.class_eval do
        after_commit :gamification_record_visit, on: :create

        def gamification_record_visit
          return if SiteSetting.day_visited_score_value <= 0

          date = visited_at.to_date
          reason = SiteSetting.day_visited_score_reason
          unless DiscourseGamification::GamificationScoreEvent.exists?(user_id: user_id, date: date, description: reason)
            DiscourseGamification::GamificationScoreEvent.create!(
              user_id: user_id,
              date: date,
              points: SiteSetting.day_visited_score_value,
              description: reason
            )
          end
        end
      end
    end
  end
end
