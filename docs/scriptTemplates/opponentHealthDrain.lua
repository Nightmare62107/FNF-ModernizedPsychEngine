function opponentNoteHit()
	health = getProperty('health');
	if getProperty('health') > 0.4 then
		setProperty('health', health- 0.23); -- Drains the players health when opponent hits a note
	end
end