tell application "System Events"
    tell process "WhatsApp"
        set winCount to count of windows
        if winCount > 0 then
            set winProps to properties of window 1
            return winProps
        else
            return "No windows found for WhatsApp"
        end if
    end tell
end tell
