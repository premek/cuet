local conf = {}

function love.conf(t)
  t.version = "11.1"                -- The LÖVE version this game was made for (string)
  t.window.title = "Cuet"        -- The window title (string)
  t.window.fullscreen = false        -- Enable fullscreen (boolean)
  --  t.window.fullscreentype = "normal" -- Standard fullscreen or desktop fullscreen mode (string)
  t.window.width = 720*0.7
  t.window.height = 1280*0.7
  t.window.resizable = true

  t.externalstorage = true
  t.audio.mixwithsystem = false -- true: Keep background music playing when opening LOVE (boolean, iOS and Android only)
  conf.t = t

end
return conf
