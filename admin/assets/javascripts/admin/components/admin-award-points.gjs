import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import Form from "discourse/components/form";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import BackButton from "discourse/components/back-button";

export default class AdminAwardPoints extends Component {
  @service toasts;
  @service router;

  get formData() {
    return { user_id: "", points: 0, reason: "", description: "" };
  }

  @action
  async award(data) {
    try {
      await ajax("/admin/plugins/gamification/score_events", {
        type: "POST",
        data,
      });

      this.toasts.success({
        duration: 3000,
        data: { message: i18n("gamification.admin.score_event_create_success") },
      });
      this.router.transitionTo(
        "adminPlugins.show.discourse-gamification-score-events"
      );
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    <BackButton
      @route="adminPlugins.show.discourse-gamification-leaderboards"
      @label="gamification.back"
    />
    <Form @data={{this.formData}} @onSubmit={{this.award}} as |form|>
      <form.Field @name="user_id" @title={{i18n "gamification.admin.user_id"}} as |field|>
        <field.Input />
      </form.Field>
      <form.Field @name="points" @title={{i18n "gamification.admin.points"}} as |field|>
        <field.Input type="number" />
      </form.Field>
      <form.Field @name="reason" @title={{i18n "gamification.admin.reason"}} as |field|>
        <field.Input />
      </form.Field>
      <form.Field @name="description" @title={{i18n "gamification.admin.description"}} as |field|>
        <field.Textarea />
      </form.Field>
      <form.Submit @label="gamification.create" />
    </Form>
  </template>
}
