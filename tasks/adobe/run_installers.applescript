#!/usr/bin/env osascript
on run argv
  set app_file to (item 1 of argv)
  set mounted_disk to (item 2 of argv)
  tell application "Finder"
    activate
    open application file app_file of disk mounted_disk
  end tell

  set app_file to ""
  set mounted_disk to ""
end run
