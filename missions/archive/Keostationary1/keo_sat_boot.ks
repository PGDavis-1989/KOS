wait until ship:unpacked.

set missionFile to "0:/missions/keo_sat.ks".
// set localMissionFile to "1:/keo_sat.ks".

// //if the ship is on the launch pad, load the necessary files locally.
// if ship:status <> "orbiting"{
//     runoncepath("0:/lib/systems.ks").
//     loadLibraryLocally().
//     copyPath(missionFile, localMissionFile).
// }

runpath(missionFile).