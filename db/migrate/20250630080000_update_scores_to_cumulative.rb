# frozen_string_literal: true

class UpdateScoresToCumulative < ActiveRecord::Migration[7.0]
  def up
    remove_index :gamification_scores, [:user_id, :date]

    if column_exists?(:gamification_scores, :created_at)
      execute <<~SQL
        DELETE FROM gamification_scores gs
        USING (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn
          FROM gamification_scores
        ) AS dups
        WHERE gs.id = dups.id
          AND dups.rn > 1;
      SQL
    else
      execute <<~SQL
        DELETE FROM gamification_scores gs
        USING (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY id DESC) AS rn
          FROM gamification_scores
        ) AS dups
        WHERE gs.id = dups.id
          AND dups.rn > 1;
      SQL
    end

    add_index :gamification_scores, :user_id, unique: true

    execute "DELETE FROM gamification_scores"

    execute <<~SQL
      WITH summed AS (
        SELECT user_id, SUM(score) AS score
        FROM gamification_scores
        GROUP BY 1
      )
      INSERT INTO gamification_scores (user_id, score, date)
      SELECT user_id, score, CURRENT_DATE FROM summed;
    SQL
  end

  def down
    remove_index :gamification_scores, :user_id
    add_index :gamification_scores, [:user_id, :date], unique: true
  end
end
