import { ajax } from "discourse/lib/ajax";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

export default {
  name: "gamification-attendance-toast",
  initialize() {
    withPluginApi("1.1.0", (api) => {
      const currentUser = api.getCurrentUser();
      if (!currentUser) {
        return;
      }
      ajax("/leaderboard/attendance.json").then((result) => {
        if (result.points && result.points > 0) {
          api.container.lookup("service:toasts").success({
            duration: 3000,
            data: { message: i18n("gamification.attendance_awarded", { points: result.points }) },
          });
        }
      });
    });
  },
};
