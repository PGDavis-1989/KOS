//refuel mining ship from orbiting station
//mining ship fuel tanks should be labeled "miningFuel"
//refueling tanks should be labeled "refueler"

set minerFuel to ship:partsdubbed("miningFuel").
set refuelingTanks to ship:partsdubbed("refueler").

set moveFuel to TRANSFERALL("liquidfuel", minerFuel, refuelingTanks).
set moveOxider to TRANSFERALL("oxidizer", minerFuel, refuelingTanks).

set moveFuel:active to true.
set moveOxider:active to true.