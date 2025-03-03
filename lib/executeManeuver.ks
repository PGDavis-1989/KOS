//import
runoncepath("0:/CLS_lib/CLS_dv.ks").

Function executeNextManeuver {
    parameter alignmentTime is 120.
    sas off.
    set myNode to nextnode.
    set maneuverVector to myNode:burnvector.
    set ves to SHIP.    

    //determine when to burn and for how long
    set burnData to list().
    set burnData to nodeBurnData().
    set burnTime to burnData[0].
    print "Burn Duration: " + round(burnTime,1).
    set burnStartTime to burnData[1]. 

    //wait until close to the maneuver, then lock to it's vector
    print "Waiting for maneuver.".
    wait until myNode:eta <= burnStartTime + alignmentTime.
    lock steering to maneuverVector.
    wait until vang(maneuverVector, ves:facing:vector) < 0.25.
    print "Steering locked to maneuver.".
    print "Waiting for burn.".

    //wait until we get to the node's burn start
    wait until myNode:eta <= burnStartTime + 5.    
    set done to False.
    set throttle_setting to 0.
    lock throttle to throttle_setting.
    print "Burn in 5 seconds".
    wait 5.
    print "Starting burn.".

    until done {
        set max_acc to (ves:availablethrust/ves:mass). // recalculate max_acceleration
		set throttle_setting to min(myNode:deltav:mag/max_acc, 1). // reduces throttle when burn time is under a second.

		// vdot of initial and current vectors is used to measure completeness of burn
		// negative value indicates maneuver overshoot. possible with high TWR.
		if vdot(maneuverVector, myNode:deltav) < 0.0 {
			lock throttle to 0.
			set remove_node to False. // keep node for review
			set program_state to "Burn Complete. Overshoot Detected.".
			break.
		}
		if vdot(maneuverVector, myNode:deltav) < 0.5 AND myNode:deltav:mag < 1.0 {
			lock throttle to 0.
			set remove_node to True.
			set program_state to "Burn Complete.".
			break.
		}
		wait 0. // allow at least 1 physics tick to elapse
    }
    print program_state.
    unlock steering.
    unlock throttle.
}

function calculateBurnDuration {
    parameter mNode.
    set delv to mnode:burnvector:mag.
    set finalMass to ves:mass / (CONSTANT:E^(delV / (vISP() * CONSTANT:g0))).
    set startAcc to ves:availablethrust / ves:mass.
    set finalAcc to ves:availablethrust / finalMass.
    return 2*delV / (startAcc + finalAcc).
}

function vISP {
    list engines in engineList.
    set totalThrust to 0.
    set totalFlow to 0.
    for eng in engineList {
        if eng:ignition {
            set totalThrust to totalThrust + eng:availablethrust.
            set totalFlow to totalFlow + eng:availablethrust/eng:isp.
        }
    }
    if (totalFlow > 0){
        return totalThrust / totalFlow.
    }
    else {
        return -1.
    }
}

function warpToNextManeuver {
    parameter timeOffset.
    set n to nextNode.
    warpTo(time:seconds + n:eta - timeOffset). //warp to next maneuver
}