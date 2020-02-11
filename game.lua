
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )

local physicsEngine = require( "physics" )
physicsEngine.start()
physicsEngine.setGravity(0.0, 0,0)

-- conf sprite sheet
local sheetOptions =
{
    frames = {
        {  -- asteroid 1
            x       = 0,
            y       = 0,
            width   = 102,
            height  = 85
        },
        {  -- asteroid 2
            x       = 0,
            y       = 85,
            width   = 90,
            height  = 83
        },
        {  -- asteroid 3
            x       = 0,
            y       = 168,
            width   = 100,
            height  = 97
        },
        {  -- ship 4
            x       = 0,
            y       = 265,
            width   = 98,
            height  = 79
        },
        
        {  -- laser 5
            x       = 98,
            y       = 265,
            width   = 14,
            height  = 40
        },
    },
};

local objectSheet = graphics.newImageSheet( "assets/gameObjects.png", sheetOptions );
-- do not play on this channel unless spiecifically asked to
audio.reserveChannels( 1 )
audio.setVolume( 0.2, { channel=1 })


local lives = 1;
local score = 0;
local died = false;

local asteroidTable = {};

local bg;
local ship;
local gameLoopTimer;
local livesText;
local scoreText;
local debugText;

local backGroup
local mainGroup
local uiGroup

local sound_explotion
local sound_fireSound
local sound_musicTrack

local function setupUi()
    livesText = display.newText (uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 );
    scoreText = display.newText (uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 );
    --debugText = display.newText (uiGroup, "Debug: ", 200, 140, native.systemFont, 36 );
end
local function updateUiText()
    livesText.text = "Lives: " .. lives;
    scoreText.text = "Score: " .. score;
end

local function createAsteroid()
    local asteroidType = math.random( 3 );
    local newAsteroid;
    if (asteroidType == 1) then
        newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 );
    elseif( asteroidType == 2) then
        newAsteroid = display.newImageRect( mainGroup, objectSheet, 2, 90, 83 );
    else
        newAsteroid = display.newImageRect( mainGroup, objectSheet, 3, 100, 97 );
    end

    newAsteroid.myName = "asteroid"
    physicsEngine.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } );
    table.insert(asteroidTable, newAsteroid);

    local whereFrom = math.random( 3 );
    if (whereFrom == 1) then
        -- from left
        newAsteroid.x = -60;
        newAsteroid.y = math.random( 500 );
        newAsteroid:setLinearVelocity( math.random( 40, 120 ), math.random( 20, 60 ) );
    elseif (whereFrom == 2) then
        -- from top
        newAsteroid.x = math.random( display.contentWidth );
        newAsteroid.y = -60;
        newAsteroid:setLinearVelocity( math.random( -40, 40 ), math.random( 20, 60 ) );
    elseif (whereFrom == 3) then
        -- from right
        newAsteroid.x = display.contentWidth + 60;
        newAsteroid.y = math.random( 500 );
        newAsteroid:setLinearVelocity( math.random( -120, -40 ), math.random( 20, 60 ) );
    end
    newAsteroid:applyTorque( math.random(-6, 6) );
end

local function cleanAsteroids()
    -- start at tablesize #table, end at 1, -1 as i--
    for i = #asteroidTable, 1, -1 do
        local thisAsteroid = asteroidTable[i];

        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid );
            table.remove( asteroidTable, i );
        end
    end
end

local function fireLaser()

    audio.play( sound_fireSound )

    local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 );
    physicsEngine.addBody( newLaser, "dynamic", { isSensor=true } );
    newLaser.isBullet = true;
    newLaser.myName = "laser";

    newLaser.x = ship.x;
    newLaser.y = ship.y;
    newLaser:toBack();  -- move it to the back of the layer maingroup

    transition.to( newLaser, { y=-40, time=500, 
        onComplete = function() display.remove( newLaser ) end } )
end

local function dragShip( event )
    local ship = event.target;
    local phase = event.phase;

    if ("began" == phase) then
        -- set touch focus on the ship
        display.currentStage:setFocus( ship );
        ship.touchOffsetX = event.x - ship.x;
    elseif ( "moved" == phase ) then
        -- move the ship to the touch new position
        ship.x = event.x - ship.touchOffsetX;
    elseif ( "ended" == phase or "cancelled" == phase) then
        -- release the touch focus on the ship
        display.currentStage:setFocus(nil);
    end

    return true;
end

local function gameloop()
    -- gameloop
    updateUiText();
    createAsteroid();
    cleanAsteroids();
end

local function restoreShip()
    ship.isBodyActive = false;
    ship.x = display.contentCenterX;
    ship.y = display.contentHeight - 100;

    -- fade in the ship
    transition.to (ship, { alpha=1, time=4000, 
        onComplete = function()
            ship.isBodyActive = true;
            died = false;
        end
    })
end

local function endgame()
    composer.setVariable( "finalScore", score )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function onCollition( event )
    if (event.phase == "began") then
        local obj1 = event.object1;
        local obj2 = event.object2;
    
        if
        (
            (obj1.myName == "laser" and obj2.myName == "asteroid" ) or
            (obj1.myName == "asteroid" and obj2.myName == "laser")
        )then
            -- remove both objects
            display.remove( obj1 );
            display.remove( obj2 );

            audio.play( sound_explotion )

            for i = #asteroidTable, 1, -1 do
                if( asteroidTable[i] == obj1 or asteroidTable[i] == obj2 ) then
                    table.remove( asteroidTable, i );
                    break;
                end
            end

            score = score + 100;
            scoreText.text = "Score: " .. score;
        end
        if
        (
            (obj1.myName == "ship" and obj2.myName == "asteroid" ) or
            (obj1.myName == "asteroid" and obj2.myName == "ship")
        )then
            if (died == false) then
                died = true;
                lives = lives - 1;
                livesText.text = "Lives: " .. lives;

                audio.play( sound_explotion )
            end

            if( lives == 0 ) then
                display.remove(ship)
				
				timer.performWithDelay( 2000, endgame )
            else
                ship.alpha = 0;
                timer.performWithDelay(1000, restoreShip);
            end
        end

    end
end

local function setupShip()
    ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 );
    ship.x = display.contentCenterX;
    ship.y = display.contentHeight - 100;
    physicsEngine.addBody (ship, { radius=30, isSensor=true } );
    ship.myName = "ship";

    ship:addEventListener( "tap", fireLaser );
    ship:addEventListener( "touch", dragShip );
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physicsEngine.pause()

	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )
	
	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert( mainGroup )
	
	uiGroup   = display.newGroup()  -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )

	bg = display.newImageRect( backGroup, "assets/background.png" , 800, 1400 );
    bg.x = display.contentCenterX;
	bg.y = display.contentCenterY;
	
	setupShip()
    setupUi()
    
    sound_explotion= audio.loadSound( "assets/audio/explosion.wav" )
    sound_fireSound= audio.loadSound( "assets/audio/fire.wav" )
    sound_musicTrack= audio.loadSound( "assets/audio/80s-Space-Game_Looping.wav" )
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physicsEngine.start()
		Runtime:addEventListener( "collision", onCollition );
        gameLoopTimer = timer.performWithDelay( 500, gameloop, 0 );
        
        audio.play( sound_musicTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

		Runtime:removeEventListener( "collision", onCollition )
        physicsEngine.pause()
        audio.stop( 1 )

		composer.removeScene( "game" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    
    audio.dispose ( sound_explotion )
    audio.dispose ( sound_fireSound )
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
