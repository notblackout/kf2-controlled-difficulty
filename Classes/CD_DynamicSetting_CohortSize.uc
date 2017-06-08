class CD_DynamicSetting_CohortSize extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.CohortSize;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.CohortSize = Ind;
}

protected function float ReadValue()
{
	return float(Outer.CohortSizeInt);
}

protected function WriteValue( const out float Val )
{
	Outer.CohortSizeInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="CohortSizeDefs"
	OptionName="CohortSize"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=10000

	ChatCommandNames=("!cdcohortsize","!cdcs")
	ChatWriteParamHintFragment="int, 0 disables cohort mode"
}
