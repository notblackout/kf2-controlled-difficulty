class CD_ConfigTender extends Object
	within CD_Survival;

`include(CD_Log.uci)

var CD_SettingRegulator CohortSizeRegulator;
var CD_SettingRegulator FakePlayersRegulator;
var CD_SettingRegulator MaxMonstersRegulator;

var private CD_ConsolePrinter CDCP;

function SetConsolePrinter( const CD_ConsolePrinter NewCDCP )
{
	CDCP = NewCDCP;
}

function Activate( const int OverrideWaveNum )
{
	TendCohortSize( OverrideWaveNum );
	TendFakePlayers( OverrideWaveNum );
	TendMaxMonsters( OverrideWaveNum );
	TendMinSpawnInterval( OverrideWaveNum );
	TendSpawnMod( OverrideWaveNum );
	TendZTSpawnSlowdown( OverrideWaveNum );
}

private function TendCohortSize( const int OverrideWaveNum )
{
	local int OldCohortSize;

	`cdlog("Tending CohortSize", bLogControlledDifficulty);

	if ( None != CohortSizeRegulator )
	{
		OldCohortSize = Outer.CohortSizeInt;
		Outer.CohortSizeInt = CohortSizeRegulator.GetValue( OverrideWaveNum, WaveMax, NumPlayers, MaxPlayers );
		if ( OldCohortSize != Outer.CohortSizeInt )
		{
			`cdlog("CD_ConfigTender: CohortSize="$ Outer.CohortSizeInt $" (was: "$ OldCohortSize $ ")");
		}
		else
		{
			`cdlog("CD_ConfigTender: CohortSize="$ Outer.CohortSizeInt $" (no change)");
		}
	}
}

private function TendFakePlayers( const int OverrideWaveNum )
{
	local int OldFakePlayers;

	`cdlog("Tending FakePlayers", bLogControlledDifficulty);

	if ( None != FakePlayersRegulator )
	{
		OldFakePlayers = Outer.FakePlayersInt;
		Outer.FakePlayersInt = FakePlayersRegulator.GetValue( OverrideWaveNum, WaveMax, NumPlayers, MaxPlayers );
		if ( OldFakePlayers != Outer.FakePlayersInt )
		{
			`cdlog("CD_ConfigTender: FakePlayers="$ Outer.FakePlayersInt $" (was: "$ OldFakePlayers $ ")");
		}
		else
		{
			`cdlog("CD_ConfigTender: FakePlayers="$ Outer.FakePlayersInt $" (no change)");
		}
	}
}

private function TendMaxMonsters( const int OverrideWaveNum )
{
	local int OldMaxMonsters;

	`cdlog("Tending MaxMonsters", bLogControlledDifficulty);

	if ( None != MaxMonstersRegulator )
	{
		OldMaxMonsters = Outer.MaxMonstersInt;
		Outer.MaxMonstersInt = MaxMonstersRegulator.GetValue( OverrideWaveNum, WaveMax, NumPlayers, MaxPlayers );
		if ( OldMaxMonsters != Outer.MaxMonstersInt )
		{
			`cdlog("CD_ConfigTender: MaxMonsters="$ Outer.MaxMonstersInt $" (was: "$ OldMaxMonsters $ ")");
		}
		else
		{
			`cdlog("CD_ConfigTender: MaxMonsters="$ Outer.MaxMonstersInt $" (no change)");
		}
	}
}

private function TendMinSpawnInterval( const int OverrideWaveNum )
{
}

private function TendSpawnMod( const int OverrideWaveNum )
{
}

private function TendZTSpawnSlowdown( const int OverrideWaveNum )
{
}
