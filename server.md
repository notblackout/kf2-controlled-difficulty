# Dedicated Server Setup

1. **Setup a standard KF2 Dedicated Server**

   Setting up a dedicated CD Server starts with setting up an unmodified KF2 dedicated server.  Follow Tripwire's documentation on how to setup a KF2 dedicated server:

   https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)

1. **Copy ControlledDifficulty.u**

   Copy ControlledDifficulty.u into `<KF2 Server Root>\KFGame\BrewedPC\Script\`.
   
   The easiest way to get ControlledDifficulty.u is to subscribe to CD's workshop item on your client machine, start KF2 once to force the workshop to download it, then recursively search in `<My Documents>\My Games\KillingFloor2\KFGame\Cache` for ControlledDifficulty.u.
   
1. **Edit KF2Server.bat**

   Add `Game=ControlledDifficulty.CD_Survival` to the `start` command line in `KFServer.bat`.  This file is in the root of your server's installation directory.
   
   For example:
   
   ```
   start .\Binaries\win64\kfserver kf-bioticslab?game=ControlledDifficulty.CD_Survival?Difficulty=3?GameLength=2
   ```
   
1. **(Optional) Edit CD INI Settings**

   To modify CD settings in your server's saved configuration files, edit `<KF2 Server Root>\KFGame\Config\PCServer-KFGame.ini`.  That file's `[ControlledDifficulty.CD_Survival]` section contains all of CD's settings.  This is not required to run CD.
   
   For a full list of settings, consult [options.md](options.md).
   
   ## Known Problems
   
   Changing maps through the web admin interface disables CD.  Changing maps through voting works fine.
