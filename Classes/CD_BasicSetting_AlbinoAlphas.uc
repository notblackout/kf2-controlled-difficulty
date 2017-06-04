class CD_BasicSetting_AlbinoAlphas extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.AlbinoAlphas;
}

protected function WriteIndicator( const out string Val )
{
	Outer.AlbinoAlphas = Val; 
	Outer.AlbinoAlphasBool = bool( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( bool( Raw ) );
}

defaultproperties
{
	OptionName="AlbinoAlphas"
	DefaultSettingIndicator="true"

	ChatCommandNames=("!cdalbinoalphas")
	ChatWriteParamHints=("true|false")
}
