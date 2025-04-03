runoncepath("0:/lib/ejectionTransfer.ks"). 
runoncepath("0:/lib/executeManeuver.ks"). 
runoncepath("0:/lib/systems.ks").
runoncepath("0:/lib/systems.ks").
runoncepath("0:/lib/units.ks").

set targetOrbit to 25 * Gm. //orbit in GM
print targetOrbit.
//create and execute ejection maneuver to target orbit
ejectionPrograde().
warpToNextManeuver(90).
wait 1.
executeNextManeuver().
remove nextNode.

//time warp to Sol SOI
until ship:orbit:body = Sun {
    set warp to 6.
}
set warp to 0.

//tune apoapsis
print "Tuning orbit.".
lock steering to prograde.
wait 5.
until ship:apoapsis >= targetOrbit{
    limitThrust(1).
    lock Throttle to 0.5. 
}
lock throttle to 0.
limitThrust(100).

//create circulization maneuver
createCircNode("apo").
sas on.
