require 'rails_helper'

RSpec.describe 'Accepted solution deletion' do
  fab!(:question_user) { Fabricate(:user) }
  fab!(:answer_user) { Fabricate(:user) }
  fab!(:topic) { Fabricate(:topic, user: question_user) }
  fab!(:answer_post) { Fabricate(:post, topic: topic, user: answer_user) }

  before do
    SiteSetting.discourse_gamification_enabled = true
    SiteSetting.accepted_solution_event_score_value = 5
    SiteSetting.accepted_solution_topic_event_score_value = 2
    DiscourseSolved.accept_answer!(answer_post, Discourse.system_user)
  end

  it 'withdraws points when the accepted post is deleted' do
    PostDestroyer.new(Discourse.system_user, answer_post).destroy

    expect(
      DiscourseGamification::GamificationScoreEvent.where(
        reason: 'accepted_solution_removed',
        description: '게시글 삭제로 인한 포인트 회수'
      ).count
    ).to eq(1)

    expect(
      DiscourseGamification::GamificationScoreEvent.where(
        reason: 'accepted_solution_topic_removed',
        description: '게시글 삭제로 인한 포인트 회수'
      ).count
    ).to eq(1)
  end
end
