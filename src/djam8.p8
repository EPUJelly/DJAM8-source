pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main
startx = 0
starty = 0

cam = {
	x = 0,
	y = 0,
	easing = 0.1
}

player = {
	x = 0,
	y = 0,
	z = 0,
	dx = 0,
	dy = 0,
	speed = 2,
	speedwater = 1,
	acceleration = 0.3,
	s_sprites = {6,7,8},
	canj = true,
	isj = false,
	s_sprite = 1,
	gravity = 1,
	jumpheight = 7
}

iterator1 = 0


function _init()
 loadlevel()
end

function loadlevel()
	generatemap()
	player.x = startx
	player.y = starty
	--setupcam()
end

function setupcam()
 cam.x = startx
 cam.y = starty
end

function _update60()
	moveplayer()
 movecam()
end

function moveplayer()
	player.dx = lerp(player.dx,0,player.acceleration)
	player.dy = lerp(player.dy,0,player.acceleration)
	
	if btn(⬆️) then
		player.dy = lerp(player.dy,-player.speed,player.acceleration)
	end
	if btn(⬇️) then
		player.dy = lerp(player.dy,player.speed,player.acceleration)
	end
	if btn(⬅️) then
		player.dx = lerp(player.dx,-player.speed,player.acceleration)
	end
	if btn(➡️) then
		player.dx = lerp(player.dx,player.speed,player.acceleration)
	end
	
	if player.z > 0 then
		player.z -= player.gravity
		player.canj = false
	else
		player.canj = true
	end
	
	
	
	if player.canj then
		if btnp(❎) then
			player.isj = true
			player.z = 0.1
			player.gravity = -player.gravity
		end
	end
	if player.isj then
		if player.z > player.jumpheight then
			player.gravity = -player.gravity
		end
	end
	
	if player.z < 3 then
		player.s_sprite = player.s_sprites[1] -5
	elseif player.z < 4 and player.z > 3 then
		player.s_sprite = player.s_sprites[2] -5
	elseif player.z < 5 and player.z > 4 then
		player.s_sprite = player.s_sprites[3] -5
	end
	
	

	
	player.x += player.dx
	player.y += player.dy
end

function movecam()
	cam.x = lerp(cam.x,player.x,cam.easing)
	cam.y = lerp(cam.y,player.y,cam.easing)
	camera(cam.x-64,cam.y-64)
end

function _draw()
	cls(1)
	map()
	if startx == 0 and starty == 0 then
		print("failed to generate level correctly :(",8)
	else
		spr(16,startx-8,starty-8,2,2)
	end
	spr(player.s_sprite+5,player.x-4,player.y-4)
	spr(1,player.x-4,player.y-4-player.z)
	
end
-->8
--particles

function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,c_table)
    local fx={
        x=x,
        y=y,
        t=0,
        die=die,
        dx=dx,
        dy=dy,
        grav=grav,
        grow=grow,
        shrink=shrink,
        r=r,
        c=0,
        c_table=c_table
    }
    add(effects,fx)
end

function update_fx()
    for fx in all(effects) do
        --lifetime
        fx.t+=1
        if fx.t>fx.die then del(effects,fx) end

        --color depends on lifetime
        if fx.t/fx.die < 1/#fx.c_table then
            fx.c=fx.c_table[1]

        elseif fx.t/fx.die < 2/#fx.c_table then
            fx.c=fx.c_table[2]

        elseif fx.t/fx.die < 3/#fx.c_table then
            fx.c=fx.c_table[3]

        else
            fx.c=fx.c_table[4]
        end

        --physics
        if fx.grav then fx.dy+=.5 end
        if fx.grow then fx.r+=.1 end
        if fx.shrink then fx.r-=.1 end

        --move
        fx.x+=fx.dx
        fx.y+=fx.dy
    end
end

function draw_fx()
    for fx in all(effects) do
        --draw pixel for size 1, draw circle for larger
        if fx.r<=1 then
            pset(fx.x,fx.y,fx.c)
        else
            circfill(fx.x,fx.y,fx.r,fx.c)
        end
    end
end

-- motion trail effect
function trail(x,y,w,c_table,num)

    for i=0, num do
        --settings
        add_fx(
            x+rnd(w)-w/2,  -- x
            y+rnd(w)-w/2,  -- y
            40+rnd(30),  -- die
            0,         -- dx
            0,         -- dy
            false,     -- gravity
            false,     -- grow
            false,     -- shrink
            1,         -- radius
            c_table    -- color_table
        )
    end
end

-- explosion effect
function explode(x,y,r,c_table,num)
    for i=0, num do

        --settings
        add_fx(
            x,         -- x
            y,         -- y
            30+rnd(25),-- die
            rnd(2)-1,  -- dx
            rnd(2)-1,  -- dy
            false,     -- gravity
            false,     -- grow
            true,      -- shrink
            r,         -- radius
            c_table    -- color_table
        )
    end
end

-- fire effect
function fire(x,y,w,c_table,num)
    for i=0, num do
        --settings
        add_fx(
            x+rnd(w)-w/2,  -- x
            y+rnd(w)-w/2,  -- y
            30+rnd(10),-- die
            0,         -- dx
            -.5,       -- dy
            false,     -- gravity
            false,     -- grow
            true,      -- shrink
            2,         -- radius
            c_table    -- color_table
        )
    end
end



-->8

-->8
--math

function lerp(a, b, t)
	return a + (b - a) * t
end

function clamp(low, n, high) return math.min(math.max(n, low), high) end

--map generation

--returns the number of map tile c neighbouring (x,y)
--returns boolean if n is true
function getneighbours(x,y,c,n)
 local nc=0--neighbouring shallow tiles
 for j=0.125,1,0.125 do--iterate over neighbouring tiles
  local nx,ny=x+flr(cos(j)+.5),y+flr(sin(j)+.5)
  if mget(nx,ny)==c then
   nc+=1
   if n then
    return true
   end
  end
 end
 if n then
  return false
 end
 return nc
end

function generatemap()
 local mx,my=127,63
 for x=0,mx do
  for y=0,my do
   mset(x,y,flr(rnd(2))+4)
  end
 end
 --smooth noise
 for i=0,4 do--smoothing iterations
  for x=0,mx do
   for y=0,my do
    local nc=getneighbours(x,y,4)--neighbouring shallow tiles
    --fiddle with these numbers to modify idland frequency
    if nc>5 then
     mset(x,y,4) 
    elseif nc<3 then
     mset(x,y,5)
    end
   end
  end
 end
 --add layers of ground
 for i=3,2,-1 do
  for x=0,mx do
   for y=0,my do
    if not (getneighbours(x,y,i+2,true) or getneighbours(x,y,i+3,true)) then
     mset(x,y,i)
    end
   end
  end
 end
 --add starting point
 local valid=false
 bx,by=0,0
 while not valid do
  bx,by=flr(rnd(mx)),flr(rnd(my))
  if mget(bx,by)<=3 and getneighbours(bx,by,2,true) then
   startx = bx*8
   starty = by*8
   valid=true
  end
 end
end
__gfx__
00000000bbbbbbbbaaaaaaaa33333333222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbbaaaaaaaa33333333222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700bbbbbbbbaaaaaaaa33333333222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000bbbbbbbbaaaaaaaa33333333222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000bbbbbbbbaaaaaaaa33333333222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700bbbbbbbbaaaaaaaa33333333222222221111111105555550005555000005500000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbbaaaaaaaa33333333222222221111111151111115051111500051150000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbbaaaaaaaa33333333222222221111111105555550005555000005500000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
