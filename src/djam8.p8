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

gems = {}

stars = {}

player = {
	active = true,
	x = 0,
	y = 0,
	z = 0,
	w = 8,
	h = 8,
	dx = 0,
	dy = 0,
	speed = 2,
	speedwater = 1,
	speeddamage = 0.2,
	acceleration = 0.3,
	s_sprites = {6,7,8},
	canj = true,
	isj = false,
	s_sprite = 1,
	gravity = 1,
	jumpheight = 7,
	health = 3,
	ishurting = false
}

decayiterator = 0
decayinterval = 120

healthiterator = 0
timetotakedamage = 60
hasdoneinitdamage = false

portalangle = 0

function _init()
	decayinterval = 120
 loadlevel()
end

function loadlevel()
	gems = {}
	stars = {}
	generatemap()
	player.x = startx
	player.y = starty
	--setupcam()
	player.health = 3
	player.active = true
	for i = 1,rnd(8)+5,1 do
		spawngems()
	end
	addstars(2000)
end

function setupcam()
 cam.x = startx
 cam.y = starty
end

function _update60()
	moveplayer()
 movecam()
 decaylevel()
 updategems()
 updateportal()
end

function updateportal()
	if portalangle < 360 then
		portalangle+=1
	else
		portalangle = 0
	end
end

function check_flag_collision(player,flag)
    -- get the player's position and dimensions (assuming player has x, y, w, h properties)
    local px, py = player.x, player.y
    local pw, ph = player.w, player.h

    -- loop over the player's bounding box to check for collisions
    for x = px, px + pw - 1, 8 do
        for y = py, py + ph - 1, 8 do
            -- get the tile position in the map
            local tile_x = flr(x / 8)
            local tile_y = flr(y / 8)

            -- get the tile value and check if it has flag 7 set
            local tile = mget(tile_x, tile_y)
            if fget(tile, flag) then
                return true
            end
        end
    end

    return false
end

function addstars(starcount)
	for i=1,starcount,1 do
		star = {
			x = rnd(256*8)-64*8,
			y = rnd(128*8) -32 * 8,
		}
		add(stars,star)
	end
end

function moveplayer()
	if player.active then
		player.dx = lerp(player.dx,0,player.acceleration)
		player.dy = lerp(player.dy,0,player.acceleration)
		
		if btn(⬆️) then
			if check_flag_collision(player,0) then
				player.dy = lerp(player.dy,-player.speedwater,player.acceleration)
			elseif check_flag_collision(player,1) then
				player.dy = lerp(player.dy,-player.speed,player.acceleration)
			elseif check_flag_collision(player,2) then
				player.dy = lerp(player.dy,-player.speeddamage,player.acceleration)
			else
				player.dy = lerp(player.dy,-player.speedwater,player.acceleration)
			end
		end
		if btn(⬇️) then
			if check_flag_collision(player,0) then
				player.dy = lerp(player.dy,player.speedwater,player.acceleration)
			elseif check_flag_collision(player,1) then
				player.dy = lerp(player.dy,player.speed,player.acceleration)
			elseif check_flag_collision(player,2) then
				player.dy = lerp(player.dy,player.speeddamage,player.acceleration)
			else
				player.dy = lerp(player.dy,player.speedwater,player.acceleration)
			end
		end
		if btn(⬅️) then
			if check_flag_collision(player,0) then
				player.dx = lerp(player.dx,-player.speedwater,player.acceleration)
			elseif check_flag_collision(player,1) then
				player.dx = lerp(player.dx,-player.speed,player.acceleration)
			elseif check_flag_collision(player,2) then
				player.dx = lerp(player.dx,-player.speeddamage,player.acceleration)
			else
				player.dx = lerp(player.dx,-player.speedwater,player.acceleration)
			end
		end
		if btn(➡️) then
			if check_flag_collision(player,0) then
				player.dx = lerp(player.dx,player.speedwater,player.acceleration)
			elseif check_flag_collision(player,1) then
				player.dx = lerp(player.dx,player.speed,player.acceleration)
			elseif check_flag_collision(player,2) then
				player.dx = lerp(player.dx,player.speeddamage,player.acceleration)
			else
				player.dx = lerp(player.dx,player.speedwater,player.acceleration)
			end
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
	
	
		if check_flag_collision(player,2) then
			player.ishurting = true
		else
			player.ishurting = false
			hasdoneinitdamage = false
		end
	
		player.x += player.dx
		player.y += player.dy
	
		if player.ishurting then
			if hasdoneinitdamage == false then
				healthiterator = timetotakedamage
				hasdoneinitdamage = true
			end
			if healthiterator < 60 then
				healthiterator += 1
			else
				healthiterator = 0
				damage()
			end
		end
	end
	
	
	if player.health == 0 then
		player.active = false
		if btnp(❎) then
			decayinterval = 120
			loadlevel()
		end
	end
end

function decaylevel()
	if decayiterator < decayinterval then
		decayiterator += 1
	else
		mset(rnd(128)-1,rnd(64)-1,18)
		decayiterator = 0
	end
end

function spawngems()
	gem = {
		x = rnd(128*8),
		y = rnd(64*8),
		shineiterator = 1,
		secondaryiterator = 1
	}
	add(gems,gem)
end

function drawgems()
	for i,gem in ipairs(gems) do
		spr(gem.shineiterator+9,gem.x -4,gem.y-4)
	end
end

function updategems()
	for i,gem in ipairs(gems) do
		if gem.secondaryiterator < 5 then
			gem.secondaryiterator += 1
		else
		 gem.secondaryiterator = 0
			if gem.shineiterator < 4 then
				gem.shineiterator += 1
			else
				gem.shineiterator = 1
			end
		end
	end

end

function damage()
	player.health -= 1
end

function movecam()
	cam.x = lerp(cam.x,player.x,cam.easing)
	cam.y = lerp(cam.y,player.y,cam.easing)
	camera(cam.x-64,cam.y-64)
end

function _draw()
	cls(1)
	drawstarbg()
	map()
	if startx == 0 and starty == 0 then
		print("failed to generate level correctly :(",8)
	else
		spr_r(8,startx-8,starty-8,portalangle,2,2)
	end
	spr(player.s_sprite+5,player.x-4,player.y-4)
	drawgems()
	spr(1,player.x-4,player.y-4-player.z)
	drawhud()
	if player.active == false then
	 cls()
	 drawgameover()
	end
end

function drawstarbg()
    -- parallax factor to control star movement speed relative to the camera
    local parallax_factor = 0.5
    
    -- camera's visible area boundaries
    local cam_min_x = cam.x - 64
    local cam_max_x = cam.x + 64
    local cam_min_y = cam.y - 64
    local cam_max_y = cam.y + 64

    -- calculate the offset for the stars based on the camera position and parallax factor
    local offset_x = cam.x * parallax_factor
    local offset_y = cam.y * parallax_factor

    -- draw stars with parallax and occlusion culling
    for i, star in ipairs(stars) do
        local star_x = star.x - offset_x
        local star_y = star.y - offset_y

        -- handle wrapping of stars to keep them within the map area
        star_x = (star_x + 256 * 8) % (256 * 8) - 64 * 8
        star_y = (star_y + 128 * 8) % (128 * 8) - 32 * 8

        -- occlusion culling: only draw stars within the camera's visible area
        if star_x >= cam_min_x and star_x <= cam_max_x and
           star_y >= cam_min_y and star_y <= cam_max_y then
            pset(star_x, star_y, 7)
        end
    end
end

function drawgameover()
	camera(0,0)
	print("game over :(",64-20 -3,64+2,1)
	print("game over :(",64-20 -3,64+1,2)
	print("game over :(",64-20 -3,64,8)

	print("❎ restart",64-15 - 3,64+9,8)
	print("🅾️ bact to menu",64-25 -3,64+18,8)
end

function drawhud()
	rectfill(0+cam.x-64,0+cam.y-64,128+cam.x-64,8+cam.y-64,0)
	for i=0,player.health-1,1 do
		spr(9,i * 9 + cam.x-64,1+cam.y-64)
	end
end
-->8
--gfx

function spr_r(s,x,y,a,w,h)
    sw=(w or 1)*8
    sh=(h or 1)*8
    sx=(s%8)*8
    sy=flr(s/8)*8
    x0=flr(0.5*sw)
    y0=flr(0.5*sh)
    a=a/360
    sa=sin(a)
    ca=cos(a)
    for ix=0,sw-1 do
        for iy=0,sh-1 do
            dx=ix-x0
            dy=iy-y0
            xx=flr(dx*ca-dy*sa+x0)
            yy=flr(dx*sa+dy*ca+y0)
            if (xx>=0 and xx<sw and yy>=0 and yy<sh) then
                local col = sget(sx+xx,sy+yy)
                if col != 0 then
                    pset(x+ix,y+iy,col)
                end
            end
        end
    end
end

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

function drawloader()
	cls()
	print("loading...",64-15,64,7)
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
 	drawloader()
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
00000000bbbbbbbbaaaaaaaa33333333222222220000000000000000000000000000000002200220000000000000000000000000000000000000000000000000
00000000bbbbbbbbaaaaaaaa33333333222222220000000000000000000000000000000028822e82000000000000000000000000000000000000000000000000
00700700bbbbbbbbaaaaaaaa333333332222222200000000000000000000000000000000288888e20cccccc00cccccc00cccccc00cccccc00000000000000000
00077000bbbbbbbbaaaaaaaa3333333322222222000000000000000000000000000000002888888271c11c1cc1711c1cc1c1171cc1c11c170000000000000000
00077000bbbbbbbbaaaaaaaa3333333322222222000000000000000000000000000000000288882071c11c1cc1711c1cc1c1171cc1c11c170000000000000000
00700700bbbbbbbbaaaaaaaa33333333222222220000000005555550005555000005500000288200071cc1c00c17c1c00c1c71c00c1cc1700000000000000000
00000000bbbbbbbbaaaaaaaa33333333222222220000000051111115051111500051150000022000007ccc0000c7cc0000cc7c0000ccc7000000000000000000
00000000bbbbbbbbaaaaaaaa333333332222222200000000055555500055550000055000000000000007c0000007c000000c7000000c70000000000000000000
0000080ff0ee0000d8dd888d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000080ff0eee00008288222800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00908ffeeddddd00d8282e2800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00908feeedcc00008288222800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa988feddcccccc0d882888d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa988ffedccbbb0c8828888d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a998ffedbbaabb082882e2800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0aa99fffaa9aabbd8dd888d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbaa9aafff99aa0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbaabbdeff899a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0bbbccdeff889aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccccccddef889aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ccdeeef809000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddddeeff809000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000eee0ff0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ee0ff08000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000020202010000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000000c0733f1153f2150c0730c6750c0733f5153f3150c0733f1153f1153f1150c6750c07317307173070c07317306153060c0730c6750c0730c0730f3050c0730d3060c3060c0730c6750c0731030601206
311000000c772000040c7720d7720000016772000000d7720c0510c030137720c7300d0510d030147720d7700c770000000c7700d7700000016772000000d7720c7710c7430c7710c7430c7710c7750c77516700
01100000187520000418752197610000022772227622275222742227322273222732207511f7511d7511c7411c7421c7421c7421c7421c7421c742000000000028000290002b0003f115240003f1003f1003f115
0110000026300293002d300333002730029300323002e300283002a3002b3002c300248002880026800288000000000000000000a324063200a3000a320003000d31000300003000c3320a3000a3220a3000d332
011000230c550195500d5201855002010020003c84736827328072e8662c8662c866308673686700000000000c550195500d52018550020100a30016552165421653116531145611356111562115221056210522
0110000026300293002d300333002730029300323002e300283002a3002b3002c300248002880026800288000000000000000000a324063200a3000a320003000d31000300003000c3320a3000a3220a3000d332
270400000e0730d0730e0730d0730e0730d0730e0730d0730e0730d073140730e073140730e0730f0730e0730e0730d0730e073140730e073160730e0730e0730e0730e0730e0730f0730e0730e0730d0730e073
31100000187721800418772197721800022772180001977218051180301f772187301905119030207721977018770180001877019770180002277218000197721877118743187711874318771187751877522700
3110000024054250542e0522e0422e0222e0252e0150000030000310003a0003a0003a0003a000000000000030054310543a0523a0423a0223a0253a015000000000000000000000000000000000000000000000
__music__
00 01020003
00 04000105
00 06014a44
00 06010744
00 08424344

