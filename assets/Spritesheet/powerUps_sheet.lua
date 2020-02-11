--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:c0b84fa97629377e878f720eee6b98dd:223fe153975b543a10daba5e7a6d9ab2:756f1605d01e2dd9880e0a25296e1cf4$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- bold_silver
            x=0,
            y=0,
            width=19,
            height=30,

        },
        {
            -- bolt_bronze
            x=19,
            y=0,
            width=19,
            height=30,

        },
        {
            -- bolt_gold
            x=38,
            y=0,
            width=19,
            height=30,

        },
        {
            -- pill_blue
            x=57,
            y=0,
            width=22,
            height=21,

        },
        {
            -- pill_green
            x=79,
            y=0,
            width=22,
            height=21,

        },
        {
            -- pill_red
            x=101,
            y=0,
            width=22,
            height=21,

        },
        {
            -- pill_yellow
            x=123,
            y=0,
            width=22,
            height=21,

        },
        {
            -- powerupBlue
            x=145,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupBlue_bolt
            x=179,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupBlue_shield
            x=213,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupBlue_star
            x=247,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupGreen
            x=281,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupGreen_bolt
            x=315,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupGreen_shield
            x=349,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupGreen_star
            x=383,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupRed
            x=417,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupRed_bolt
            x=451,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupRed_shield
            x=485,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupRed_star
            x=519,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupYellow
            x=553,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupYellow_bolt
            x=587,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupYellow_shield
            x=621,
            y=0,
            width=34,
            height=33,

        },
        {
            -- powerupYellow_star
            x=655,
            y=0,
            width=34,
            height=33,

        },
        {
            -- shield_bronze
            x=689,
            y=0,
            width=30,
            height=30,

        },
        {
            -- shield_gold
            x=719,
            y=0,
            width=30,
            height=30,

        },
        {
            -- shield_silver
            x=749,
            y=0,
            width=30,
            height=30,

        },
        {
            -- star_bronze
            x=779,
            y=0,
            width=31,
            height=30,

        },
        {
            -- star_gold
            x=810,
            y=0,
            width=31,
            height=30,

        },
        {
            -- star_silver
            x=841,
            y=0,
            width=31,
            height=30,

        },
        {
            -- things_bronze
            x=872,
            y=0,
            width=32,
            height=32,

        },
        {
            -- things_gold
            x=904,
            y=0,
            width=32,
            height=32,

        },
        {
            -- things_silver
            x=936,
            y=0,
            width=32,
            height=32,

        },
    },

    sheetContentWidth = 968,
    sheetContentHeight = 33
}

SheetInfo.frameIndex =
{

    ["bold_silver"] = 1,
    ["bolt_bronze"] = 2,
    ["bolt_gold"] = 3,
    ["pill_blue"] = 4,
    ["pill_green"] = 5,
    ["pill_red"] = 6,
    ["pill_yellow"] = 7,
    ["powerupBlue"] = 8,
    ["powerupBlue_bolt"] = 9,
    ["powerupBlue_shield"] = 10,
    ["powerupBlue_star"] = 11,
    ["powerupGreen"] = 12,
    ["powerupGreen_bolt"] = 13,
    ["powerupGreen_shield"] = 14,
    ["powerupGreen_star"] = 15,
    ["powerupRed"] = 16,
    ["powerupRed_bolt"] = 17,
    ["powerupRed_shield"] = 18,
    ["powerupRed_star"] = 19,
    ["powerupYellow"] = 20,
    ["powerupYellow_bolt"] = 21,
    ["powerupYellow_shield"] = 22,
    ["powerupYellow_star"] = 23,
    ["shield_bronze"] = 24,
    ["shield_gold"] = 25,
    ["shield_silver"] = 26,
    ["star_bronze"] = 27,
    ["star_gold"] = 28,
    ["star_silver"] = 29,
    ["things_bronze"] = 30,
    ["things_gold"] = 31,
    ["things_silver"] = 32,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
