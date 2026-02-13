import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
importScript("data/scripts/Box2D.hx");

/*
This is an example script for CNE-Box2D.
Box2D for Codename Engine! this script makes you be able to pick up BF.
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
// Floor is static (type 0) positioned near bottom of screen.
var floor = box2d_createBody(worldId, 0, 0, 850);

// Mouse grabbing variables
var mouseBody:Int = 0; // invisible body that follows mouse
var mouseJoint:Int = 0; // joint connecting mouse to grabbed body
var isGrabbing:Bool = false;
var lastMouseX:Float = 0;
var lastMouseY:Float = 0;

function postCreate() {
    whiteSquare = new FlxSprite();
    // these give the bodies their "fixtures" also known as their collision. 
    box2d_addBox(floor, 4000, 50, 0);
    box2d_addBox(bfBody, bfChar.width, bfChar.height, 1);
    FlxG.mouse.visible = true;

    // Create invisible mouse body (kinematic type = 1, moves but isn't affected by forces)
    mouseBody = box2d_createBody(worldId, 1, FlxG.mouse.x, FlxG.mouse.y);
    box2d_addBox(mouseBody, 1, 1, 0); // tiny fixture

    whiteSquare.x = box2d_getPos(floor)[0];
    whiteSquare.y = box2d_getPos(floor)[1];

    box2dDebugGroup = new FlxGroup();
    add(box2dDebugGroup);
    if (box2dDebugEnabled) {
        createDebugForBody(floor);
        createDebugForBody(bfBody); // add for every body you want to debug.
    }
}

function createDebugForBody(bodyId:Int):Void {
    var fixtures = box2d_getFixtures(bodyId);
    for (f in fixtures) {
        var s = new FlxSprite();
        
        if (f.isCircle) {
            var diameter = Math.ceil(f.radius * 2);
            s.makeGraphic(diameter, diameter, FlxColor.TRANSPARENT);
            
            FlxSpriteUtil.drawCircle(s, f.radius, f.radius, f.radius, FlxColor.TRANSPARENT, {thickness: 2, color: FlxColor.RED});
            
            FlxSpriteUtil.drawLine(s, f.radius, f.radius, f.radius * 2, f.radius, {thickness: 2, color: FlxColor.YELLOW});
            
            FlxSpriteUtil.drawCircle(s, f.radius, f.radius, 3, FlxColor.LIME);
            
            s.alpha = 0.35;
        } else {
            s.makeGraphic(Math.ceil(f.hx), Math.ceil(f.hy), FlxColor.RED);
            s.alpha = 0.35;
            
            FlxSpriteUtil.drawCircle(s, f.hx / 2, f.hy / 2, 3, FlxColor.LIME);
        }
        
        box2dDebugGroup.add(s);
        box2dDebugFixtures.push({ bodyId: bodyId, fixture: f, sprite: s });
    }
}

function update(elapsed:Float) {
    // Update mouse body position (you'll need to add a setPosition function to Box2D.hx)
    // For now, we'll destroy and recreate it each frame as a workaround
    if (mouseBody != 0) {
        // Calculate mouse velocity for throwing
        var mouseVelX = (FlxG.mouse.x - lastMouseX) / elapsed;
        var mouseVelY = (FlxG.mouse.y - lastMouseY) / elapsed;
        lastMouseX = FlxG.mouse.x;
        lastMouseY = FlxG.mouse.y;
    }

    box2d_setBodyTransform(mouseBody, FlxG.mouse.x, FlxG.mouse.y);
    if (FlxG.mouse.justPressed) {
        var bfPos = box2d_getPos(bfBody);
        var dx = FlxG.mouse.x - bfPos[0];
        var dy = FlxG.mouse.y - bfPos[1];
        var dist = Math.sqrt(dx * dx + dy * dy);
        
        if (dist < 150) {
            mouseJoint = box2d_createRevoluteJointBetween(worldId, mouseBody, bfBody, FlxG.mouse.x, FlxG.mouse.y);
            isGrabbing = true;
            trace("bros been grabbed 😭😭");
        }
    }

    // Release on mouse release
    if (FlxG.mouse.justReleased && isGrabbing) {
        if (mouseJoint != 0) {
            box2d_destroyJoint(worldId, mouseJoint);
            mouseJoint = 0;
            
            // Apply throw impulse based on mouse velocity
            var mouseVelX = (FlxG.mouse.x - lastMouseX) / elapsed;
            var mouseVelY = (FlxG.mouse.y - lastMouseY) / elapsed;
            box2d_impulse(bfBody, mouseVelX , mouseVelY );
            
            trace("bye");
        }
        isGrabbing = false;
    }

    // makes a step in the physics simulation, self explanatory.
    box2d_step(worldId, elapsed);
    var pos = box2d_getPos(bfBody);
    var fpos = box2d_getPos(floor);

    if (box2dDebugEnabled) updateDebugSprites();
}

function updateDebugSprites():Void { 
    for (d in box2dDebugFixtures) {
        var pos = box2d_getPos(d.bodyId);
        var rot = box2d_getAngle(d.bodyId);
        if (pos == null) continue;
        
        var f = d.fixture;
        var s:FlxSprite = d.sprite;
        
        if (f.isCircle) {
            s.x = pos[0] - f.radius;
            s.y = pos[1] - f.radius;
        } else {
            s.x = pos[0] + f.ox - (f.hx / 2);
            s.y = pos[1] + f.oy - (f.hy / 2);
        }
        
        s.angle = -rot * 180.0 / Math.PI;
    }
}

function draw() {
    box2d_syncSprite(bfBody, bfChar, -200, -565);
}