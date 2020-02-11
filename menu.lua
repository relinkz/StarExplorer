
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
	composer.gotoScene( "game", {time = 800, effect="crossFade" } )
end

local function gotoHighScores()
	composer.gotoScene( "highscores", {time = 800, effect="crossFade" } )
end

audio.reserveChannels( 1 )
audio.setVolume( 0.5, { channel=1 })

local sound_musicTrack

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local bg = display.newImageRect( sceneGroup, "assets/background.png" , 800, 1400 );
	bg.x = display.contentCenterX
	bg.y = display.contentCenterY

	local title = display.newImageRect (sceneGroup, "assets/title.png", 500, 80 )
	title.x = display.contentCenterX
	title.y = 200

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44 )
	playButton:setFillColor(0.82, 0.86, 1)

	local highScoreButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44 )
	highScoreButton:setFillColor(0.82, 0.86, 1)

	playButton:addEventListener( "tap", gotoGame )
	highScoreButton:addEventListener( "tap", gotoHighScores )
	
	sound_musicTrack= audio.loadSound( "assets/audio/Escape_Looping.wav" )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
	
	audio.play( sound_musicTrack, { channel=1, loops=-1 } )
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
	audio.stop( 1 )

end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

    audio.dispose ( sound_musicTrack )
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
