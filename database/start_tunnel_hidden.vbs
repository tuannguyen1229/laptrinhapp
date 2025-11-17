Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /c cloudflared tunnel run library-tunnel", 0, False
Set WshShell = Nothing
