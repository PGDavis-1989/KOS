set logDirectory to "0:/log/".

function clearLogs {
    set missionLog to logDirectory + ship:name + "_Mission.txt".
    set ascentProfile to logDirectory + ship:name + "_ascent_profile.csv".

    DELETEPATH(missionLog).
    DELETEPATH(ascentProfile).
}

function logEntry{
    parameter message.
    log message to logDirectory + ship:name + "_Mission.txt".
}

function logCurrentOrbit{
    logApoapsis().
    logPeriapsis().
    logInclination().
    logOrbitalPeriod().
}

function logApoapsis {
    logEntry("Apoapsis: " + round(ship:apoapsis,1)).
}

function logPeriapsis {
    logEntry("Periapsis: " + round(ship:periapsis,1)).
}

function logInclination {
    logEntry("Inclination: " + round(ship:orbit:inclination,1)).
}

function logOrbitalPeriod{
    set periodInSeconds to round(ship:orbit:period,1).
    set minutes to floor(periodInSeconds / 60).
    set hours to floor(minutes / 60).
    set seconds to floor(periodInSeconds - ((minutes * 60) + (hours * 60 * 60))).
    set periodFormatted to hours + ":" + minutes + ":" + seconds.
    logEntry("Period: " + periodFormatted).
}

function logLiftoff{
    parameter targetOrbit.
    parameter targetInclination.
    parameter gravityTurnPitch.
    parameter calculatedHeading.

    logEntry(targetOrbit).
    logEntry(targetInclination).
    logEntry(gravityTurnPitch).
    logEntry(calculatedHeading).
}

function createAscentFile{
    set ascentProfile to "0:/log/" + ship:name + "_ascent_profile.csv".
    log "MISSION_TIME;ALTITUDE" to ascentProfile.
}

function logAscentProfile{
    log timestamp(missionTime):clock  + ";" + ship:altitude to ascentProfile.
    wait 0.1.
}