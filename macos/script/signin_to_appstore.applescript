#!/usr/bin/env osascript
-- script inspired by: https://github.com/tiiiecherle/osx_install_config/blob/master/05_homebrew_and_casks/5b_homebrew_cask/6_mas_appstore.sh
-- due to issues with signin: https://github.com/mas-cli/mas/issues/164

on run argv
  set apple_store_user to item 1 of argv
  set apple_store_pw to item 2 of argv

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
      tell application "System Events" to keystroke apple_store_user
      delay 2
      tell application "System Events" to keystroke return
      delay 2
      tell application "System Events" to keystroke apple_store_pw
      delay 2
      tell application "System Events" to keystroke return

      set apple_store_user to ""
      set apple_store_pw to ""

    end tell
  end tell

  tell application "App Store"
    try
      delay 5
      quit
    end try
  end tell

end run
