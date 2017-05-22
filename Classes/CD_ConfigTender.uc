class CD_ConfigTender
	extends Object
	within CD_Survival;

`include(CD_Log.uci)

var CD_SettingRegulator FakePlayersRegulator;

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
