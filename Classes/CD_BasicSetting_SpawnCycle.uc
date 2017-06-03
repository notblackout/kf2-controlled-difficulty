class CD_BasicSetting_SpawnCycle extends CD_BasicSetting
	within CD_Survival;

`include(CD_Log.uci)

var array<string> WriteMessages;
var array<CD_AIWaveInfo> StagedWaveInfos;

protected function string ReadIndicator()
{
	return Outer.SpawnCycle;
}

protected function WriteIndicator( const out string Val )
{
	Outer.SpawnCycle = Val;
	Outer.SpawnCycleWaveInfos = StagedWaveInfos;
}

protected function string SanitizeIndicator( const string Raw )
{
	WriteMessages.Length = 0;

	LoadSpawnCycle( Raw, StagedWaveInfos );

	if ( 0 == StagedWaveInfos.length && Raw != "unmodded" )
	{
		// The new SpawnCycle was invalid or could not be loaded (gamelength incompatibility?)
		// Revert to the old SC and warn the user
		WriteMessages.AddItem("Setting SpawnCycle=" $ Raw $ " failed!");
		WriteMessages.AddItem("Kept SpawnCycle=" $ SpawnCycle);
		return SpawnCycle;
	}
	else
	{
		// the new SpawnCycle is either "unmodded" or was successfully loaded
		WriteMessages.AddItem("SpawnCycle="$ Raw $" (old: "$ SpawnCycle $")");
		return Raw;
	}
}

defaultproperties
{
	OptionName="SpawnCycle"
	DefaultSettingIndicator="unmodded"

	ChatCommandNames=("!cdspawncycle")
	ChatWriteParamHints=("ini|name_of_spawn_cycle|unmodded")
}
