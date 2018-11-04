--local conf = require('conf').t
local lg = love.graphics


local color = {
	fg = {1,1,1},
	bg = {0,0,0},
	playing = {0.3, 0.5, 0.3, 0.8},
	warn = {0.7, 0.3, 0.3},
	volume = {1,1,1, 0.7}
}

local files={}
local dir
local sources = {}
local waveforms = {}


local dragy = false
local scroll = 0
local selected = nil
local dragvol = nil


local lgw, lgh = lg.getDimensions()

local w = lgw-120-50


function love.load()
	dir = love.filesystem.getSaveDirectory();
	print(dir)

 for _, file in ipairs(love.filesystem.getDirectoryItems("")) do
  local ext = string.sub(file, -3)
  if ext == "mp3" or ext=="wav" then -- TODO
   table.insert(files, file)
   print(file)
  end
 end
 print("files: "..#files)

 for k, file in ipairs(files) do
	 print("Loading", file)
  sources[k] = love.audio.newSource(file, "stream")

  waveforms[k] = lg.newCanvas(w, 50)

--[[----------------------

local samplesTotal = sources[k]:getDuration("samples")
print("samples", samplesTotal)


local samplesPerPixel = math.max(1, samplesTotal/w)
print(samplesPerPixel)


local decoder = love.sound.newDecoder( file, 10000 )

waveforms[k] = lg.newCanvas(w, 50)
    lg.setCanvas(waveforms[k])
    lg.setColor(color.volume)



local x = 0
local avgWindow = 2
local currentPixelSamplesLoaded = 0
local countAvg = 0
local avg = 0
local skipSamples = 300

while true do
	local soundData = decoder:decode()
	if not soundData then break end
	for s=0, soundData:getSampleCount()-1, skipSamples do

		currentPixelSamplesLoaded = currentPixelSamplesLoaded+skipSamples
		if currentPixelSamplesLoaded >= samplesPerPixel then
			currentPixelSamplesLoaded = currentPixelSamplesLoaded - samplesPerPixel
			x=x+1
			countAvg = avgWindow
		end

		if countAvg>0 then
			avg = avg + math.abs(soundData:getSample(s))
			countAvg = countAvg -1
			if countAvg == 0 then
				avg = avg / avgWindow
				lg.line(x, 50, x, 50-50*avg)
				avg = 0
			end
		end
	end
end
    lg.setCanvas()


end--------------]]


 end

 love.graphics.newFont(15)
end





local function secToMin(seconds)
  seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00";
  else
    local mins = string.format("%02.f", math.floor(seconds/60));
    local secs = string.format("%02.f", math.floor(seconds - mins *60));
    return mins..":"..secs
  end
end

function love.draw()
	lg.setColor(color.fg)


for k, file in ipairs(files) do

	local s = sources[k]
	local pos = s:tell("seconds")
	local dur = s:getDuration("seconds")
	local progress = pos/dur
	local vol = s:getVolume()

	lg.setColor(color.fg)
	lg.draw(waveforms[k], 115.5, 0.5+scroll+40-10+k*55)

	lg.setColor(color.playing)
	if progress>0.85 then lg.setColor(color.warn) end
	lg.rectangle('fill', 115.5, 0.5+scroll+40-10+k*55, (w)*progress, 50)
	lg.setColor(color.fg)
	lg.rectangle('line', 115.5, 0.5+scroll+40-10+k*55, (w)*progress, 50)

	--if k == selected then lg.setLineWidth(3) end
	lg.rectangle('line', 115.5, 0.5+scroll+40-10+k*55, w, 50)
	lg.setLineWidth(1)
	lg.print(file, 120, scroll+35+k*55)

	lg.print(secToMin(pos), 120, scroll+50+k*55)
	lg.print("-"..secToMin(dur-pos), 190, scroll+50+k*55)

	-- left btn
	if s:isPlaying() then
          lg.setColor(color.playing)
	  lg.rectangle('fill', 5.5, 0.5+scroll+40-10+k*55, 50, 50)
	end
	lg.setColor(color.fg)
	lg.rectangle('line', 5.5, 0.5+scroll+30+k*55, 50, 50)
	lg.printf(s:isPlaying() and "II" or ">", 5, scroll+50+k*55, 50, "center")

	lg.setColor(color.volume)
	lg.rectangle('fill', 60.5, 0.5+scroll+40-10+k*55+(1-vol)*50, 50, vol*50)
	lg.setColor(color.fg)
	lg.line(60.5, 0.5+scroll+40-10+k*55+50, 60.5+50, 0.5+scroll+40-10+k*55+50)
	lg.rectangle('line', 60.5, 0.5+scroll+30+k*55, 50, 50)
	lg.printf(math.floor(vol*10)/10, 60, scroll+50+k*55, 50, "center")


end

-- toolbar
	lg.setColor(color.bg)
lg.rectangle("fill", lgw-54, 0, 99, lgh)
lg.rectangle("fill", 0,0, lgw, 60)
	lg.setColor(color.fg)
	if selected ~= nil then
          lg.print(files[selected], 70, 10)
          lg.print(secToMin(sources[selected]:getDuration("seconds")), 70, 30)
        else
          lg.printf(dir, 70, 10, lgw-20, 'left')
	end


	lg.setColor(color.fg)
	lg.rectangle('line', 5.5, 5.5, 50, 50)
	lg.printf("[ ]", 5, 23, 50, 'center')


end

function love.update(_dt)
end



local function stopAll()
 for _, s in ipairs(sources) do
  s:stop()
 end
end

local function getSelected(y)
    local sel = math.floor((y-scroll-50+15)/55)
    if sel <= 0 or sel > #files then
	    return nil
    end
    return sel
end

function love.mousepressed(x, y, _btn, _touch)
    if x > lgw-50 then
	dragy = y
    elseif x<120 and x>60 then
	    dragvol = getSelected(y)
    end
end



function love.mousereleased(x, y, _button)

if y < 50 then
  if x<50 then stopAll() end
else
  --if not drag then
    selected = getSelected(y)
    if selected ~= nil then
      local s = sources[selected]
      if x < 50 then
	    if s:isPlaying() then s:stop()
	    else s:play()
	    end
      elseif x<lgw-50 then
	       s:seek(math.min(1, math.max(0, (x-116)/w))*s:getDuration("samples"), "samples")
      end
    end
 end
  --end
  dragy = false
  dragvol = nil

end

function love.mousemoved(_x, _y, _dx, dy, _touch)
  if dragy then
    scroll = scroll + dy
  elseif nil~=dragvol then
    sources[dragvol]:setVolume(math.min(1, math.max(0, sources[dragvol]:getVolume() - dy/300)))

  end
end



function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end



