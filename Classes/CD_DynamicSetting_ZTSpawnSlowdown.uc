class CD_DynamicSetting_ZTSpawnSlowdown extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ZTSpawnSlowdown;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.ZTSpawnSlowdown = Ind;
}

protected function float ReadValue()
{
	return Outer.ZTSpawnSlowdownFloat;
}

protected function WriteValue( const out float Val )
{
	Outer.ZTSpawnSlowdownFloat = Val;
}

defaultproperties
{
	IniDefsArrayName="ZTSpawnSlowdownDefs"
	OptionName="ZTSpawnSlowdown"
	DefaultSettingValue=1.5f
	MinSettingValue=1.f
	MaxSettingValue=10.f

	ChatCommandNames=("!cdztspawnslowdown")
	ChatWriteParamHintFragment="float, default is 1.0"
}
