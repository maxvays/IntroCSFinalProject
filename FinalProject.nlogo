
breed [players player]
breed [beams beam]
breed [enemies enemy]

globals [wave gameover? upgrading?]

beams-own [side]
players-own [reload health accuracy shieldsize money speed shootspeed]
enemies-own [enemytype HP reload]

to setup
  ca
  set wave 1
  set gameover? false
  set upgrading? false
  ask patches with [pxcor = max-pxcor or pxcor = min-pxcor or pycor = max-pycor or pycor = min-pycor] [set pcolor red]
  create-players 1 [set accuracy 2 set shootspeed 10 set shieldsize 30 set size 17 set shape "charactertank" set reload 0 set health 100 set label health]
  spawnenemies
  reset-ticks
end

to go
  if gameover? [showgameoverscreen stop]
  if count enemies = 0 [set wave wave + 1 spawnenemies set upgrading? true]
  ifelse not upgrading? [every 5 [ifelse count enemies with [hidden? = true] > 4 [ask n-of 5 enemies with [hidden? = true] [set hidden? false]][ask enemies [set hidden? false]]]
    every .01[every (10 / [shootspeed] of turtle 0) [ask players [set reload 0]]
  if mouse-down? [ask players with [reload = 0] [shoot set reload 1]]
  ask beams [beamupdate]
    ask enemies with [hidden? = false] [updateenemies]
    ask players [playerupdate]
      tick]][showupgradescreen tick]
end

to showgameoverscreen
end

to showupgradescreen
  ask turtle 0 [set hidden? true]
  ask beams [die]
  ask patch 70 0 [set plabel (word "Upgrading. You have " [money] of turtle 0 " money")]
end

to beamupdate
  if pcolor = red [die]
  fd 2
end

to updateenemies
  if any? beams with [side = "player"] in-radius 3 [set HP HP - count beams with [side = "player"] in-radius 3 ask beams with [side = "player"] in-radius 3 [die]]
  if HP < 1 [die]
  ask enemies with [enemytype = "minion"] [ifelse reload = 0 [enemyshoot set reload 100 + random 100][set reload reload - 1] set heading towards turtle 0 if (distance turtle 0) > 50 [ifelse random 5 = 1 [fd .1][ifelse random 2 = 1 [set heading heading - 90 fd .1][set heading heading + 90 fd .1]]]]
end

to enemyshoot
  hatch 1 [fd 7 set breed beams set side "enemy" set size 5 set shape "bullet" set heading towards turtle 0]
end

to shoot
  ifelse reload = 0 [hatch 1 [set heading heading + random-float (10 / accuracy) - random-float (10 / accuracy) set label "" set size 7 set breed beams set side "player" set shape "bullet" fd 4] set reload 1][]
end

to playerupdate
  set hidden? false
  if mouse-inside? [set heading towards patch mouse-xcor mouse-ycor]
  if any? beams with [side = "enemy"] in-radius 3 [ask beams with [side = "enemy"] in-radius 3 [ifelse (heading > 360 - [shieldsize] of turtle 0 and [heading] of turtle 0 < [shieldsize] of turtle 0 and (heading + [shieldsize] of turtle 0) mod 360 > [heading] of turtle 0) or (heading < [shieldsize] of turtle 0 and [heading] of turtle 0 > 360 - [shieldsize] of turtle 0 and ([heading] of turtle 0 + [shieldsize] of turtle 0) mod 360 > heading) or (not (heading > 360 - [shieldsize] of turtle 0 and [heading] of turtle 0 < [shieldsize] of turtle 0) and not (heading > [shieldsize] of turtle 0 and [heading] of turtle 0 > 360 - [shieldsize] of turtle 0) and heading + [shieldsize] of turtle 0 > [heading] of turtle 0 and heading - [shieldsize] of turtle 0 < [heading] of turtle 0) [die][ask turtle 0 [set health health - 1] die]]]
  set label health
  if health < 1 [set gameover? true die]
end

to w
  ask players [fd 5]
end

to a
  ask players [set heading heading - 90 fd 5 set heading heading + 90]
end

to s
  ask players [bk 5]
end

to d
  ask players [set heading heading + 90 fd 5 set heading heading - 90]
end

to spawnenemies
  create-enemies 5 * wave [set hidden? true set HP 2 set enemytype "minion" set shape "person" set color red set size 15 ifelse random 2 = 1 [setxy (random 2 * 2 - 1) * (max-pxcor - 10) (random 2 * (max-pycor - 10) - (max-pycor - 10))][setxy (random 2 * (max-pxcor - 10) - (max-pxcor - 10)) (random 2 * 2 - 1) * (max-pycor - 10) ]]
end

;tempheading = [heading] of turtle
;ifelse (heading > 180 and [heading] of turtle 0 + 45 > heading and ([heading] of turtle 0 - 45) mod 360 < heading) or (heading < 180 and ([heading] of turtle 0 + 45) mod 360 > heading and ([heading] of turtle 0 - 45) < heading)
