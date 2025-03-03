//declare variables
global partsOnShip is ship:parts.
global fairing is list().
global antennas is list().
global commandModules is list().

//add parts to lists
for part in partsOnShip {
  if part:TAG = "fairing" {fairing:add(part).}
  if part:TAG = "antenna" {antennas:add(part).}
  if part:TAG = "command" {commandModules:add(part).}
}

global function extendAntennas{
    for part in antennas {
        part:getModule("ModuleDeployableAntenna"):doevent("extend antenna").
    }
    print "Antennas extended." at (0,12).
    logEntry("Antennas extended.").
}

global function deployFairing{
    for part in fairing {
        part:getModule("ModuleProceduralFairing"):doevent("deploy").
    }
    print "Fairing deployed." at (0,10).
    logEntry("Fairings deployed.").
}

global function extendSolarPanels {
    panels on.
    print "Solar Panels deployed." at (0,13).
    logEntry("Solar Panels deployed.").
}

global function openServiceBays {
    bays on.
    print "Service bays open." at (0,11).
    logEntry("Service bays open.").
}

global function deploySystems {
  parameter nameOfAntenna is "antenna".
  parameter condition is ship:body:atm:height + 500.
  print "Autodeployment system ready.".
  print "Waiting altitude of: " + condition.
  print " ".
  logEntry("Autodeployment system actived. Waiting altitude of: " + condition).
  wait 0.5.
  when ship:altitude > condition then {
    wait 0.
    deployFairing().
    wait 5.
    openServiceBays().
    wait 2.
    extendAntennas().
    extendSolarPanels().
    wait 0.1.
    logEntry("Systems deployed.").
  }
}

//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// CHANGE ENGINE'S THRUST LIMIT
//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

global function limitThrust {
  parameter perc.
  for eng in ship:engines {
    if eng:stage = stage:number {set eng:thrustLimit to perc.}
  }
  print ("Thrust power at ") + perc + (" %.            ") at (0,25).
}

//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// SWITCH TO ANOTHER VESSEL
//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

global function switchToVessel{
    parameter shipName.
    set kuniverse:activevessel to vessel(shipName).
}

//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// LOAD FILES FROM ARCHIVE TO LOCAL PROCESSOR
//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

global function loadLibraryLocally{
    set libPath to "0:/lib/".
    cd(libPath).
    list files in myFiles.
    
    for aFile in myFiles{
        copyPath(libPath + aFile, "1:/lib/" + aFile).
    }
}

//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// Allows for automatic staging of engines
//_________________________________________________
//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
global function triggerStaging{
  global oldThrust is ship:availableThrust.
  global canStage is true.
  print ("Autostage system operational.").
  print " ".
  when ship:availableThrust < oldThrust - 10 AND canStage = true then {
    until false {
      wait until stage:ready.
      stage.
      logEntry("Staged.").
      hudText("STAGE", 1, 2, 30, rgb(1,0.498,0.208), false).
      wait 0.1.
      if ship:maxThrust > 0 or stage:number = 0 { 
        break.
      }
    }
    set oldThrust to ship:availableThrust.
    if stage:number > 1 {preserve.}
  }
}