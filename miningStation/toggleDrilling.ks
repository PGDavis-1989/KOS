if drills {//if drills are currently active
    drills off.
    deploydrills off.
    radiators off.
    print "Drills retracted.".
}
else {
    deploydrills on.
    radiators on.
    wait 2.
    drills on.
    print "Drills deployed.".
}