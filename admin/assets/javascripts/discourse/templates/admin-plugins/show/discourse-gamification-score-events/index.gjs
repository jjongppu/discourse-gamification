import RouteTemplate from "ember-route-template";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";
import AdminAwardPoints from "discourse/plugins/discourse-gamification/admin/components/admin-award-points";

export default RouteTemplate(
  <template>
    <DBreadcrumbsItem
      @path="/admin/plugins/{{@controller.adminPluginNavManager.currentPlugin.name}}/score-events"
      @label={{i18n "gamification.admin.score_event_title"}}
    />

    <div class="discourse-gamification__score-events admin-detail">
      <DPageSubheader @titleLabel={{i18n "gamification.admin.score_event_title"}} />
      <AdminAwardPoints />
    </div>
  </template>
);
