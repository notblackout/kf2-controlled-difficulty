class CD_CohortSizeOption extends CD_RegulatedOption
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.CohortSize;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.CohortSize = Ind;
}

protected function int ReadValue()
{
	return Outer.CohortSizeInt;
}

protected function WriteValue( const out int Val )
{
	Outer.CohortSizeInt = Val;
}

defaultproperties
{
	IniDefsArrayName="CohortSizeDefs"
	OptionName="CohortSize"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=10000
}
