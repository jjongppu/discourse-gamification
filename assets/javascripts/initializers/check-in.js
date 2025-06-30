import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";

export default {
  name: "discourse-gamification-check-in",
  initialize() {
    withPluginApi("1.2.0", (api) => {
      if (!api.getCurrentUser()) {
        return;
      }
      ajax("/gamification/check-in.json", { method: "POST" }).then((result) => {
        if (result.points_awarded) {
          api.addFlash(I18n.t("gamification.check_in_awarded", { points: result.points }), "success");
        }
      });
    });
  },
};
