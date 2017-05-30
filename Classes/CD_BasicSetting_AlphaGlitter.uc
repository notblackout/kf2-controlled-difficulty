class CD_BasicSetting_AlphaGlitter extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.AlphaGlitter;
}

protected function WriteIndicator( const out string Val )
{
	Outer.AlphaGlitter = Val; 
	Outer.AlphaGlitterBool = bool( Val );
}

protected function string SanitizeIndicator( const string Raw )
{
	return string( bool( Raw ) );
}

defaultproperties
{
	OptionName="AlphaGlitter"
	DefaultSettingIndicator="true"

	ChatCommandNames=("!cdalphaglitter")
	ChatWriteParamHints=("true|false")
}
