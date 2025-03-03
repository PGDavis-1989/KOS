//imports
runoncepath("0:/lib/CLS_dv.ks"). 
runoncepath("0:/lib/executeManeuver.ks"). 
runoncepath("0:/lib/missionLogger.ks"). 
runoncepath("0:/lib/systems.ks").

set payload to ship:name.
set keoPeriod to body("Kerbin"):rotationPeriod. //KEO orbit period is 6 hours
set keoAltitude to 2_863_334. //altitude of KEO orbit
set orbitTuningDistance to 3_000. 

//determine flight mode.
//Flight mode 1: Payload is on the pad in the fairing.
//Flight mode 2: Payload was just deployed. Needs to execute maneuver to final KEO orbit.
//Flight mode 3: Payload is in KEO orbit. Likely selected from Tracking Station.

local flightMode is 0.
if ship:status = "orbiting" and ship:orbit:period < keoPeriod {set flightMode to 2.} //in transfer orbit.
if ship:status = "orbiting" and ship:orbit:period >= 0.98*keoPeriod {set flightMode to 3.} //in final KEO orbit

if flightMode = 1{
    print "flight mode 1.".
}
else if flightMode = 2{
    DELETEPATH("0:/log/" + payload + "_Mission.txt"). //clear the last mission log
    logEntry(payload + " active.").
    logEntry("Preparing transfer to final KEO orbit.").
    print "Preparing transfer to final KEO orbit".
    //open terminal
    set terminal:width to 45.
    set terminal:height to 26.

    core:part:getModule("kOSProcessor"):doEvent("Open Terminal").

    //get CLOSE to final orbit
    set dv to BurnApoapsis_TargetPeriapsis(keoAltitude - orbitTuningDistance).
    logEntry("Calculated maneuver dV: " + dv).
    local nd is node(time:seconds + eta:apoapsis, 0, 0, dv). //create node, execute maneuver
    add nd.
    executeNextManeuver(). 
    logEntry("First maneuver complete.").
    print "First maneuver complete.".

    logEntry("Tuning orbital period.").
    print "Tuning orbital period.".
    //tune the kto by period, rather than by periapsis
    until ship:orbit:period >= keoPeriod{
        limitThrust(1).
        lock throttle to 0.5.
    }
    limitThrust(100).
    lock throttle to 0.
    logEntry("KEO orbit tuned. Final KEO parameters:").
    logCurrentOrbit().  
    print "KEO orbit achieved.".
    print "Final orbital period: " + ship:orbit:period.

    logEntry("Returning to launch vessel.").
    switchToVessel("KTO").
}
else{
    print "flight mode 3.".
}