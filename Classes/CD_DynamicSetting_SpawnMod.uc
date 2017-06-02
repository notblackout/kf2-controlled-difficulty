class CD_DynamicSetting_SpawnMod extends CD_DynamicSetting
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

	ChatCommandNames=("!cdspawnmod","!cdsm")
	ChatWriteParamHintFragment="float, default is 1.0"
}
