import flixel.FlxG;
importScript("data/scripts/Box2D.hx");

/*
This is an example script for CNE-Box2D.
Box2D for Codename Engine! this script makes a physics object, and makes BF follow it.
*/

var box2dDebugEnabled:Bool = true;
var box2dDebugGroup:FlxGroup;
var box2dDebugFixtures:Array<Dynamic> = [];

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

function postCreate() {
    whiteSquare = new FlxSprite();
    // these give the bodies their "fixtures" also known as their collision. 
    box2d_addBox(floor, 4000, 50, 0);
    box2d_addBox(bfBody, 300, 300, 1);
    box2d_addBox(dadBody, 300, 600, 1);

    whiteSquare.x = box2d_getPos(floor)[0];
    whiteSquare.y = box2d_getPos(floor)[1];

    box2dDebugGroup = new FlxGroup();
    add(box2dDebugGroup);
    if (box2dDebugEnabled) {
        createDebugForBody(floor);
        createDebugForBody(bfBody);
        createDebugForBody(dadBody);
    }
}

function createDebugForBody(bodyId:Int):Void {
    var fixtures = box2d_getFixtures(bodyId);
    for (f in fixtures) {
        var s = new FlxSprite();
        s.makeGraphic(Math.ceil(f.hx), Math.ceil(f.hy), FlxColor.RED);
        s.alpha = 0.35;
        box2dDebugGroup.add(s);
        box2dDebugFixtures.push({ bodyId: bodyId, fixture: f, sprite: s });
    }
}

function update(elapsed:Float) {
    // makes a step in the physics simulation, self explanatory.
    box2d_step(worldId, elapsed);
    var pos = box2d_getPos(bfBody);
    var fpos = box2d_getPos(floor);

    // how to use impulses and torque!
    if (FlxG.keys.justPressed.E) {
        box2d_impulse(bfBody, -30, -5);
        box2d_torque(bfBody, 90);
        trace("impulse yippe!!");
    }

    if (box2dDebugEnabled) updateDebugSprites();
}

function updateDebugSprites():Void { 
    for (d in box2dDebugFixtures) {
        var pos = box2d_getPos(d.bodyId);
        var rot = box2d_getAngle(d.bodyId);
        if (pos == null) continue;
        var f = d.fixture;
        var s:FlxSprite = d.sprite;
        s.x = pos[0] + f.ox - (f.hx / 2);
        s.y = pos[1] + f.oy - (f.hy / 2);
        s.angle = -rot * 180.0 / Math.PI;
    }
}

function draw() {
 /* get the position and rotation of the box2d body and set bf to it!
    (yes i really could not think of a better way to do this) */

    //BF POS and ROT
    var bfPhysPos = box2d_getPos(bfBody);
    var bfPhysRot = box2d_getAngle(bfBody);
    bfChar.x = bfPhysPos[0] - 200;
    bfChar.y = bfPhysPos[1] - 575;
    bfChar.angle = -bfPhysRot * 180.0 / Math.PI; // box2d angle is in radians and clockwise, flixel is in degrees and counterclockwise, so convert and negate.

    //DAD POS and ROT
    var dadPhysPos = box2d_getPos(dadBody);
    var dadPhysRot = box2d_getAngle(dadBody);
    dadChar.x = dadPhysPos[0] - 200;
    dadChar.y = dadPhysPos[1] - 405;
    dadChar.angle = -dadPhysRot * 180.0 / Math.PI;
}