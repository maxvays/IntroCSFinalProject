breed [players player]
breed [beams beam]
breed [enemies enemy]
breed [healthbars healthbar]
breed [powerups powerup]

globals [playerbeamspeed powerupcountdown wave gameover? upgrading? powertype deflection]

beams-own [beamspeed side]
players-own [powerupspawnrate normalshieldsize powerduration normalreload reload health numbeams damage accuracy shieldsize money speed shootspeed]
enemies-own [enemytype HP reload]
powerups-own [power durationleft]

to setup
  ca
  set wave 1
  set gameover? false
  set upgrading? false
  set powerupcountdown 1000
  set powertype 0
  ask patches with [pxcor = max-pxcor or pxcor = min-pxcor or pycor = max-pycor or pycor = min-pycor] [set pcolor red]
  create-players 1 [set color blue set playerbeamspeed 1 set normalreload 10 set powerduration 0 set powerupspawnrate 1 set numbeams 1 set speed 3 set damage 1 set accuracy 2 set shootspeed 10 set normalshieldsize 30 set shieldsize 30 set size 17 set shape "charactertank" set reload 0 set health 100]
  create-healthbars 1 [setxy [xcor] of turtle 0 [ycor] of turtle 0 - 8 set heading 0 set shape "healthbar" set size [health] of turtle 0 / 10 set color green]
  spawnenemies
  reset-ticks
end

to go
  if gameover? [showgameoverscreen stop]
  if count enemies = 0 [set wave wave + 1 set upgrading? true spawnenemies ]
  ifelse not upgrading? [every 5 [ifelse count enemies with [hidden? = true] > 4 [ask n-of 5 enemies with [hidden? = true] [set hidden? false]][ask enemies [set hidden? false]]]
    every .01[
      if powerupcountdown < 0 [spawnpowerup set powerupcountdown 1000 * (1 + 1 / [powerupspawnrate] of turtle 0)]
      set powerupcountdown powerupcountdown - 1
      ask powerups [powerupdate]
      every (10 / [shootspeed] of turtle 0)
      [ask players [set reload 0]]
      if mouse-down? [ask players with [reload = 0] [shoot set reload 1]]
      ask beams [beamupdate]
      ask enemies with [hidden? = false] [updateenemies]
      ask healthbars [healthupdate]
      ask players [playerupdate]
      tick]][showupgradescreen tick]
end


to powerupdate
  set durationleft durationleft - 1
  if durationleft = 0 [die]
end

to spawnpowerup
  create-powerups 1 [set durationleft 500 setxy random-xcor random-ycor set power random 3 set shape "square" set size 5]
end

to healthupdate
  set hidden? false
  if [ycor] of turtle 0 > (min-pycor + 8) [setxy [xcor] of turtle 0 [ycor] of turtle 0 - 8]
  set size [health] of turtle 0 / 10
end

to showgameoverscreen
  clear-turtles
  ask patch 70 0 [set plabel (word "Game over. You got to wave: " wave)]
end

to showupgradescreen
  ask turtle 0 [set hidden? true]
  ask turtle 1 [set hidden? true]
  ask beams [die]
  ask patch 70 0 [set plabel (word "Upgrading. You have " [money] of turtle 0 " money")]
end

to beamupdate
  if pcolor = red [die]
  fd 2 * beamspeed
end

to updateenemies
  if any? beams with [side = "player"] in-radius 4 [set HP HP - ([damage] of turtle 0) * (count beams with [side = "player"] in-radius 4) ask beams with [side = "player"] in-radius 4 [die]]
  if HP < 1 [ask turtle 0 [set money money + 1] die]
    ask enemies with [enemytype = "minion"] [ifelse reload = 0 [enemyminionshoot set reload 100 + random 100][set reload reload - 1] set heading towards turtle 0 if (distance turtle 0) > 50 [ifelse random 5 = 1 [fd .1][ifelse random 2 = 1 [set heading heading - 90 fd .1][set heading heading + 90 fd .1]]]]
  ask enemies with [enemytype = "sniper"] [ifelse reload = 0 [enemysnipershoot set reload 200 + random 100][set reload reload - 1] set heading towards turtle 0 ]
  ask enemies with [enemytype = "rocket"] [every 0.1 [set heading towards turtle 0 fd wave / 40]]
end

to enemyminionshoot
  hatch 1 [ fd 7 set breed beams set beamspeed 1 set side "enemyminion" set size 5 set shape "bullet" set heading towards turtle 0]
end

to enemysnipershoot
  hatch 1 [fd 7 set breed beams set beamspeed 2 set side "enemysniper" set size 8 set shape "bullet" set heading towards turtle 0]
end

to shoot
  ifelse reload = 0 [hatch numbeams [ set heading heading + random-float (20 / accuracy) - random-float (20 / accuracy) set label "" set size 7 set breed beams set beamspeed playerbeamspeed set side "player" set shape "bullet" fd 4] set reload 1][]
end

to playerupdate
  if any? powerups in-radius 4 [set powertype [power] of one-of (powerups in-radius 4) ask powerups in-radius 4 [die]]
  ifelse powertype = 4 [set deflection true] [ifelse powertype = 3 [set normalreload shootspeed set shootspeed 100 set powerduration 500][ifelse powertype = 2 [set normalshieldsize shieldsize set shieldsize 180 set powerduration 700][ifelse powertype = 1 [set money money + count enemies with [hidden? = false] ask enemies with [hidden? = false] [die]][set shootspeed normalreload set shieldsize normalshieldsize]]]]
  if powerduration > 0 [set powerduration powerduration - 1]
  if powerduration = 0 [set powertype 0]
  set hidden? false
  if mouse-inside? [set heading towards patch mouse-xcor mouse-ycor]
 if any? beams with [side = "enemyminion"] in-radius 3 [ask beams with [side = "enemyminion"] in-radius 3 [ifelse (heading > 360 - [shieldsize] of turtle 0 and [heading] of turtle 0 < [shieldsize] of turtle 0 and (heading + [shieldsize] of turtle 0) mod 360 > [heading] of turtle 0) or (heading < [shieldsize] of turtle 0 and [heading] of turtle 0 > 360 - [shieldsize] of turtle 0 and ([heading] of turtle 0 + [shieldsize] of turtle 0) mod 360 > heading) or (not (heading > 360 - [shieldsize] of turtle 0 and [heading] of turtle 0 < [shieldsize] of turtle 0) and not (heading > [shieldsize] of turtle 0 and [heading] of turtle 0 > 360 - [shieldsize] of turtle 0) and heading + [shieldsize] of turtle 0 > [heading] of turtle 0 and heading - [shieldsize] of turtle 0 < [heading] of turtle 0) [die][ask turtle 0 [set health health - 1] die]]]
  if any? beams with [side = "enemysniper"] in-radius 3 [ask beams with [side = "enemysniper"] in-radius 3 [ifelse (heading > 360 - [shieldsize] of turtle 0 and [heading] of turtle 0 < [shieldsize] of turtle 0 and (heading + [shieldsize] of turtle 0) mod 360 > [heading] of turtle 0) or (heading < [shieldsize] of turtle 0 and [heading] of turtle 0 > 360 - [shieldsize] of turtle 0 and ([heading] of turtle 0 + [shieldsize] of turtle 0) mod 360 > heading) or (not (heading > 360 - [shieldsize] of turtle 0 and [heading] of turtle 0 < [shieldsize] of turtle 0) and not (heading > [shieldsize] of turtle 0 and [heading] of turtle 0 > 360 - [shieldsize] of turtle 0) and heading + [shieldsize] of turtle 0 > [heading] of turtle 0 and heading - [shieldsize] of turtle 0 < [heading] of turtle 0) [die][ask turtle 0 [set health health - 5] die]]]
  if any? enemies with [enemytype = "rocket"] in-radius 2 [set health health - 10 ask enemies with [enemytype = "rocket"] in-radius 2 [die]]
  if health < 1 [set gameover? true die]
end

to w
  ask players [fd speed]
end

to a
  ask players [set heading heading - 90 fd speed set heading heading + 90]
end

to s
  ask players [bk speed]
end

to d
  ask players [set heading heading + 90 fd speed set heading heading - 90]
end

to spawnenemies
  create-enemies 5 * wave [set hidden? true set HP 2 ifelse wave < 2 [set enemytype "minion"  set shape "person"] [ifelse wave > 4 [ifelse random 5 = 1 [set enemytype "sniper" set shape "person soldier" set HP 1] [ifelse random 5 = 1 [set enemytype "rocket" set shape "rocket" set HP 1] [set enemytype "minion"  set shape "person"]]] [ifelse random 3 = 1 [set enemytype "rocket" set shape "rocket" set HP 1] [set enemytype "minion"  set shape "person"]]] set color red set size 15 ifelse random 2 = 1 [setxy (random 2 * 2 - 1) * (max-pxcor - 10) (random ((max-pycor - 10) * 2) - (max-pycor - 10))][setxy (random (2 * (max-pxcor - 10)) - (max-pxcor - 10)) (random 2 * 2 - 1) * (max-pycor - 10) ]]
  
end
