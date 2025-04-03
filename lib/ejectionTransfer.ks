runoncepath("0:/lib/missionLogger.ks").

function ejectionPrograde{
    parameter targetOrbit is 25. //default orbit is between Duna and Dres
    logEntry("*******************Creating Ejection Maneuver**********************").
    logEntry("Target Orbit: " + targetOrbit + " Gm").
    set targetOrbit to targetOrbit * 1_000_000_000. //convert to Gigameters
    set startDV to 1_000. 
    set timeBuffer to 60. //seconds away from ship to make first test maneuver
    set stepTime to 2. //how big each time step is in the hill climbing algo    
    set stepDV to 0.25. //how big each dV step is when 
    set orbitBuffer to 1_000_000.

    //create a maneuver node with enough dv to eject
    set ejectionNode to node(TimeSpan(timeBuffer), 0, 0, startDV).
    add ejectionNode.
    logEntry("Initial maneuver created. Finding best ejection time...").

    //find the first maneuver (moving counterclockwise) that is prograde to Kerbin
    //i.e. if our intial node is retrograde, step forward until prograde;
    //if initial node is already prograde, step back until the next backward step is retrograde and stop.
    if isPrograde(ejectionNode){
        print "Starting prograde.".
        until isRetrograde(ejectionNode){
            //move the ejection node back
            set ejectionNode:ETA to ejectionNode:eta - stepTime.
        }
        set ejectionNode:ETA to ejectionNode:eta + stepTime.
    }
    else {
        print "Starting retrograde".
        until isPrograde(ejectionNode) {
            //move the ejection node forward
            set ejectionNode:ETA to ejectionNode:eta + stepTime.
        }
    }

    //use a hill climbing algorithm to step the node forward until apoapsis is maximized
    set bestManeuverTimeFound to false.
    until bestManeuverTimeFound {
        //get current apoapsis of next conic
        set currentOrbit to ejectionNode:Orbit:nextpatch:Apoapsis.

        //step maneuver forward in time, get that conic apoapsis
        set ejectionNode:ETA to ejectionNode:ETA + stepTime.
        set nextOrbit to ejectionNode:Orbit:nextpatch:Apoapsis.

        //if the next orbit is smaller than the last, step back the maneuver and break
        if nextOrbit < currentOrbit {
            set ejectionNode:ETA to ejectionNode:ETA - stepTime.
            break.
        }
 
    }
    logEntry("Ejection time found. ETA: " + ejectionNode:ETA).

    //adjust dv until we are just shy of target orbit
    until ejectionNode:Orbit:nextpatch:Apoapsis >= targetOrbit - orbitBuffer {
        set ejectionNode:Prograde to ejectionNode:Prograde + stepDV.
    }
    //step back one more time
    set ejectionNode:Prograde to ejectionNode:Prograde - (2 * stepDV).
    logEntry("Maneuver finalized. dV: " + ejectionNode:Prograde).

}

function ejectionRetrograde {

}

function isPrograde {
    parameter myNode.

    set solarApo to myNode:Orbit:nextpatch:Apoapsis.
    if solarApo > ship:Body:altitude + Gm{
        return True.
    }
    else {
        return False.
    }
}

function isRetrograde {
    parameter myNode.

    set solarApo to myNode:Orbit:nextpatch:Apoapsis.
    if solarApo <= ship:Body:altitude {
        return True.
    }
    else {
        return False.
    }
}