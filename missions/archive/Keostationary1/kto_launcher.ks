//imports
runoncepath("0:/lib/liftoff.ks"). 
runoncepath("0:/lib/CLS_dv.ks"). 
runoncepath("0:/lib/executeManeuver.ks"). 
runoncepath("0:/lib/missionLogger.ks"). 

set keoAltitude to 2_863_334.
set ktoPeriapsisAltitude to 1_222_703.
set keoPeriod to body("Kerbin"):rotationPeriod. //6 hour keo synchronous orbit
set ktoPeriod to 2/3 * keoPeriod. //4 hour period of the resonant orbit
set orbitTuningDistance to 1_500. 
set flightPhase to 0.
set timeOffset to 180. //warp time offset; i.e. how far away from node to stop time warp

//determine what phase of the flight we're in
if ship:status = "prelaunch" {set flightPhase to 1.}
if ship:status = "orbiting" and ship:orbit:period < ktoPeriod {set flightPhase to 2.} //get to transfer orbit
if ship:status = "orbiting" and ship:orbit:period >= 0.98*ktoPeriod {set flightPhase to 3.} //ready to deploy payloads


//
////////PHASE 1: Get to 100km parking orbit
//

if flightPhase = 1 {
    clearLogs().
    logEntry("Launch phase started.").
    print "Launch Phase started".
    wait 5.
    liftoff(100,0,86).
    set flightPhase to 2.
    clearScreen.
}
    

//
////////PHASE 2: Get to Keostationary Transfer Orbit
//
if flightPhase = 2 {
    logEntry("Phase 2: Transfer to KTO started.").
    print "Phase 2: Transfer to KTO started.".

    //Raise Apo to CLOSE to KEO altitude
    logEntry("Raising Apoapsis.").
    set ktoApoapsisDv to BurnPeriapsis_TargetApoapsis(keoAltitude - orbitTuningDistance).//calculate dv to raise apo
    local nd is node(time:seconds + eta:periapsis, 0, 0, ktoApoapsisDv). //create node, execute maneuver
    add nd.
    logEntry("Time warp to periapsis.").
    wait 5.
    warpTo(time:seconds + eta:periapsis - timeOffset). //warp to next maneuver
    wait until kuniverse:timewarp:rate = 1.
    logEntry("Time warp ended. Time to periapsis: " + round(eta:periapsis,1)).
    executeNextManeuver().
    remove nd.
    clearScreen.
    logApoapsis().
    logEntry("Apoapsis raised. Tuning.").
    set canStage to false. //turn off autostaging

    //dial in the apoapsis with tiny burn
    until ship:orbit:apoapsis >= keoAltitude{
        limitThrust(1).
        lock throttle to 0.5.
    }
    limitThrust(100).
    lock throttle to 0.
    wait 1.
    logEntry("KTO maneuver Apoapsis:" + ship:orbit:apoapsis).

    //
    //////// Raise periapsis to CLOSE to resonant orbit
    //

    logEntry("Raising Periapsis").
    set ktoPeriapsisDv to BurnApoapsis_TargetPeriapsis(ktoPeriapsisAltitude - orbitTuningDistance).
    local nd is node(time:seconds + eta:apoapsis, 0, 0, ktoPeriapsisDv). //create node, execute maneuver
    add nd.
    logEntry("Time warp to apoapsis.").
    warpTo(time:seconds + eta:apoapsis - timeOffset). //warp to next maneuver
    wait until kuniverse:timewarp:rate = 1.
    logEntry("Time warp ended. Time to Apoapsis: " + round(eta:periapsis,1)).
    executeNextManeuver().
    remove nd.
    logPeriapsis().
    logEntry("Periapsis Raised. Tuning.").

    //tune the kto by period, rather than by periapsis
    until ship:orbit:period >= ktoPeriod{
        limitThrust(1).
        lock throttle to 0.5.
    }
    limitThrust(100).
    lock throttle to 0.
    logEntry("KTO orbit tuned. Final KTO parameters:").
    logCurrentOrbit().    

    set flightPhase to 3.
    logEntry("KTO maneuver completed.").
}

//
////////PHASE 3: Deploy KeoSat
//
if flightPhase = 3 {
    logEntry("Performing payload inventory.").
    wait until kuniverse:activeVessel = ship. //mke sure the ship is fully loaded in the scene
    wait 1.
    //determine how many payloads are left
    list Processors in remainingCPU.
    set vesselsLeft to remainingCPU:length.
    logEntry("Vessels remaining: " + vesselsLeft).

    if vesselsLeft = 1 { //mission starts with 4 processors. Deorbit once satellites are all deployed.
        deorbit().
        logEntry("End of Mission.").
    } 

    else {//if there's a payload remaining, orient the ship and deploy it
        //Launch order: KeoSat 3, KeoSat 2, KeoSat 1
        set payload to "KeoSat " + (vesselsLeft - 1).
        logEntry("Preparing payload delivery: " + payload).

        //warp to apoapsis
        logEntry("Warping to 300 seconds of apoapsis.").
        warpTo(time:seconds + eta:apoapsis - timeOffset).
        wait until kuniverse:timewarp:rate = 1.

        //orient prograde
        logEntry("Orienting for delivery.").
        lock steering to ship:prograde.
        wait 30.
        logEntry("Oriented.").

        //deploy satellite
        logEntry("Deploying payload: " + payload).
        stage.
        wait 2.
        logEntry("Payload deployed.").
        logEntry("Switching vessels for final insertion.").
        switchToVessel(payload).
    }
}

local function deorbit {
    //calculate deorbit delta v
    set deorbitDV to BurnApoapsis_TargetPeriapsis(0). 
    logEntry("Calculated deorbit dV: " + deorbitDV).

    //create retrograde maneuver, execute.
    local nd is node(time:seconds + eta:apoapsis, 0, 0, -deorbitDV). 
    add nd.
    executeNextManeuver().
    logEntry("Final deorbit:").
    logCurrentOrbit().
}
