
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local json = require( "json" )

local scoreTable = {}
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local sound_musicTrack
audio.reserveChannels( 1 )
audio.setVolume( 0.2, { channel=1 })


local function loadScores()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read( "*a")
		io.close( file )
		scoreTable = json.decode( contents )
	end

	if (scoreTable == nil or #scoreTable == 0 ) then
		scoreTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end

local function saveScores()
	for i = #scoreTable, 11,-1 do
		table.remove( scoreTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoreTable ) )
		io.close( file )
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	loadScores()

	table.insert( scoreTable, composer.getVariable("finalScore") )
	composer.setVariable( "finalScore", 0 )

	local function compare( a, b )
		return a > b
	end
	table.sort(scoreTable, compare)

	saveScores()

	local bg = display.newImageRect( sceneGroup, "assets/background.png" , 800, 1400 );
	bg.x = display.contentCenterX;
	bg.y = display.contentCenterY

	local highScoreHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44 )

	for i = 1, 10 do
		if (scoreTable[i]) then
			local yPos = 150 + ( i * 56 )
		
			local rankNum = display.newText(sceneGroup, i .. " )", display.contentCenterX - 50, yPos, native.systemFont, 36 )
			rankNum:setFillColor( 0.75, 0.78, 1.0 )
			rankNum.anchorX = 1;

			local thisScore = display.newText( sceneGroup, scoreTable[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
			thisScore.anchorX = 0;
		end
	end

	local menuButton = display.newText( sceneGroup, "menu", display.contentCenterX, 810, native.systemFont, 44 )
	menuButton:setFillColor( 0.75, 0.78, 1.0 )

	local function gotoMenu()
		composer.gotoScene( "menu", { time=800, effect="crossFade" } )
	end
	menuButton:addEventListener( "tap", gotoMenu )

    sound_musicTrack= audio.loadSound( "assets/audio/Midnight-Crawlers_Looping.wav" )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		audio.play( sound_musicTrack , { channel=1, loops=-1 })
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "highScores" )
		audio.stop(1)
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

	audio.dispose(sound_musicTrack)

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
