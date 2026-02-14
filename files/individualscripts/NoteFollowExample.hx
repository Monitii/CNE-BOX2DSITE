import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
importScript("data/scripts/Box2D.hx");
importScript("data/scripts/BoxDebug.hx");

/*
This is an example script for CNE-Box2D.
Box2D for Codename Engine! this script makes both Dad and BF fling and spin whenever they hit a note.
*/

var bfChar = strumLines.members[1].characters[0];
var dadChar = strumLines.members[0].characters[0];

// make the world (gravity in pixels/sec^2, positive = downwards)
var worldId = box2d_createWorld(0, 980);

// make the box bodies!
// BF is dynamic (type 2) and starts above the floor.
public var bfBody = box2d_createBody(worldId, 2, 1050, 650);
// Dad is also dynamic! 
public var dadBody = box2d_createBody(worldId, 2, 400, 500);
// Floor is static (type 0) positioned near bottom of screen.
public var floor = box2d_createBody(worldId, 0, 0, 850);
public var celing = box2d_createBody(worldId, 0, 0, -1000);
// walls!!
public var wall1 = box2d_createBody(worldId, 0, 1750, -1150);
public var wall2 = box2d_createBody(worldId, 0, -200, -1150);

function postCreate() {
    whiteSquare = new FlxSprite();
    
    // these give the bodies their "fixtures" also known as their collision. 
    box2d_addBox(floor, 4000, 50, 0);
    box2d_addBox(celing, 4000, 50, 0);
    box2d_addBox(wall1, 50, 4000, 0);
    box2d_addBox(wall2, 50, 4000, 0);
    box2d_addBox(bfBody, bfChar.width, bfChar.height, 1);
    box2d_addBox(dadBody, dadChar.width, dadChar.height, 1);

    whiteSquare.x = box2d_getPos(floor)[0];
    whiteSquare.y = box2d_getPos(floor)[1];

    // Initialize debug group in THIS script's context
    box2dDebugGroup = new FlxGroup();
    add(box2dDebugGroup);
    
    // Now create debug sprites
    if (box2dDebugEnabled) {
        //createDebugForBody(floor);
        createDebugForBody(bfBody);
        createDebugForBody(dadBody);
        createDebugForBody(wall1);
        createDebugForBody(wall2);
        createDebugForBody(celing);
    }
}

function update(elapsed:Float) {
    // makes a step in the physics simulation, self explanatory.
    box2d_step(worldId, elapsed);
    var pos = box2d_getPos(bfBody);
    var fpos = box2d_getPos(floor);
    
    // Update debug sprites
    if (box2dDebugEnabled) updateDebugSprites();
}

function onPlayerHit(){
    switch(bfChar.getAnimName()) {
        case "singLEFT" | "singLEFT-alt": 
            box2d_torque(bfBody, -90);

        case "singUP" | "singUP-alt":  
            box2d_impulse(bfBody, 0, -5);

        case "singRIGHT", "singRIGHT-alt": 
            box2d_torque(bfBody, 90);
    }
}

function onDadHit(){
    switch(dadChar.getAnimName()) {
        case "singLEFT" | "singLEFT-alt": 
            box2d_torque(dadBody, -120);

        case "singUP" | "singUP-alt":  
            box2d_impulse(dadBody, 0, -10);

        case "singRIGHT", "singRIGHT-alt": 
            box2d_torque(dadBody, 120);
    }
}

function draw() {
    box2d_syncSprite(bfBody, bfChar, 0, 0, 0, -350);
    box2d_syncSprite(dadBody, dadChar, 0, 0, 0, -150);
}