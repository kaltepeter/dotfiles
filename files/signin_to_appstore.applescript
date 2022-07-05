#!/usr/bin/env osascript
-- script inspired by: https://github.com/tiiiecherle/osx_install_config/blob/master/03_homebrew_casks_and_mas/3b_homebrew_casks_and_mas_install/6_mas_appstore.sh
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
			-- to reset delete ASAcknowledgedOnboardingVersion from ~/Library/Preferences/com.apple.AppStore.plist
			try
				if "$MACOS_VERSION_MAJOR" is equal to "10.14" then
					click button 2 of UI element 1 of sheet 1 of window 1
					#click button "Weiter" of UI element 1 of sheet 1 of window 1
				end if
				if "$MACOS_VERSION_MAJOR" is equal to "10.15" then
					click button 2 of UI element 1 of sheet 1 of window 1
					#click button "Weiter" of UI element 1 of sheet 1 of window 1
				end if
				if "$MACOS_VERSION_MAJOR" is greater than or equal to "11" then
					click button 2 of UI element 1 of sheet 1 of window "App Store"
				end if
				delay 3
			end try
			-- login
			if "$MACOS_VERSION_MAJOR" is equal to "10.14" then
				click menu item 15 of menu "Store" of menu bar item "Store" of menu bar 1
			end if
			if "$MACOS_VERSION_MAJOR" is equal to "10.15" then
				click menu item 16 of menu "Store" of menu bar item "Store" of menu bar 1
			end if
			if "$MACOS_VERSION_MAJOR" is greater than or equal to "11" then
				click menu item 16 of menu "Store" of menu bar item "Store" of menu bar 1
			end if
			#click menu item "Anmelden" of menu "Store" of menu bar item "Store" of menu bar 1
			delay 2
			if "$MACOS_VERSION_MAJOR" is equal to "10.14" then
				set focused of text field "Apple-ID:" of sheet 1 of window 1 to true
			end if
			if "$MACOS_VERSION_MAJOR" is equal to "10.15" then
				set focused of text field "Apple-ID:" of sheet 1 of window 1 to true
			end if
			if "$MACOS_VERSION_MAJOR" is greater than or equal to "11" then
				try
					set focused of text field "Apple-ID:" of sheet 1 of sheet 1 of window "App Store" to true
				on error
					set focused of text field 1 of sheet 1 of sheet 1 of window "App Store" to true
				end try
			end if
			delay 2
			tell application "System Events" to keystroke apple_store_user
			delay 2
			tell application "System Events" to keystroke return
			delay 2
			tell application "System Events" to keystroke apple_store_pw
			delay 2
			tell application "System Events" to keystroke return
			-- leave two factor auth disabled if disabled before
			if "$MACOS_VERSION_MAJOR" is greater than or equal to "11" then
				try
					delay 12
					try
						click button "More Options" of group 6 of group 1 of UI element 1 of scroll area 1 of sheet 1 of sheet 1 of window "App Store"
					on error
						# universal
						click button 1 of group 6 of group 1 of UI element 1 of scroll area 1 of sheet 1 of sheet 1 of window "App Store"
					end try
					delay 5
					try
						click button "Do not update" of sheet 1 of sheet 1 of window "App Store"
					on error
						# universal
						click button 1 of sheet 1 of sheet 1 of window "App Store"
					end try
					delay 5
				end try
			end if

			set apple_store_user to ""
			set apple_store_pw to ""


		end tell
	end tell

	tell application "App Store"
		try
			delay 15
			quit
		end try
	end tell

end run
