class CD_BasicSetting_FakesMode extends CD_BasicSetting
	within CD_Survival;

protected function string ReadIndicator()
{
	return Outer.FakesMode;
}

protected function WriteIndicator( const out string Val )
{
	Outer.FakesMode = Val; 

	if ( Outer.FakesMode == "add_with_humans" )
	{
		FakesModeEnum = FPM_ADD;
	}
	else
	{
		FakesModeEnum = FPM_REPLACE;
	}
}

protected function string SanitizeIndicator( const string Raw )
{
	local string Sanitized;

	if ( !IsValidFakesModeString( Raw, Sanitized ) )
	{
		return DefaultSettingIndicator;
	}

	return Sanitized;
}

private static function bool IsValidFakesModeString( const out string fpm, out string sanitized )
{
	local int InputLen;

	InputLen = Len( fpm );

	if ( 0 == InputLen )
	{
		return false;
	}

	if ( Left( "add_with_humans", InputLen ) ~= fpm )
	{
		sanitized = "add_with_humans";
		return true;
	}

	if ( Left( "ignore_humans", InputLen ) ~= fpm )
	{
		sanitized = "ignore_humans";
		return true;
	}

	return false;
}

defaultproperties
{
	OptionName="FakesMode"
	DefaultSettingIndicator="add_with_humans"

	ChatCommandNames=("!cdfakesmode","!cdfm")
	ChatWriteParamHints=("add_with_humans|ignore_humans")
}
