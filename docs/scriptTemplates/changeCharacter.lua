function onCreate()
	-- triggered when the lua file is started
	addCharacterToList('pico-player', 'boyfriend');
	addCharacterToList('bf-christmas', 'boyfriend');
	addCharacterToList('bf', 'boyfriend');
	addCharacterToList('dad', 'dad');
	addCharacterToList('parents-christmas', 'dad');
	addCharacterToList('bf-pixel-opponent', 'dad');
end

function onUpdate(elapsed)
	-- start of "update", some variables weren't updated yet
	if keyJustPressed('left') then
		triggerEvent('Change Character', 0, 'bf-christmas');
		triggerEvent('Change Character', 1, 'parents-christmas');
	elseif keyJustPressed('down') then
		triggerEvent('Change Character', 0, 'bf');
		triggerEvent('Change Character', 1, 'dad');
	elseif keyJustPressed('up') then
		triggerEvent('Change Character', 0, 'bf-car');
		triggerEvent('Change Character', 1, 'mom-car');
	elseif keyJustPressed('right') then
		triggerEvent('Change Character', 0, 'pico-player');
		triggerEvent('Change Character', 1, 'bf-pixel-opponent');
	end
end