#!/usr/bin/env osascript
tell application "App Store"
  try
    activate
    delay 5
  end try
end tell


tell application "System Events"
  tell process "App Store"
    set frontmost to true
    delay 2
    -- on first run when installing the appstore asks for accepting privacy policy
    try
      click button 2 of UI element 1 of sheet 1 of window 1
      delay 3
    end try
    -- login
    click menu item 15 of menu "Store" of menu bar item "Store" of menu bar 1
    delay 2
    tell application "System Events" to keystroke "${apple_store_user}"
    delay 2
    tell application "System Events" to keystroke return
    delay 2
    tell application "System Events" to keystroke "${apple_store_pw}"
    delay 2
    tell application "System Events" to keystroke return
  end tell
end tell

tell application "App Store"
  try
    delay 10
    quit
  end try
end tell
