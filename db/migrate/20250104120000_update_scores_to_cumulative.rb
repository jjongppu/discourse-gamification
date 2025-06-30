# frozen_string_literal: true

class UpdateScoresToCumulative < ActiveRecord::Migration[7.0]
  def up
    remove_index :gamification_scores, [:user_id, :date]
    add_index :gamification_scores, :user_id, unique: true

    execute <<~SQL
      WITH summed AS (
        SELECT user_id, SUM(score) AS score
        FROM gamification_scores
        GROUP BY 1
      )
      DELETE FROM gamification_scores;
      INSERT INTO gamification_scores (user_id, score, date)
      SELECT user_id, score, CURRENT_DATE FROM summed;
    SQL
  end

  def down
    remove_index :gamification_scores, :user_id
    add_index :gamification_scores, [:user_id, :date], unique: true
  end
end
