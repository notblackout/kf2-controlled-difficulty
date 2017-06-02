class CD_DynamicSetting_MinSpawnInterval extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.MinSpawnInterval;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.MinSpawnInterval = Ind;
}

protected function float ReadValue()
{
	return Outer.MinSpawnIntervalFloat;
}

protected function WriteValue( const out float Val )
{
	Outer.MinSpawnIntervalFloat = Val;
}

defaultproperties
{
	IniDefsArrayName="MinSpawnIntervalDefs"
	OptionName="MinSpawnInterval"
	DefaultSettingValue=1.f
	MinSettingValue=0.05f
	MaxSettingValue=60.f

	ChatCommandNames=("!cdminspawninterval","!cdmsi")
	ChatWriteParamHintFragment="float, default is 1.0"
}
