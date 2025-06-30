class AddReasonToGamificationScoreEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :gamification_score_events, :reason, :string, null: false, default: ""
  end
end
