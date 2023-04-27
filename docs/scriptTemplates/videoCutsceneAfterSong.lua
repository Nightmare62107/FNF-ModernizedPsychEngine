function onEndSong()
	if not allowEndShit and isStoryMode and not seenCutscene then -- Block endshit
		startVideo('');
		allowEndShit = true;
		return Function_Stop;
	end
	return Function_Continue;
end