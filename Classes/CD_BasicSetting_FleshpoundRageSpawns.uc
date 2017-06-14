class CD_BasicSetting_FleshpoundRageSpawns extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FleshpoundRageSpawns;
}

protected function WriteIndicator( const out string Val )
{
	Outer.FleshpoundRageSpawns = Val; 
	Outer.FleshpoundRageSpawnsBool = bool( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( bool( Raw ) );
}

defaultproperties
{
	OptionName="FleshpoundRageSpawns"
	DefaultSettingIndicator="false"

	ChatCommandNames=("!cdfleshpoundragespawns")
	ChatWriteParamHints=("true|false")
}
