using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.UserProfile as UserProfile;

class HeartRateZonePercentageField extends Ui.DataField {

    function initialize() {
        DataField.initialize();
    }

    // onUpdate is called periodically to update the display
    function onUpdate(dc) {
        // Set colors and clear the display
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        // Get activity info
        var info = Activity.getActivityInfo();
        var heartRate = info.currentHeartRate;

        // If HR data is not available, display a message
        if (heartRate == null) {
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Gfx.FONT_SMALL, "No HR Data", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // Get user's heart rate zones
        var userZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());

        // Determine the current heart rate zone
        var zone = 0;
        for (var i = userZones.size() - 1; i >= 0; i--) {
            if (heartRate >= userZones[i]) {
                zone = i + 1; // zones are 1-based
                break;
            }
        }
        
        var zoneText = "Z" + zone;
        if (zone == 0) {
            zoneText = "Z-";
        }

        // --- Drawing ---
        
        // Draw Heart Rate
        var hrText = heartRate.toString();
        var hrFont = Gfx.FONT_NUMBER_THAI_HOT;
        var zoneFont = Gfx.FONT_SMALL;

        var hrY = dc.getHeight() / 2;
        var zoneY = hrY + dc.getFontHeight(hrFont) / 2;


        dc.drawText(dc.getWidth() / 2, hrY, hrFont, hrText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

        // Draw Zone
        dc.drawText(dc.getWidth() / 2, zoneY, zoneFont, zoneText, Gfx.TEXT_JUSTIFY_CENTER);
    }
}
