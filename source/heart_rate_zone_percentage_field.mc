using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.ActivityMonitor as Act;
using Toybox.System as Sys;
using Toybox.Activity as Activity;

class HeartRateZonePercentageField extends Ui.SimpleDataField {
    // Declare zoneTimes as an array of numbers
    var zoneTimes = [0, 0, 0, 0, 0]; // Time spent in Zone 1 to Zone 5
    var lastUpdateTime = 0; // Timestamp of the last update
    var totalElapsedTime = 0; // Total elapsed time of the activity

    function initialize() {
        SimpleDataField.initialize();
        label = "HR Live Zone Ratio";
    }

    // Function to determine the current heart rate zone
    function getHeartRateZone(heartRate, maxHeartRate) {
        if (heartRate == null || maxHeartRate == null) {
            return -1; // Invalid data
        }

        var zonePercentage = (heartRate.toFloat() / maxHeartRate) * 100;

        if (zonePercentage < 50) {
            return 0; // Below Zone 1
        } else if (zonePercentage < 60) {
            return 1; // Zone 1
        } else if (zonePercentage < 70) {
            return 2; // Zone 2
        } else if (zonePercentage < 80) {
            return 3; // Zone 3
        } else if (zonePercentage < 90) {
            return 4; // Zone 4
        } else {
            return 5; // Zone 5
        }
    }

    // Function to compute the percentage of time spent in each zone
    function compute(info) {
        var currentTime = Sys.getTimer();
        var heartRate = info.currentHeartRate;
        var maxHeartRate = info.maxHeartRate;

        if (heartRate == null || maxHeartRate == null) {
            return "No HR Data"; // Return a single string if no heart rate data is available
        }

        // Calculate elapsed time since the last update
        if (lastUpdateTime > 0) {
            var elapsedTime = currentTime - lastUpdateTime;
            totalElapsedTime += elapsedTime;

            // Determine the current heart rate zone
            var zone = getHeartRateZone(heartRate, maxHeartRate);
            if (zone >= 1 && zone <= 5) {
                // Explicitly cast the values to ensure type safety
                zoneTimes[zone - 1] = zoneTimes[zone - 1].toNumber() + elapsedTime.toNumber();
            }
        }

        lastUpdateTime = currentTime;

        // Initialize percentages array with default values
        var percentages = ["0.0%", "0.0%", "0.0%", "0.0%", "0.0%"];

        // Calculate percentages for each zone
        for (var i = 0; i < zoneTimes.size(); i++) {
            if (totalElapsedTime > 0) {
                var percentage = (zoneTimes[i].toFloat() / totalElapsedTime.toFloat()) * 100;
                percentages[i] = percentage.format("%.1f") + "%";
            }
        }

        // Return a single formatted string
        return "Z1: " + percentages[0] + " Z2: " + percentages[1] + " Z3: " + percentages[2] + " Z4: " + percentages[3] + " Z5: " + percentages[4];
    }

    // Function to draw the data field on the screen
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        var info = Activity.getActivityInfo();
        var percentages = compute(info);

        // Draw the percentages on the screen
        var y = 10; // Starting Y position for text
        var zoneLabels = ["Z1: ", "Z2: ", "Z3: ", "Z4: ", "Z5: "];
        for (var i = 0; i < zoneLabels.size(); i++) {
            dc.drawText(dc.getWidth() / 2, y, Gfx.FONT_SMALL, zoneLabels[i] + percentages[i], Gfx.TEXT_JUSTIFY_CENTER);
            y += 20; // Move down for the next line
        }
    }
}