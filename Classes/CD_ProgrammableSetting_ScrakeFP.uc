class CD_ProgrammableSetting_ScrakeFP extends CD_ProgrammableSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.ScrakeFP;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.ScrakeFP = Ind;
}

protected function float ReadValue()
{
	return float(Outer.ScrakeFPInt);
}

protected function WriteValue( const out float Val )
{
	Outer.ScrakeFPInt = int(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(int(RawValue));
}

defaultproperties
{
	IniDefsArrayName="ScrakeFPDefs"
	OptionName="ScrakeFP"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32
}
