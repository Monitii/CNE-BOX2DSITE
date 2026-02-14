import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
importScript("data/scripts/Box2D.hx");
importScript("data/scripts/BoxDebug.hx");

/*
This is an example script for CNE-Box2D.
Box2D for Codename Engine! this script makes a ton of balls fall from the sky.
*/

var bfChar = strumLines.members[1].characters[0];
var dadChar = strumLines.members[0].characters[0];

// make the world (gravity in pixels/sec^2, positive = downwards)
var worldId = box2d_createWorld(0, 980);

// make the box bodies!
// BF is dynamic (type 2) and starts above the floor.
var bfBody = box2d_createBody(worldId, 2, 1050, 650);
// Dad is also dynamic! 
var dadBody = box2d_createBody(worldId, 2, 400, 500);
// Floor is static (type 0) positioned near bottom of screen.
var floor = box2d_createBody(worldId, 0, 0, 850);
public var celing = box2d_createBody(worldId, 0, 0, -1000);
// walls!!
public var wall1 = box2d_createBody(worldId, 0, 1750, -1150);
public var wall2 = box2d_createBody(worldId, 0, -200, -1150);

// ball stuff
var ballBodies:Array<Int> = [];
var ballSpawnTimer:Float = 0;
var ballSpawnInterval:Float = 0.1;
var totalBallsToSpawn:Int = 50;
var ballsSpawned:Int = 0;

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

function spawnBall():Void {
    var randomX = FlxG.random.float(100, 1180);
    var spawnY = -50;
    var randomRadius = FlxG.random.float(20, 50);
    
    var ball = box2d_createBody(worldId, 2, randomX, spawnY);
    box2d_addCircle(ball, randomRadius, 1);
    
    box2d_impulse(ball, FlxG.random.float(-0.25, 0.25), 0);
    box2d_setRestitution(ball, 0, 2);
    
    ballBodies.push(ball);
    
    if (box2dDebugEnabled) {
        createDebugForBody(ball);
    }
    
    trace("ball.");
}

function update(elapsed:Float) {
    // Ball spawning logic
    if (ballsSpawned < totalBallsToSpawn) {
        ballSpawnTimer += elapsed;
        
        if (ballSpawnTimer >= ballSpawnInterval) {
            spawnBall();
            ballsSpawned++;
            ballSpawnTimer = 0;
        }
    }
    
    // makes a step in the physics simulation, self explanatory.
    box2d_step(worldId, elapsed);
    var pos = box2d_getPos(bfBody);
    var fpos = box2d_getPos(floor);

    if (box2dDebugEnabled) updateDebugSprites();
}

function draw() {
    box2d_syncSprite(bfBody, bfChar, 0, 0, 0, -350);
    box2d_syncSprite(dadBody, dadChar, 0, 0, 0, -150);
}