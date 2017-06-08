class CD_DynamicSetting_FleshpoundFP extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FleshpoundFP;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.FleshpoundFP = Ind;
}

protected function float ReadValue()
{
	return float(Outer.FleshpoundFPInt);
}

protected function WriteValue( const out float Val )
{
	Outer.FleshpoundFPInt = Round(Val);
}

protected function string PrettyValue( const float RawValue )
{
	return string(Round(RawValue));
}

defaultproperties
{
	IniDefsArrayName="FleshpoundFPDefs"
	OptionName="FleshpoundFP"
	DefaultSettingValue=0
	MinSettingValue=0
	MaxSettingValue=32

	ChatCommandNames=("!cdfleshpoundfp")
	ChatWriteParamHintFragment="int"
}
