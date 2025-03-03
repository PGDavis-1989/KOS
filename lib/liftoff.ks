//imports
runoncepath("0:/lib/lib_lazcalc.ks"). 
runoncepath("0:/lib/CLS_dv.ks").
runoncepath("0:/lib/lib_navball.ks").
runoncepath("0:/lib/executeManeuver.ks").
runoncepath("0:/lib/systems.ks").
runoncepath("0:/lib/missionLogger.ks").

global function liftoff{
    //default launch to 80 km lko
    parameter myOrbit is 80. set myOrbit to myOrbit * 1000. //orbit can be passed in km    
    parameter myInc is 0. //altitude can be passed in degrees. Positive is north, negative is south.
    parameter gravityTurnPitch is 85.
    set gravityTurnSpeed to 50.
    set myHeading to 90. //default heading is due east for an equatorial orbit   
    set startDV to ship:deltaV:vacuum. //get the launch dv for calculating dv to orbit later  

    if myInc <> 0 {//calculates a heading for inclined orbits
        set launchData to LAZcalc_init(myOrbit, myInc).
        set myHeading to LAZcalc(launchData).
    }
    clearscreen.
    print "Target orbit: " + myOrbit.
    print "Target inclination: " + myInc.
    print "Calculated heading: " + round(myHeading, 1).
    sas off.

    logLiftoff(myOrbit, myInc, gravityTurnPitch, myHeading).

    //set throttle to full
    set power to 1.
    lock throttle to power.
    stage. //stage
    createAscentFile().
    SET STEERINGMANAGER:ROLLPID:KP TO 0.
    SET STEERINGMANAGER:ROLLPID:KI TO 0.
    lock steering to up. print "Lock steering up.".

    wait until verticalspeed > gravityTurnSpeed. 

    triggerStaging().
    deploySystems().
    logEntry("Autostaging activated. Gravity turn started.").
    gravityTurnPID(myOrbit, myHeading, gravityTurnPitch).    

    //unlock controls
    lock throttle to 0.
    sas on.
    unlock steering.
    unlock throttle.
    set finalDV to ship:deltaV:vacuum.
    set usedDV to round(startDV - finalDV,0).

    logEntry("Launch phase ended.").
    logEntry("Staging off.").
    logEntry("Final parking orbit parameters:").
    logEntry("DeltaV used: " + usedDV + " m/s").
    logCurrentOrbit().
}

function gravityTurnPID{
    parameter targetApo.
    parameter targetHeading.
    parameter pitchAngle is 85.
    lock steering to heading(targetHeading, pitchAngle).

    until vAng(ship:facing:vector, heading(myHeading, pitchAngle):vector) <= 0.3{
        logAscentProfile().
    }.
    print "In position.".
        
    until vAng(ship:srfPrograde:vector, ship:facing:vector) <= 0.3{
        logAscentProfile().
    }.
    clearScreen.
    print "Following the surface Prograde." at (0,0).
    lock steering to srfPrograde.

    set throttlePID to PIDLoop(1.05, 10, 0.03, 0.01, 1).
    
    //First target is 90 seconds to apoapsis until 36km
    set throttlePID:SETPOINT to 90.
    set wanted_throttle to 1.
    lock throttle to wanted_throttle.
    
    print "  Target ETA: " + throttlePID:SETPOINT + "   " at (0,4).

    until ship:altitude >= 36000 {
        print ("--- THROTTLE PID ---") at (0,6).
        set wanted_throttle to throttlePID:UPDATE(time:seconds, ETA:apoapsis).
        showThrottlePIDInfo().
        logAscentProfile().
        wait 0.
    }
    
    //second target is 80 seconds to apoapsis until target apoapsis is reached
    lock steering to Prograde.
    print "Following the orbit Prograde.     " at (0,0).
    set throttlePID:SETPOINT to 80.
    
    print "  Target ETA: " + throttlePID:SETPOINT + " s   " at (0,4).

    until ship:apoapsis >= targetAPO {
        set wanted_throttle to throttlePID:UPDATE(time:seconds, ETA:apoapsis).
        showThrottlePIDInfo().
        logAscentProfile().
        wait 0.
    }

    //---> NEW SETPOINT: 20 sec to APO
    set throttlePID:SETPOINT to 20.
    print "  Target ETA: " + throttlePID:SETPOINT + " s   " at (0,4).

    until ship:periapsis > 0 or ETA:apoapsis < 10 {
        set wanted_throttle to throttlePID:UPDATE(time:seconds, ETA:apoapsis).
        showThrottlePIDInfo().
        logAscentProfile().
        wait 0.
    }

    //use a pitch PID to circularize

    set pitchPID to PIDLoop(1.05, 10, 0.03, -5, 5).
    //---> NEW SETPOINT: 10 sec to APO
    set pitchPID:SETPOINT to 10.

    lock throttle to 0.3.
    clearscreen.

    print "  Target ETA: " + pitchPID:SETPOINT + " s   " at (0,4).
    local oldEcc is ship:orbit:eccentricity.
    wait 0.

    until ship:orbit:eccentricity <= 0.00001 or ship:orbit:eccentricity > oldEcc {
        print ("--- PITCH PID ---") at (0,6).
        set wanted_pitch to pitchPID:UPDATE(time:seconds, ETA:apoapsis).
        lock steering to heading(myHeading, wanted_pitch).
        print "    Apoapsis: " + round(ship:apoapsis,2) + " m   " at (0,2).
        print "ETA:Apoapsis: " + round(ETA:apoapsis,2) + " s   " at (0,3).
        print "Eccentricity: " + round(ship:orbit:eccentricity,5) + "   " at (0,4).
        
        print "       Pitch: " + round(wanted_pitch,2) + "°    " at (0,7).
        set oldEcc to ship:orbit:eccentricity.
        if ETA:apoapsis < 0.1 {break.}
        wait 0.
    }
}

function showThrottlePIDInfo{
    print "    Apoapsis: " + round(ship:apoapsis,2) + " m   " at (0,2).
    print "ETA:Apoapsis: " + round(ETA:apoapsis,2) + " s   " at (0,3).
        
    print "    Throttle: " + round(throttle,2) + "   " at (0,7).
}