class CD_ZTSpawnSlowdownOption extends CD_RegulatedOption
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
	DefaultSettingValue=1.f
	MinSettingValue=1.f
	MaxSettingValue=10.f
}
