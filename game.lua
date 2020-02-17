
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

-- collition filters
-- https://docs.coronalabs.com/guide/physics/collisionDetection/index.html#filtering
local cf_ship       = { categoryBits=1, maskBits=6 }
local cf_asteroid   = { categoryBits=2, maskBits=3 }
local cf_powerup    = { categoryBits=4, maskBits=1 }


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

local powerupInfo = require("assets.Spritesheet.powerUps_sheet")
local powerupSheet = graphics.newImageSheet("assets/Spritesheet/powerUps_sheet.png", powerupInfo:getSheet() )

local laserInfo = require("assets.Spritesheet.bullets_sheet")
local laserSheet = graphics.newImageSheet("assets/Spritesheet/bullets_sheet.png", laserInfo:getSheet() )

local objectSheet = graphics.newImageSheet( "assets/gameObjects.png", sheetOptions );
-- do not play on this channel unless spiecifically asked to
audio.reserveChannels( 1 )
audio.setVolume( 0.2, { channel=1 })

local playerLaserSplit = {}
local playerLaserPen = {}


local lives = 1;
local score = 0;
local died = false;

local asteroidTable = {}
local powerupTable  = {}

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
    
    physicsEngine.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8, filter=cf_asteroid } );
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

local function spawnPowerUp( event )

    local powerup = display.newSprite( powerupSheet , { 
            frames= {
                powerupInfo:getFrameIndex("powerupBlue_bolt")
            }
        } )

    local params = event.source.params

    powerup.x = params.posX
    powerup.y = params.posY

    powerup.myName = "powerUp_split"
    physicsEngine.addBody( powerup, "dynamic", { radius=17, bounce=1.0, filter=cf_powerup });

    table.insert(powerupTable, powerup);
    powerup:setLinearVelocity( 0 , 140 );

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

local function cleanPowerups()
    for i = #powerupTable, 1, -1 do
        local thisPowerUp = powerupTable[i];

        if ( thisPowerUp.x < -100 or
            thisPowerUp.x > display.contentWidth + 100 or
            thisPowerUp.y < -100 or
            thisPowerUp.y > display.contentHeight + 100 )
        then
            display.remove( thisPowerUp );
            table.remove( powerupTable, i );
        end
    end
end

local function removePowerUp(powerUp)
    for i = #powerupTable, 1, -1 do
        local thisPowerUp = powerupTable[i]
        if (powerUp == thisPowerUp ) then
            display.remove(thisPowerUp)
            table.remove(powerupTable, i)
        break
        end
    end


end

local function addLaser( xOffset )
    local newLaser = display.newSprite( mainGroup, laserSheet, {
        frames = {
            laserInfo:getFrameIndex("laserBlue01")
        }
    } );

    physicsEngine.addBody( newLaser, "dynamic", { isSensor=true } );
    newLaser.isBullet = true;
    newLaser.myName = "laser";

    newLaser.x = ship.x;
    newLaser.y = ship.y;
    newLaser:toBack();  -- move it to the back of the layer maingroup

    if xOffset == 0 then
        transition.to( newLaser, { y=-40, time=500, 
            onComplete = function() display.remove( newLaser ) end } )
    else
        transition.to( newLaser, { y=-40, x = xOffset, time=500, 
            onComplete = function() display.remove( newLaser ) end } )
    end
end

local function fireLaser()

    audio.play( sound_fireSound )
    addLaser(0)

    for i = 1, #playerLaserSplit, 1 do
            addLaser(ship.x - (100 * i))
            addLaser(ship.x + (100 * i))
    end

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
    updateUiText()
    createAsteroid()

    cleanAsteroids()
    cleanPowerups()
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

            local tm = timer.performWithDelay(50, spawnPowerUp )
            tm.params = {posX = obj1.x , posY = obj1.y }

            --if (math.random(10) == 10 ) then
                --local collisionPos = { event.x, event.y }
              --  timer.performWithDelay(500, spawnPowerUp, collisionPos )
            --end
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

        if
        (
            (obj1.myName == "ship" and obj2.myName == "powerUp_split") or
            (obj1.myName == "powerUp_split" and obj2.myName == "ship")
        ) then
            table.insert(playerLaserSplit, 1)
            if obj1.myName == "powerUp_split" then
                removePowerUp(obj1)
            else
                removePowerUp(obj2)
            end
        end
    end
end

local function setupShip()
    ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 );
    ship.x = display.contentCenterX;
    ship.y = display.contentHeight - 100;
    physicsEngine.addBody (ship, { radius=30, isSensor=true, filter=cf_ship } );
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
