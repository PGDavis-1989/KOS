//offload ore from mining ship to ISRU containers
//mining ship containers should be labeled "mining"
//ISRU containers should be labeled "ISRU"

set minerStorage to ship:partsdubbed("mining").
set isruStorage to ship:partsdubbed("ISRU").
print minerStorage:length.
set move to TRANSFERALL("ore", minerStorage, isruStorage).
set move:active to true.