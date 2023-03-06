function onEvent(name,value1,value2)
	if name == 'changeLyrics' then
	makeLuaText('bruhtxt', value1, 1250 , 0, 540)
	setTextSize('bruhtxt', 30)
	addLuaText('bruhtxt')
	setObjectCamera('bruhtxt', 'other')
	setTextString(value1)
	end
end
