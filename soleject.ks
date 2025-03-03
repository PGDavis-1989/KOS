runoncepath("0:/lib/ejectionTransfer.ks"). 
runoncepath("0:/lib/executeManeuver.ks"). 
runoncepath("0:/lib/systems.ks").
runoncepath("0:/lib/systems.ks").

set targetOrbit to 25 * 1_000_000_000. //orbit in GM

//create and execute ejection maneuver to target orbit
ejectionPrograde().
warpToNextManeuver(90).
wait 1.
executeNextManeuver().
remove nextNode.

set solOrbit to ship:orbit:nextpatch.

//tune apoapsis
print "Tuning orbit.".
print solOrbit:apoapsis.
until solOrbit:apoapsis >= targetOrbit{
    limitThrust(1).
    lock Throttle to 0.5. 
}
lock throttle to 0.
limitThrust(100).

//time warp to Sol SOI then create circulariztion node
until ship:orbit:body = Sun {
    set warp to 5.
}
set warp to 0.
createCircNode("apo").