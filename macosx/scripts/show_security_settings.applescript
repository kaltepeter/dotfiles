#!/usr/bin/env osascript

tell application "System Preferences"
    try
        activate
        delay 5
    end try
end tell


tell application "System Events"
    tell process "System Preferences"
        set frontmost to true
        delay 2
        click button "Show All" of group 1 of group 2 of toolbar of window 1
        delay 2
        click button "Security
& Privacy" of scroll area 1 of window 1
    end tell
end tell
