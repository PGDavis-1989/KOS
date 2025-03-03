//imports
runoncepath("0:/lib/liftoff.ks"). 

//launch to 80 km lko
parameter myOrbit is 80. //orbit will be passed in km
parameter myInc is 0.
parameter pitch is 86.

liftoff(myOrbit, myInc, pitch).