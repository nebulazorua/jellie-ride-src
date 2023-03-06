function onCreate()
	setProperty('camGame.bgColor', getColorFromHex('224D42'))
	-- background shit
	makeLuaSprite('stageback', 'jellie/bg', -1000, -510)
	setScrollFactor('stageback', 0.9, 0.9)
	
	makeLuaSprite('stagefront', 'jellie/bgg', -1220, -630)
	setScrollFactor('stagefront', 0.95, 0.95)
	scaleObject('stagefront', 1.1, 1.1)

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then

		makeLuaSprite('stagecurtains', 'jellie/bushes', -1220, 930)
		setScrollFactor('stagecurtains', 1.1, 1.1)
	end

	addLuaSprite('stageback', false)
	addLuaSprite('stagefront', false)
	addLuaSprite('stagecurtains', true)
	
	close(true) --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end