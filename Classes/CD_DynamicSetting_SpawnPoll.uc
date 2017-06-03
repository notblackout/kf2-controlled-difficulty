class CD_DynamicSetting_SpawnPoll extends CD_DynamicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.SpawnPoll;
}

protected function WriteIndicator( const out string Ind )
{
	Outer.SpawnPoll = Ind;
}

protected function float ReadValue()
{
	return Outer.SpawnPollFloat;
}

protected function WriteValue( const out float Val )
{
	Outer.SpawnPollFloat = Val;
}

defaultproperties
{
	IniDefsArrayName="SpawnPollDefs"
	OptionName="SpawnPoll"
	DefaultSettingValue=1.f
	MinSettingValue=0.05f
	MaxSettingValue=60.f

	ChatCommandNames=("!cdspawnpoll","!cdsp")
	ChatWriteParamHintFragment="float, default is 1.0"
}
