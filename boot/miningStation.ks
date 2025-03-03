wait until ship:unpacked.

set terminal:width to 45.
set terminal:height to 26.

core:part:getModule("kOSProcessor"):doEvent("Open Terminal").

clearScreen.
wait 0.5.

//if the ship is on the launch pad, load the necessary files locally.
if ship:status = "prelaunch"{
    set libPath to "0:/miningStation/".
    cd(libPath).
    list files in myFiles.
    
    for aFile in myFiles{
        copyPath(libPath + aFile, "1:/" + aFile).
    }
}