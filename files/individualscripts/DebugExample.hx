//CNE BOX2D DEBUG KIT EXAMPLE, SET UP AS EXPLICITLY TOLD OR ELSE IT MAY NOT WORK!!

import flixel.util.FlxSpriteUtil; // imports!!! important!!!

// debug settings and variables, add to top of script
var box2dDebugEnabled:Bool = true;
var box2dDebugGroup:FlxGroup;
var box2dDebugFixtures:Array<Dynamic> = [];

function postCreate() {
    // debug group and sprites, add anywhere in your postCreate function.
    box2dDebugGroup = new FlxGroup();
    add(box2dDebugGroup);
    if (box2dDebugEnabled) {
        createDebugForBody(objID); // add your objects here
    }
}

// add below post create function
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

    if (box2dDebugEnabled) updateDebugSprites(); // add anywhere inside ur update function
}

// add below update function
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