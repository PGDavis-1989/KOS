runoncepath("0:/CLS_lib/CLS_dv.ks").

parameter whichSide is "apoapsis".

print "Creating circulization maneuver at " + whichSide + ".".

if whichSide = "apoapsis"{
    set circNode to node(time:seconds + eta:apoapsis, 0, 0, circulariseDV_Apoapsis()).
}
else {
    set circNode to node(time:seconds + eta:periapsis, 0, 0, circulariseDV_Periapsis()).
}

add circNode.