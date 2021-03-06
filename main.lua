-- Goals
-- Colors!
-- Set Square / toroid
-- Set Brush Size
-- Stroke Interpolation
-- Presets / Load / Save

function love.load()
  math.randomseed(os.time())                                            -- LOAD LOAD LOAD
  debug = true                                                        -- this time I am logging everything
  colorLatch = {}   --HACK
  SCREEN = {}                                                         -- dont change these things... yet
  SCREEN.WIDTH, SCREEN.HEIGHT, SCREEN.FLAGS = love.window.getMode()
  session = {}
  session.time = 0
  love.window.setTitle('um... I had something for this')
  titleFont = love.graphics.newFont(100)
  bodyFont = love.graphics.newFont(20)
  smallFont = love.graphics.newFont(20)
  layout = newLayout()
  user = newUser()
  canvas = newButtonArray(user.screenSize, user.screenSize, layout.canvas)
  palette = newPalette()
  love.graphics.setBackgroundColor(layout.background.color)
  -- TEXT MENU
  clearButton = newButton(layout.tab, layout.tab, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  clearButton.debounceLatch = 0
  guideButton = newButton(layout.tab, clearButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  guideButton.debounceLatch = 0
  golButton = newButton(layout.tab, guideButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  golButton.debounceLatch = 0
  solidButton = newButton(layout.tab, golButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  solidButton.debounceLatch = 0
  frameUpButton = newButton(layout.tab, solidButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  frameUpButton.debounceLatch = 0
  frameDownButton = newButton(layout.tab, frameUpButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  frameDownButton.debounceLatch = 0
  makeBiggerButton = newButton(layout.tab, frameDownButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  makeBiggerButton.debounceLatch = 0
  makeSmallerButton = newButton(layout.tab, makeBiggerButton.y.max, layout.palette.dim / 8, layout.palette.dim, {255, 255, 255, 255})
  makeSmallerButton.debounceLatch = 0
  gameoflife = {}
  gameoflife.solid = true
  gameoflife.toggle = false
  gameoflife.update = 0
  print('hi')
end

function love.update(dt)                                              -- UPDATE UPDATE UPDATE
  session.time = session.time + dt
  if love.mouse.isGrabbed then                                        -- mouse moved callback doesnt give any better resolution
    user.previousx = user.x
    user.previousy = user.y
    user.x = love.mouse.getX()
    user.y = love.mouse.getY()
    if love.mouse.isDown('l') then
      -- LET USER DRAW ON CANVAS. NEEDS IMPROVING / STROKE INTERPOLATION (?)
      for i, button in ipairs(canvas.pixels.buttons) do               -- run through all pixels in the canvas, looking for mouse. TODO better
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          button.color = user.color.active
          button.state.current = 1
          button.state.future = 1
          if user.color.active == user.color.disactive then
            button.state.current = 0
            button.state.future = 0
          end
        end
      end
      -- USER CONTROL
      -- MAKE SCREEN BIGGER
      if user.x <= makeBiggerButton.x.max and user.y <= makeBiggerButton.y.max and user.x >= makeBiggerButton.x.min and user.y >= makeBiggerButton.y.min and session.time > makeBiggerButton.debounceLatch then
        makeBiggerButton.debounceLatch = session.time + 0.2
        if user.screenSize <= user.maxScreenSize then
          user.screenSize = user.screenSize + 10
          canvas = {}
          canvas = newButtonArray(user.screenSize, user.screenSize, layout.canvas)
        end
      end
      -- MAKE SCREEN SMALLER
      if user.x <= makeSmallerButton.x.max and user.y <= makeSmallerButton.y.max and user.x >= makeSmallerButton.x.min and user.y >= makeSmallerButton.y.min and session.time > makeSmallerButton.debounceLatch then
        makeSmallerButton.debounceLatch = session.time + 0.2
        if user.screenSize > user.minScreenSize then
          user.screenSize = user.screenSize - 10
          canvas = {}
          canvas = newButtonArray(user.screenSize, user.screenSize, layout.canvas)
        end
      end
      -- PALETTE
      for i, button in ipairs(palette.pixels.buttons) do               -- run through all pixels in palette, looking for mouse. TODO better
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          user.color.active = button.color
        end
      end
      -- CLEAR SCREEN
      if user.x <= clearButton.x.max and user.y <= clearButton.y.max and user.x >= clearButton.x.min and user.y >= clearButton.y.min and session.time > clearButton.debounceLatch then
        clearButton.debounceLatch = session.time + 0.2
        local randomLatch = true
        for i, button in ipairs(canvas.pixels.buttons) do               -- clear every pixel
          if button.state.current == 1 then
            randomLatch = false
          end
          button.color = user.color.disactive
          button.state.current = 0
          button.state.future = 0
        end
        if randomLatch then
          for i, button in ipairs(canvas.pixels.buttons) do               -- clear every pixel
            if math.random() > 0.5 then
              button.color = {255 * math.random(), 255 * math.random(), 255 * math.random(), 255}
              button.state.current = 1
              button.state.future = 1
            end
          end
        end
      end
      -- TOGGLE VISIBLE GUIDES
      if user.x <= guideButton.x.max and user.y <= guideButton.y.max and user.x >= guideButton.x.min and user.y >= guideButton.y.min and session.time > guideButton.debounceLatch then
        user.guides = not user.guides
        guideButton.debounceLatch = session.time + 0.2
      end
      if guideButton.debounceLatch < session.time then
        guideButton.debounceLatch = session.time
      end
      -- TOGGLE solidButton
      if (user.x <= solidButton.x.max and user.y <= solidButton.y.max and user.x >= solidButton.x.min and user.y >= solidButton.y.min and session.time > solidButton.debounceLatch) then
        gameoflife.solid = not gameoflife.solid
        solidButton.debounceLatch = session.time + 0.2
      end
      if solidButton.debounceLatch < session.time then
        solidButton.debounceLatch = session.time
      end
      -- FRAME RATE DOWN
      if user.x <= frameDownButton.x.max and user.y <= frameDownButton.y.max and user.x >= frameDownButton.x.min and user.y >= frameDownButton.y.min and session.time > frameDownButton.debounceLatch then
        frameDownButton.debounceLatch = session.time + 0.2
        if user.fps > 0.6 then
          user.fps = user.fps - 0.5
        end
      end
      if frameDownButton.debounceLatch < session.time then
        frameDownButton.debounceLatch = session.time
      end
      -- FRAME RATE UP
      if user.x <= frameUpButton.x.max and user.y <= frameUpButton.y.max and user.x >= frameUpButton.x.min and user.y >= frameUpButton.y.min and session.time > frameUpButton.debounceLatch then
        if user.fps < 15 then
          user.fps = user.fps + 0.5
        end
        frameUpButton.debounceLatch = session.time + 0.2
      end
      if frameUpButton.debounceLatch < session.time then
        frameUpButton.debounceLatch = session.time
      end
      -- TOGGLE GAME OF LIFE
      if user.x <= golButton.x.max and user.y <= golButton.y.max and user.x >= golButton.x.min and user.y >= golButton.y.min and session.time > golButton.debounceLatch then
        gameoflife.toggle = not gameoflife.toggle
        if gameoflife.toggle then
          gameoflife.update = session.time + 1/user.fps
        end
        golButton.debounceLatch = session.time + 0.2
      end
      if golButton.debounceLatch < session.time then
        golButton.debounceLatch = session.time
      end
    end
  end
  -- GAME OF LIFE
  if gameoflife.toggle  and not love.mouse.isDown('l') then
    if session.time > gameoflife.update then
      gameoflife.update = session.time + 1/user.fps
      -- GAME OF LIFE LOGIC
      for i, button in ipairs(canvas.pixels.buttons) do
        -- COUNT NEIGHBOURS
        local neighbourCount, buttonColor = countActiveNeighbours(i, canvas)
        table.insert(colorLatch, buttonColor)   --HACK
        -- APPLY GOL
        if button.state.current == 1 and neighbourCount < 2 then
          button.state.future = 0
        elseif button.state.current == 1 and neighbourCount > 3 then
          button.state.future = 0
        end
        if button.state.current == 0 and neighbourCount == 3 then
          button.state.future = 1
        end
      end
      -- UPDATE CELL STATES (CURRENT -> FUTURE)
      for i, button in ipairs(canvas.pixels.buttons) do
        button.state.current = button.state.future
        if button.state.current == 1 then
          button.visited = true
          if gameoflife.solid then
            button.color = colorLatch[i]
          else
            -- button.color  = {255*math.sin(session.time / 20), 255*math.cos(session.time / 20),(255 - 255*math.sin(session.time / 20) + 0.5),255}
            button.color = colorLatch[i]
          end
        end
      end
      colorLatch = {}
    end
  end
  --- SLIME ANIMAL SWITCH
  if session.time > solidButton.debounceLatch and love.keyboard.isDown('tab') then
    gameoflife.solid = not gameoflife.solid
    solidButton.debounceLatch = session.time + 0.2
  end
  if solidButton.debounceLatch < session.time then
    solidButton.debounceLatch = session.time
  end
end

function love.draw()                                                  -- DRAW DRAW DRAW
  love.graphics.setColor(user.color.disactive)
  love.graphics.rectangle("fill", layout.canvas.x.min, layout.canvas.y.min, layout.canvas.dim, layout.canvas.dim)
  for i, button in ipairs(canvas.pixels.buttons) do                   -- Draw the Canvas (Painting area thing)
    love.graphics.setColor(button.color)
    if button.state.current == 0 and gameoflife.solid then
      love.graphics.setColor(user.color.disactive)
    elseif button.state.current == 0 and not button.visited then
      love.graphics.setColor(user.color.disactive)
    end
    if not gameoflife.solid and button.state.current == 1 and user.fps < 10 then
      love.graphics.setColor(InverseColor(button.color))
    end
    love.graphics.rectangle("fill", button.x.min, button.y.min, button.width, button.height)
    if user.guides then                                               -- Add little dots to show square placement
      love.graphics.setColor(user.color.active)
      love.graphics.rectangle("fill", button.x.min, button.y.min, 1, 1)
    end
  end
  for i, button in ipairs(palette.pixels.buttons) do                   -- Draw the palette (Painting area thing)
    love.graphics.setColor(button.color)
    love.graphics.rectangle("fill", button.x.min, button.y.min, button.width, button.height)
  end
  -- TEXT MENU
  love.graphics.setColor(InverseColor(layout.background.color))
  love.graphics.setFont(bodyFont)
  love.graphics.printf("CLEAR", clearButton.x.min + layout.tab, clearButton.y.min + layout.tab, clearButton.width, 'left')
   love.graphics.printf("GUIDE", guideButton.x.min + layout.tab, guideButton.y.min + layout.tab, guideButton.width, 'left')
   if gameoflife.toggle then
     love.graphics.printf("PAUSE", golButton.x.min + layout.tab, golButton.y.min + layout.tab, golButton.width, 'left')
   else
     love.graphics.printf("PLAY", golButton.x.min + layout.tab, golButton.y.min + layout.tab, golButton.width, 'left')
   end
   if gameoflife.solid then
    love.graphics.printf("SLIME", solidButton.x.min + layout.tab, solidButton.y.min + layout.tab, solidButton.width, 'left')
  else
    love.graphics.printf("ANIMALS", solidButton.x.min + layout.tab, solidButton.y.min + layout.tab, solidButton.width, 'left')
  end
  love.graphics.printf("FASTER", frameUpButton.x.min + layout.tab, frameUpButton.y.min + layout.tab, frameUpButton.width, 'left')
  love.graphics.printf("SLOWER", frameDownButton.x.min + layout.tab, frameDownButton.y.min + layout.tab, frameDownButton.width, 'left')
  love.graphics.printf("SMALLER", makeBiggerButton.x.min + layout.tab, makeBiggerButton.y.min + layout.tab, makeBiggerButton.width, 'left')
  love.graphics.printf("BIGGER", makeSmallerButton.x.min + layout.tab, makeSmallerButton.y.min + layout.tab, makeSmallerButton.width, 'left')
end

function countActiveNeighbours(index, buttonArray)
  neighbourIndex = {}
  local newColor = {}
  local neighbours = {}
  local neighbourCount = 0
  table.insert(neighbourIndex, index + 1)
  table.insert(neighbourIndex, index - 1)
  table.insert(neighbourIndex, index + buttonArray.x.resolution)
  table.insert(neighbourIndex, index + buttonArray.x.resolution - 1)
  table.insert(neighbourIndex, index + buttonArray.x.resolution + 1)
  table.insert(neighbourIndex, index - buttonArray.x.resolution)
  table.insert(neighbourIndex, index - buttonArray.x.resolution - 1)
  table.insert(neighbourIndex, index - buttonArray.x.resolution + 1)
  if user.toroid then
    for i, indec in ipairs(neighbourIndex) do
      if indec < 0 then
        indec = indec + buttonArray.pixels.length
      elseif indec > buttonArray.pixels.length then
        indec = indec - buttonArray.pixels.length
      end
      table.insert(neighbours, buttonArray.pixels.buttons[indec])
    end
  end
  for i, neighbour in ipairs(neighbours) do
    if neighbour.state.current == 1 then
      neighbourCount = neighbourCount + 1
      newColor = neighbour.color    -- HACK
    end
  end
  return neighbourCount, newColor
end

function InverseColor(color)
  newColor = {255 - color[1], 255 - color[2], 255 - color[3], color[4]}
  return newColor
end

function newPalette()
  local palette = newButtonArray(8, 8, layout.palette)
  for i, button in ipairs(palette.pixels.buttons) do                   -- Draw the palette (Painting area thing)
    button.color = {math.random() * 255, math.random() * 255, math.random() * 255, 255}
    -- button.color = {(math.floor(8 * math.random()) * 255 / 8), (math.floor(8 * math.random()) * 255 / 8), (math.floor(8 * math.random()) * 255 / 8), 255}
    if i == 1 then
      button.color = {255, 255, 255, 255}
    elseif i == 2 then
      button.color = {0, 0, 0, 255}
    elseif i == 3 then
      button.color = {255, 0, 0, 255}
    elseif i == 4 then
      button.color = {255, 255, 0, 255}
    elseif i == 5 then
      button.color = {0, 255, 0, 255}
    elseif i == 6 then
      button.color = {0, 255, 255, 255}
    elseif i == 7 then
      button.color = {0, 0, 255, 255}
    elseif i == 8 then
      button.color = {255, 0, 255, 255}
    end
  end
  return palette
end

function newUser()
  local user = {}
  user.toroid = true
  user.color = {}
  user.color.active = {255, 255, 255, 255}
  user.color.disactive = {0, 0, 0, 255}
  user.x = 0
  user.y = 0
  user.guides = false
  user.fps = 5
  user.maxScreenSize = 200
  user.minScreenSize = 10
  user.screenSize = 100
  return user
end

function newButton(x, y, height, width, color)
  local button = {}
  button.color = color
  button.inherit = {}
  button.inherit.currentColor = color
  button.inherit.futureColor = color
  button.width = width
  button.height = height
  button.x = {}
  button.x.min = x
  button.x.max = x + width
  button.y = {}
  button.y.min = y
  button.y.max = y + height
  button.state = {}
  button.state.current = 0
  button.state.future = 0
  button.visited = false
  return button
end

function newButtonArray(xResolution, yResolution, type)
  local buttonArray = {}
  buttonArray.x = {}
  buttonArray.x.resolution = xResolution
  buttonArray.y = {}
  buttonArray.y.resolution = yResolution
  buttonArray.cell = {}
  buttonArray.pixels = {}                                -- fake pixels = fauxils?
  buttonArray.pixels.width = type.dim / xResolution
  buttonArray.pixels.height = type.dim / yResolution
  buttonArray.pixels.buttons = {}
  buttonArray.pixels.length = xResolution * yResolution
  for j = 0, buttonArray.y.resolution - 1 do
    for i = 0, buttonArray.x.resolution - 1 do
      local buttonx = i * buttonArray.pixels.width + type.x.min
      local buttony = j * buttonArray.pixels.height + type.y.min
          local button = newButton(buttonx, buttony, buttonArray.pixels.height, buttonArray.pixels.width, user.color.active)
          table.insert(buttonArray.pixels.buttons, button)
    end
  end
  return buttonArray
end

function newLayout()
  local layout = {}
  layout.border = 0.01                                                -- proportional border
  layout.background = {}
  layout.background.color = {200, 200, 200, 200}
  layout.maxSquareSide = SCREEN.HEIGHT                                -- max length of box
  layout.tab = layout.border * layout.maxSquareSide                   -- converted to pixels
  -- CANVAS
  layout.canvas = {}
  layout.canvas.maxAlign = SCREEN.WIDTH - layout.maxSquareSide      -- max hand side for max screen box
  layout.canvas.x = {}                                               -- make bordered canvas dimensions
  layout.canvas.x.min = layout.canvas.maxAlign + layout.tab
  layout.canvas.x.max = SCREEN.WIDTH - layout.tab
  layout.canvas.y = {}
  layout.canvas.y.min = layout.tab
  layout.canvas.y.max = SCREEN.HEIGHT - layout.tab
  layout.canvas.dim = layout.canvas.x.max - layout.canvas.x.min          -- get width of bordered canvas
  -- PALETTE
  layout.palette = {}
  layout.palette.maxAlign = 0
  layout.palette.x = {}
  layout.palette.x.min = 0 + layout.tab
  layout.palette.x.max = layout.canvas.maxAlign
  layout.palette.y = {}
  layout.palette.y.min = SCREEN.HEIGHT - layout.canvas.x.min + layout.tab
  layout.palette.y.max = SCREEN.HEIGHT - layout.tab
  layout.palette.dim = layout.palette.x.max - layout.palette.x.min
  return layout
end
