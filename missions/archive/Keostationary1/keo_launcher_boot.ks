wait until ship:unpacked.

set terminal:width to 45.
set terminal:height to 26.

core:part:getModule("kOSProcessor"):doEvent("Open Terminal").

clearScreen.
wait 0.5.

set missionFile to "0:/missions/kto_launcher.ks".
// set localMissionFile to "1:/kto_launcher.ks".

// //if the ship is on the launch pad, load the necessary files locally.
// if ship:status <> "orbiting"{
//     runoncepath("0:/lib/systems.ks").
//     loadLibraryLocally().
//     copyPath(missionFile, localMissionFile).
// }

runpath(missionFile).