class CD_SpawnModOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.SpawnMod;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.SpawnMod = Ind;
}

protected function float ReadValue()
{
	return Outer.SpawnModFloat;
}

protected function WriteValue( const out float Val )
{
	Outer.SpawnModFloat = Val;
}

defaultproperties
{
	IniDefsArrayName="SpawnModDefs"
	OptionName="SpawnMod"
	DefaultSettingValue=1.f
	MinSettingValue=0.f
	MaxSettingValue=1.f
}
