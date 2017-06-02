//=============================================================================
// CD_SpawnManager
//
// This is the common parent class for CD's various game-length-specific
// SpawnManager subclasses.  Having one subclass per game-length is a
// convention inherited from the base game.
// This lets us override GetMaxMonsters() once for all of the
// game-length-specific subclasses.
// The longer functions in this file are copied from KFAISpawnManager,
// because those functions do not provide any easy extension points
// short of overridding the whole thing (i.e. no variables to set or
// ancillary functions to override in order to get the desired behavior).
//=============================================================================
class CD_SpawnManager extends KFAISpawnManager
	within CD_Survival;

`include(CD_Log.uci)

var array<CD_AIWaveInfo> CustomWaves;

var int CohortZedsSpawned;
var int CohortSquadsSpawned;
var int CohortVolumeIndex;

var int SpawnEventsThisWave;

var float WaveSetupTimestamp;
var float FirstSpawnTimestamp;
var float FinalSpawnTimestamp;
var float LatestSpawnTimestamp;
var float WaveEndTimestamp;

function SetCustomWaves( array<CD_AIWaveInfo> inWaves )
{
	CustomWaves = inWaves;
}

/** We override this because of TimeUntilNextSpawn.
	The standard implementation assumes that this
	method is invoked on a 1-second timer.	It always
	decrements TimeUntilNextSpawn by 1.  But CD makes
	this timer a user-configurable setting. */
function Update()
{
	local array<class<KFPawn_Monster> > SpawnList;
	local int SpawnSquadResult;
	local bool CohortSaturated;

	if ( IsFinishedSpawning() || !IsWaveActive() )
	{
		return;
	}

	TotalWavesActiveTime += MinSpawnIntervalFloat;
	TimeUntilNextSpawn -= MinSpawnIntervalFloat;

	CohortZedsSpawned = 0;
	CohortSquadsSpawned = 0;
	CohortVolumeIndex = 0;
	CohortSaturated = false;

	// As soon as SpawnSquadResult reaches zero on an attempt, we assume that 
	// the eligible spawners/spawnvolumes are saturated
	while ( ShouldAddAI() )
	{
		SpawnList = GetNextSpawnList();
		SpawnSquadResult = SpawnSquad( SpawnList );
		NumAISpawnsQueued += SpawnSquadResult;
		CohortZedsSpawned += SpawnSquadResult;
		if ( 0 == SpawnSquadResult || 0 >= Outer.CohortSizeInt )
		{
			CohortSaturated = true;
			break;
		}
		CohortSquadsSpawned += 1;
	}

	// Log cohort composition (if cohorting is enabled)
	if ( 0 < Outer.CohortSizeInt )
	{
		if ( 0 < CohortZedsSpawned )
		{
			`cdlog("Cohort: " $ CohortSquadsSpawned $ " squads | " $ CohortZedsSpawned $ " zeds | saturated=" $ CohortSaturated, bLogControlledDifficulty);
		}
		else
		{
			`cdlog("Cohort empty: could not spawn any squads on this attempt", bLogControlledDifficulty);
		}
	}

	// if we spawned at least one thing, then:
	// 1. invoke CalcNextGroupSpawnTime()
	// 2. update the various bits of state related to spawnrate tracking
	if ( 0 < CohortZedsSpawned )
	{
		TimeUntilNextSpawn = CalcNextGroupSpawnTime();

		SpawnEventsThisWave += 1;

		LatestSpawnTimestamp = Outer.Worldinfo.TimeSeconds;

		if ( 0 > FirstSpawnTimestamp )
		{
			FirstSpawnTimestamp = LatestSpawnTimestamp;
		}

		if ( NumAISpawnsQueued >= WaveTotalAI && 0 > FinalSpawnTimestamp )
		{
			FinalSpawnTimestamp = LatestSpawnTimestamp;
		}
	}


	// This is redundant but it's cheap and it makes me feel better
	CohortZedsSpawned = 0;
	CohortSquadsSpawned = 0;
	CohortVolumeIndex = 0;
	CohortSaturated = false;
}

// We override this solely to add logging
function bool ShouldAddAI()
{
	local int ain;

	`cdlog("TimeUntilNextSpawn=" $ TimeUntilNextSpawn, bLogControlledDifficulty);

	// If it is time to spawn the next squad, or there are any leftovers from the last batch spawn them
	if( (LeftoverSpawnSquad.Length > 0 || TimeUntilNextSpawn <= 0) && !IsFinishedSpawning() )
	{
		ain = GetNumAINeeded();
		`cdlog("GetNumAINeeded()=" $ ain, bLogControlledDifficulty);
		return ain > 0;
	}

	return false;
}



function string GetWaveAverageSpawnrate()
{
	local string SpawnrateString;
	local string ZedCountString, GroupName;
	local string DelayString, SpawnDurationString, LingerString;

	// There are a bunch of edge cases in here

	// (a) if the team wipes before everything spawns,
	// FinalSpawnTimestamp will be -1

	// (b) if the team somehow wipes before anything spawns,
	// FirstSpawnTimestamp will be -1

	// (c) if the cohort size is gigantic, or the wave size
	// is absurdly tiny, then it is theoretically possible for
	// the whole wave to spawn in a single cohort.	In this
	// case, FinalSpawnTimestamp and FirstSpawnTimestamp both
	// have the same positive value.  Avoid div by zero.

	if ( 0 > FinalSpawnTimestamp )
	{
		`cdlog("Overridding FinalSpawnTimestamp " $ FinalSpawnTimestamp $ " -> " $ LatestSpawnTimestamp, bLogControlledDifficulty);
		FinalSpawnTimestamp = LatestSpawnTimestamp;
	}

	if ( 0 > FirstSpawnTimestamp || 0 > FinalSpawnTimestamp || 0 == SpawnEventsThisWave)
	{
		return "0/" $ WaveTotalAI $ " zeds spawned";
	}

	if ( FinalSpawnTimestamp == FirstSpawnTimestamp )
	{
		SpawnrateString = "infinite (single-cohort wave)";
	}
	else
	{
		SpawnrateString = FormatFloatToTwoDecimalPlaces( WaveTotalAI / ( FinalSpawnTimestamp - FirstSpawnTimestamp) ) $ " avg zed/s spawnrate";
	}


	DelayString = FormatFloatToOneDecimalPlace( FirstSpawnTimestamp - WaveSetupTimestamp );
	SpawnDurationString = FormatFloatToOneDecimalPlace( FinalSpawnTimestamp - FirstSpawnTimestamp );
	LingerString = FormatFloatToOneDecimalPlace( WaveEndTimestamp - FinalSpawnTimestamp );

	GroupName = 0 < Outer.CohortSizeInt ? "cohorts" : "squads" ;
	ZedCountString = NumAISpawnsQueued < WaveTotalAI ?
		(NumAISpawnsQueued $"/"$ WaveTotalAI) :
		string(WaveTotalAI);

	return
		ZedCountString $ " zeds, " $ SpawnEventsThisWave $ " " $ GroupName $ "\n" $
		SpawnrateString $ "\n" $
		"  (timed first spawn to last)\n" $
		DelayString $ " s pre, " $ SpawnDurationString $ " s spawning, " $ LingerString $ " s post";
}

private function string FormatFloatToOneDecimalPlace( const float f )
{
	local int l;
	local string s;	

	s = string( f );

	l = Len( s );
	if ( 5 <= l )
	{
		s = Left( s, l - 3 );
	}

	return s;
}

private function string FormatFloatToTwoDecimalPlaces( const float f )
{
	local int l;
	local string s;	

	s = string( f );

	l = Len( s );
	if ( 5 <= l )
	{
		s = Left( s, l - 2 );
	}

	return s;
}

function SetupNextWave(byte NextWaveIndex)
{
	super.SetupNextWave(NextWaveIndex);
	WaveSetupTimestamp = Outer.WorldInfo.TimeSeconds;
	FirstSpawnTimestamp = -1.f;
	FinalSpawnTimestamp = -1.f;
	LatestSpawnTimestamp = -1.f;
	WaveEndTimestamp = -1.f;
	SpawnEventsThisWave = 0;
}

function WaveEnded()
{
	WaveEndTimestamp = Outer.WorldInfo.TimeSeconds;
}

// This function is invoked by the spawning system in the base game.
// Its return value is the maximum number of simultaneously live zeds
// allowed on the map at one time.
function int GetMaxMonsters()
{
	local int mm;

	// We must be careful when accessing CD_Survival's MaxMonsters variable,
	// because we inherited a MaxMonsters field from KFAISpawnManager.	We generally
	// want to ignore the KFAISpawnManager variable and consider only Outer.MaxMonsters,
	// which is the user-specified CD_Survival setting.

	mm = Outer.MaxMonstersInt;

	if (0 < mm)
	{
		`cdlog("GetMaxMonsters(): Returning custom value "$mm, bLogControlledDifficulty);
	}
	else
	{
		mm = super.GetMaxMonsters();
		`cdlog("GetMaxMonsters(): Returning default value "$mm, bLogControlledDifficulty);
	}

	return mm;
}

function GetAvailableSquads(byte MyWaveIndex, optional bool bNeedsSpecialSquad=false)
{
	local CD_AIWaveInfo wi;

	if ( 0 < CustomWaves.length && MyWaveIndex < CustomWaves.length )
	{
		wi = CustomWaves[MyWaveIndex];
		wi.CopySquads( AvailableSquads );
		`cdlog("Copying squads from custom wave info", bLogControlledDifficulty);
	}
	else
	{
		super.GetAvailableSquads(MyWaveIndex, bNeedsSpecialSquad);
		`cdlog("Using unmodded, randomly-selected squads", bLogControlledDifficulty);
	}
}

/*	I overrode this function to ensure that the leftover spawn squad list does
	not get reordered during spawning.	In v<=1048, elements would be taken from
	the head of the LSS for spawning.  If too many elements were taken (limited
	by AINeeded/MaxMonsters), then surplus leftovers would be appended to the
	tail of the LSS.  This is a problem.  Whenever leftovers partially spawned,
	LSS is effectively partially reordered by this process.

	It would be better if surplus leftovers were pushed back onto the head of
	the list, where they were taken from, rather than the tail.
	This can get really noticeable with a CD SpawnCycle, because LSS can get
	into double digit length in normal solo play.

	Despite the fact that this function invokes KFSV.SpawnWave with the
	parameter "bAllOrNothing" set to true, it still sometimes spawns only
	part of the squad, or perhaps spawns the whole squad but then immediately
	destroys some of its constituents, whining into the log thusly:

	[0698.07] ScriptLog: Monster List SpawnSquad Pre Spawning Length = 3
	[0698.07] ScriptLog: MonsterList SpawnSquad Pre Spawning element 0 is KFPawn_ZedClot_Cyst
	[0698.07] ScriptLog: MonsterList SpawnSquad Pre Spawning element 1 is KFPawn_ZedBloat
	[0698.07] ScriptLog: MonsterList SpawnSquad Pre Spawning element 2 is KFPawn_ZedClot_Cyst
	[0698.07] Warning: SpawnActor destroyed [KFPawn_ZedBloat_8] after spawning because it was encroaching on another Actor
	[0698.07] Warning: Warning, Failed to spawn KFPawn_ZedBloat at X=1120.000 Y=800.000 Z=130.000 (Marker Index 1) in volume KFSpawnVolume_8
	[0698.07] Warning: SpawnActor destroyed [KFPawn_ZedClot_Cyst_100] after spawning because it was encroaching on another Actor
	[0698.07] Warning: Warning, Failed to spawn KFPawn_ZedClot_Cyst at X=1120.000 Y=800.000 Z=130.000 (Marker Index 2) in volume KFSpawnVolume_8
	[0698.07] Warning: Warning, Not all AI spawned for volume KFSpawnVolume_8 with 1 markers
	[0698.07] ScriptLog: KFAISpawnManager.SpawnAI() AIs spawned: 1 in Volume: KFSpawnVolume_8
	[0698.07] ScriptLog: Monster List SpawnSquad Post Spawning Length = 2
	[0698.07] ScriptLog: MonsterList SpawnSquad Post Spawning element 0 is KFPawn_ZedClot_Cyst
	[0698.07] ScriptLog: MonsterList SpawnSquad Post Spawning element 1 is KFPawn_ZedBloat

	I don't think I can fix bAllOrNothing=true, because the implementation
	of KFSV.SpawnWave is native.  This wouldn't be a huge problem either
	if KFAISpawnManager would just push the destroyed/encroaching zeds back
	onto the head of the leftovers list.  But it does the opposite.  It
	appends encroachers to the tail of the leftovers list.	The leftovers list
	is processed from its head to its tail, and it can get quite long
	(double digits) during ordinary play, so this can result in severely
	out-of-order spawns.

	It seems possible to avoid copyping most of this method.  I could just
	invoke super.SpawnSquad and do some pre/post checks on LeftoverSpawnSquad's
	size, moving elements from the beginning to the end according to the change
	in size.  That would be way more elegant an involve no copy-pasting, but I
	worried that the underlying assumption -- that all additional elements on the
	end of LSS are failed spawn elements -- could be violated if TWI changes
	SpawnSquad() upstream in a future patch.  For instance, TWI could decide that
	SpawnSquad's LSS append is a good point for additional entropy injection and
	do that by randomly shuffling the list every time elements are added.  That
	would silently break the assumptions necessary for the override strategy, and
	without causing a compiler or runtime error.  The spawnlist would just be
	quietly randomized.  That's pretty much the worst failure mode because it is
	the likeliest to get through testing, so even though
	this is an unlikely scenario, I'm willing to put up with some ugly copy-paste
	to preclude it.
*/
function int SpawnSquad( out array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
	local KFSpawnVolume KFSV;
	local int SpawnerAmount, VolumeAmount, FinalAmount, i;
	local bool bCanSpawnPlayerBoss;
	local int BestVolumeIndex;

`if(`notdefined(ShippingPC))
	local KFGameReplicationInfo KFGRI;
	local vector VolumeLocation;
`endif

	// Since this is called from multiple locations, early out if we're not in a wave
	if( !IsWaveActive() )
	{
		return 0;
	}

	// first check scripted spawners
	if( ActiveSpawner != None && ActiveSpawner.CanSpawnHere(DesiredSquadType) )
	{
		SpawnerAmount = ActiveSpawner.SpawnSquad(AIToSpawn);

		`log("KFAISpawnManager.SpawnAI() Using Spawner AIs spawned:" @ SpawnerAmount @ "in Spawner:" @ ActiveSpawner, bLogAISpawning);
	}
	// otherwise use default spawn volume selection
	if( AIToSpawn.Length > 0 )
	{
		BestVolumeIndex = GetBestSpawnVolumeIndex(AIToSpawn);

		if ( BestVolumeIndex != SpawnVolumes.Length ) // if == length, there were no usable volumes left
		{
			KFSV = SpawnVolumes[BestVolumeIndex];

`if(`notdefined(ShippingPC))
			VolumeLocation=KFSV.Location;
`endif

			KFSV.VolumeChosenCount++;

			if( bLogAISpawning )
			{
				LogMonsterList(AIToSpawn, "SpawnSquad Pre Spawning");
			}

			bCanSpawnPlayerBoss = (bIsVersusGame && MyKFGRI.WaveNum == MyKFGRI.WaveMax) ? CanSpawnPlayerBoss() : false;

			if( !bIsVersusGame || MyKFGRI.WaveNum < MyKFGRI.WaveMax || !bCanSpawnPlayerBoss )
			{
				VolumeAmount = KFSV.SpawnWave(AIToSpawn, true);
				LastAISpawnVolume = KFSV;
			}

			if( bIsVersusGame && !bSkipHumanZedSpawning && MyKFGRI.WaveNum == MyKFGRI.WaveMax )
			{
				AIToSpawn.Length = 0;
			}

			`log("KFAISpawnManager.SpawnAI() AIs spawned:" @ VolumeAmount @ "in Volume:" @ KFSV, bLogAISpawning);

			if( bLogAISpawning )
			{
				LogMonsterList(AIToSpawn, "SpawnSquad Post Spawning");
			}

`if(`notdefined(ShippingPC))
			// Let the GRI know that a spawn volume was just used
			KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
			if( KFGRI != none && KFGRI.bTrackingMapEnabled )
			{
				KFGRI.AddRecentSpawnVolume(KFSV.Location);
			}
`endif
		}

		if( VolumeAmount == 0 )
		{
		  // `warn(self@GetFuncName()$" No spawn volume with a positive rating, no AI will spawn!!!");
		}
	}

	FinalAmount = VolumeAmount + SpawnerAmount;

	RefreshMonsterAliveCount();

	if( AIToSpawn.Length > 0 )
	{
		//`warn(self@GetFuncName()$" Didn't spawn the whole list of AI!!!");
		`log("Partial squad spawn: unable to spawn " $ string(AIToSpawn.Length) $ "/" $ string(FinalAmount));

`if(`notdefined(ShippingPC))
		// Let the GRI know that a spawn volume failed to spawn some AI
		if( !IsZero(VolumeLocation) )
		{
			KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
			if( KFGRI != none && KFGRI.bTrackingMapEnabled )
			{
				KFGRI.AddFailedSpawn(VolumeLocation);
			}
		}
`endif

		if( bLogAISpawning )
		{
			LogMonsterList(AIToSpawn, "SpawnSquad Incomplete Spawn Remaining");
			LogMonsterList(LeftoverSpawnSquad, "Failed Spawn Before Adding To Leftovers");
		}

		//////////////////////////////
		// Start of CD customization
		//////////////////////////////
		// Prepend AIToSpawn onto beginning of LSS.  In the standard game, leftovers
		// go at the end, not the beginning.  This affects the game both with a
		// SpawnCycle and without, but when a SpawnCycle is not in use, the spawn
		// list is generally random anyway.
		for ( i = AIToSpawn.Length - 1 ; 0 <= i ; i-- )
		{
			LeftoverSpawnSquad.Insert(0, 1);
			LeftoverSpawnSquad[0] = AIToSpawn[i];
		}
		//////////////////////////////
		// End of CD customization
		//////////////////////////////

		if( bLogAISpawning )
		{
		   LogMonsterList(LeftoverSpawnSquad, "Failed Spawn After Adding To Leftovers");
		}
	}

	/* __TW_ANALYTICS_ */
	if( bEnableGameAnalytics )
		RecordSpawnInformation( KFSV, FinalAmount );

	return FinalAmount;
}

function int GetBestSpawnVolumeIndex( optional array< class<KFPawn_Monster> > AIToSpawn, optional Controller OverrideController, optional Controller OtherController, optional bool bTeleporting, optional float MinDistSquared )
{
	local int ControllerIndex;
	local Controller RateController;

	if( OverrideController != none )
	{
		RateController = OverrideController;
	}
	else
	{
		// Get the Controller list ready for spawn selection
		InitControllerList();

		if( RecentSpawnSelectedHumanControllerList.Length > 0 )
		{
			// Randomly grab a Human PRI from the list to use for rating zed spawning
			ControllerIndex = Rand(RecentSpawnSelectedHumanControllerList.Length);
			RateController = RecentSpawnSelectedHumanControllerList[ControllerIndex];
			RecentSpawnSelectedHumanControllerList.Remove( ControllerIndex, 1 );
			`Log( GetFuncName()$" Rating with Controller "$RateController.PlayerReplicationInfo.PlayerName$" From RecentSpawnSelectedHumanControllerList", bLogAISpawning );
		}
	}

	// If there were no controllers to rate against, return none
	if( RateController == none )
	{
		`warn( GetFuncName()$" no controllers to rate spawning with!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", bLogAISpawning);
		return SpawnVolumes.Length;
	}

	if( (OtherController == none || !OtherController.bIsPlayer) && NeedPlayerSpawnVolume() )
	{
		// Grab the first player controller
		foreach WorldInfo.AllControllers( class'Controller', OtherController )
		{
			if( OtherController.bIsPlayer )
			{
				break;
			}
		}
	}

	// pre-sort the list to reduce the number of line checks performed by IsValidForSpawn
	SortSpawnVolumes(RateController, bTeleporting, MinDistSquared);

	while ( CohortVolumeIndex < SpawnVolumes.Length )
	{
		if ( SpawnVolumes[CohortVolumeIndex].IsValidForSpawn(DesiredSquadType, OtherController) 
			&& SpawnVolumes[CohortVolumeIndex].CurrentRating > 0 )
		{
			`log(GetFuncName()@"returning chosen spawn volume"@SpawnVolumes[CohortVolumeIndex]@"with a rating of"@SpawnVolumes[CohortVolumeIndex].CurrentRating, bLogAISpawning);
			break;
		}
		CohortVolumeIndex++;
	}

	return CohortVolumeIndex;
}


/* The sole reason for overriding this function is to suppress
   the Rand()-based spawnlist shuffling when using a CD SpawnCycle.
   The if statement in question is marked with banner-style comments.
*/
function array< class<KFPawn_Monster> > GetNextSpawnList()
{
	local array< class<KFPawn_Monster> >  NewSquad, RequiredSquad;
	local int RandNum, AINeeded;

	if( DesiredSquadType == EST_Boss && LeftoverSpawnSquad.Length > 0 )
	{
		LeftoverSpawnSquad.Length = 0;
	}
	
	if( LeftoverSpawnSquad.Length > 0 )
	{
		if( bLogAISpawning )
		{
			LogMonsterList(LeftoverSpawnSquad, "Leftover LeftoverSpawnSquad");
		}
		NewSquad = LeftoverSpawnSquad;

		// Make sure we properly initialize the DesiredSquadType for the leftover squads, otherwise they will just use whatever size data was left in the system
		SetDesiredSquadTypeForZedList( NewSquad );
	}
	else
	{
		// Get a new monster list
		if( !IsAISquadAvailable() )
		{
			if( !bSummoningBossMinions )
			{
				// WaveNum Displays 1 - Length, Squads are ordered 0 - (Length - 1)
				if( bRecycleSpecialSquad && NumSpawnListCycles % 2 == 1 && (MaxSpecialSquadRecycles == -1 || NumSpecialSquadRecycles < MaxSpecialSquadRecycles) )
				{
					//`log("Recycling special squad!!! NumSpawnListCycles: "$NumSpawnListCycles);
					GetAvailableSquads(MyKFGRI.WaveNum - 1, true);
					++NumSpecialSquadRecycles;
				}
				else
				{
					//`log("Not recycling special squad!!! NumSpawnListCycles: "$NumSpawnListCycles);
					GetAvailableSquads(MyKFGRI.WaveNum - 1);
				}
			}
			else
			{
				// Replace the regular squads with boss minions
				AvailableSquads = BossMinionsSpawnSquads;
			}
		}

		//////////////////////////////
		// Start of CD customization
		//////////////////////////////
		if (0 < CustomWaves.length && MyKFGRI.WaveNum - 1 < CustomWaves.length )
		{
			// CD behavior: use available squads in first-to-last order
			RandNum = 0;
		}
		else
		{
			// STANDARD game behavior: select a random squad from the list
			RandNum = Rand(AvailableSquads.Length);
		}
		//////////////////////////////
		// End of CD customization
		//////////////////////////////

		// If we're forcing the required squad, and it already got picked, clear the flag
		if( bForceRequiredSquad && RandNum == (AvailableSquads.Length - 1) )
		{
		   //`log("We spawned the required squad!");
		   bForceRequiredSquad=false;
		}

		if( bLogAISpawning )
		{
			LogAvailableSquads();
		}

		`log("KFAISpawnManager.GetNextAIGroup() Wave:"@MyKFGRI.WaveNum@"Squad:"@AvailableSquads[RandNum]@"Index:"@RandNum, bLogAISpawning);

		// generate list of classes to spawn
		GetSpawnListFromSquad(RandNum, AvailableSquads, NewSquad);

		// Grab the required squad (special squad) which will be the last squad in the array,
		// if we're about to run out of zeds we can spawn, and the special squad hasn't spawned yet
		if( bForceRequiredSquad )
		{
			// generate list of classes to spawn
			GetSpawnListFromSquad((AvailableSquads.Length - 1), AvailableSquads, RequiredSquad);

			if( (NumAISpawnsQueued + NewSquad.Length + RequiredSquad.Length) > WaveTotalAI )
			{
				NewSquad = RequiredSquad;
				RandNum = (AvailableSquads.Length - 1);
				//LogMonsterList(NewSquad, "RequiredSquad");
				//`log("Spawning required squad NumAISpawnsQueued: "$NumAISpawnsQueued$" NewSquad.Length: "$NewSquad.Length$" RequiredSquad.Length: "$RequiredSquad.Length$" WaveTotalAI: "$WaveTotalAI);
				bForceRequiredSquad=false;
			}
		}

		// remove selected squad from the list of available squads
		AvailableSquads.Remove(RandNum, 1);

		if( bLogAISpawning )
		{
			LogAvailableSquads();
		}
	}

	// Clamp list by NumAINeeded()
	AINeeded = GetNumAINeeded();
	if( AINeeded < NewSquad.Length )
	{
		LeftoverSpawnSquad = NewSquad;
		// Clear out the monsters we're about to spawn from the leftover list
		LeftoverSpawnSquad.Remove( 0, AINeeded );

		// Cut off the leftovers from the new monster list
		NewSquad.Length = AINeeded;
	}
	else
	{
		// If we're spawning all the monsters in the list, there are no leftovers
		LeftoverSpawnSquad.Length = 0;
	}

	if( bLogAISpawning )
	{
		LogMonsterList( NewSquad, "NewSquad" );
		LogMonsterList( LeftoverSpawnSquad, "LeftoverSpawnSquad" );
	}

	return NewSquad;
}

function int GetNumAINeeded()
{
	local int n;

	n = super.GetNumAINeeded();

	if ( 0 < Outer.CohortSizeInt )
	{
		n = Min( n, Outer.CohortSizeInt - CohortZedsSpawned );
	}

	return n;
}

/* This function is overridden for a couple reasons:

   - if a boss preference is set and we're spawning a boss,
	 then bypass random boss selection and apply the preference

   - if AlbinoAlphas=false/AlbinoCrawlers=false/AlbinoGorefasts=false,
	 then we replace all of the standard alpha/crawler/gorefast classes
	 with subclasses that forcibly disable special behavior and appearance
*/
function GetSpawnListFromSquad(byte SquadIdx, out array< KFAISpawnSquad > SquadsList, out array< class<KFPawn_Monster> >  AISpawnList)
{
	local KFAISpawnSquad Squad;
	local EAIType AIType;
	local int i, j, RandNum, waveIndex;
	local ESquadType LargestMonsterSquadType;
	local array<class<KFPawn_Monster> > TempSpawnList;
	local array<AISquadElement> SquadElements;
	local CD_AISpawnSquad CustomSquad;
	local bool UsingCustomSquads;
	local array< class< KFPawn_Monster > > MatchClasses;

	Squad = SquadsList[SquadIdx];

	// Start with the smallest size, and the crank it up if the squad is larger
	LargestMonsterSquadType = EST_Crawler;

	waveIndex = MyKFGRI.WaveNum - 1;
	UsingCustomSquads = 0 < CustomWaves.length && waveIndex < CustomWaves.length;

	if ( UsingCustomSquads )
	{
		CustomSquad = CD_AISpawnSquad( Squad );
		CustomSquad.CopyAISquadElements( SquadElements );
	}
	else
	{
		SquadElements = Squad.MonsterList;
	}

	for ( i = 0; i < SquadElements.Length; i++ )
	{
		for ( j = 0; j < SquadElements[i].Num; j++ )
		{
			if( SquadElements[i].CustomClass != None )
			{
				TempSpawnList.AddItem(SquadElements[i].CustomClass);
			}
			else
			{
				AIType = SquadElements[i].Type;
				if( AIType == AT_BossRandom )
				{
					if ( BossEnum == CDBOSS_VOLTER )
					{
						`cdlog("Spawning Hans Volter (config: Boss="$Outer.BossEnum$")", bLogControlledDifficulty);
						TempSpawnList.AddItem(AIBossClassList[0]);
					}
					else if ( BossEnum == CDBOSS_PATRIARCH  )
					{
						`cdlog("Spawning Patriarch (config: Boss="$Outer.BossEnum$")", bLogControlledDifficulty);
						TempSpawnList.AddItem(AIBossClassList[1]);
					}
					else
					{
						`cdlog("Spawning a random boss (config: Boss="$Outer.BossEnum$")", bLogControlledDifficulty);
						TempSpawnList.AddItem(AIBossClassList[Rand(AIBossClassList.Length)]);
					}
				}
				else
				{
					TempSpawnList.AddItem(AIClassList[AIType]);
				}
			}

			if( TempSpawnList[TempSpawnList.Length - 1].default.MinSpawnSquadSizeType < LargestMonsterSquadType )
			{
				LargestMonsterSquadType = TempSpawnList[TempSpawnList.Length - 1].default.MinSpawnSquadSizeType;
			}
		}
	}

	if( TempSpawnList.Length > 0 )
	{
		// Copy temp spawn list to AISpawnList, one element at a time
		while( TempSpawnList.Length > 0 )
		{
			if ( UsingCustomSquads )
			{
				RandNum = 0;
				`cdlog("Prevented spawnlist shuffling", bLogControlledDifficulty);
			}
			else
			{
				RandNum = Rand( TempSpawnList.Length );
				`cdlog("Permitted spawnlist shuffling", bLogControlledDifficulty);
			}

			AISpawnList.AddItem( TempSpawnList[RandNum] );
			TempSpawnList.Remove( RandNum, 1 );
		}

		DesiredSquadType = Squad.MinVolumeType;

		if( LargestMonsterSquadType < DesiredSquadType )
		{
			DesiredSquadType = LargestMonsterSquadType;
		}
	}

	if ( !AlbinoCrawlersBool )
	{
		`cdlog("AlbinoCrawlers="$AlbinoCrawlersBool$": scanning AISpawnList of length "$AISpawnList.Length$" at squadidx "$SquadIdx, bLogControlledDifficulty);

		// Replace all standard crawler classes with forced-regular crawers
		MatchClasses.Length = 2;
		MatchClasses[0] = AIClassList[AT_Crawler];
		MatchClasses[1] = class'ControlledDifficulty.CD_Pawn_ZedCrawler_Special';
		ReplaceZedClass( MatchClasses,
		                 class'ControlledDifficulty.CD_Pawn_ZedCrawler_Regular',
		                 AISpawnList );
	}

	if ( !AlbinoAlphasBool )
	{
		`cdlog("AlbinoAlphas="$AlbinoAlphasBool$": scanning AISpawnList of length "$AISpawnList.Length$" at squadidx "$SquadIdx, bLogControlledDifficulty);

		// Replace all standard alpha classes with forced-regular alphas
		MatchClasses.Length = 2;
		MatchClasses[0] = AIClassList[AT_AlphaClot];
		MatchClasses[1] = class'ControlledDifficulty.CD_Pawn_ZedClot_Alpha_Special';
		ReplaceZedClass( MatchClasses,
		                 class'ControlledDifficulty.CD_Pawn_ZedClot_Alpha_Regular',
		                 AISpawnList );
	}

	if ( !AlbinoGorefastsBool )
	{
		`cdlog("AlbinoGorefasts="$AlbinoGorefastsBool$": scanning AISpawnList of length "$AISpawnList.Length$" at squadidx "$SquadIdx, bLogControlledDifficulty);

		// Replace all standard gorefast classes with forced-regular gorefasts
		MatchClasses.Length = 2;
		MatchClasses[0] = AIClassList[AT_GoreFast];
		MatchClasses[1] = class'ControlledDifficulty.CD_Pawn_ZedGorefast_Special';
		ReplaceZedClass( MatchClasses,
		                 class'ControlledDifficulty.CD_Pawn_ZedGorefast_Regular',
		                 AISpawnList );
	}
}

function ReplaceZedClass( const array< class< KFPawn_Monster > > MatchClasses,
						  const class< KFPawn_Monster > ReplacementClass,
						  out array< class<KFPawn_Monster> >  AISpawnList )
{
	local int conversions;
	local int i;
	local int j;

	conversions = 0;

	// Replace all standard alpha classes with forced-regular crawers
	for ( i = 0; i < AISpawnList.Length; i++ )
	{
		for ( j = 0; j < MatchClasses.Length; j++ )
		{
			if ( AISpawnList[i] == MatchClasses[j] )
			{
				AISpawnList[i] = ReplacementClass;
				`cdlog("Converting "$ string(MatchClasses[j]) $" at AISpawnList["$i$"] to "$ string(ReplacementClass), bLogControlledDifficulty);
				conversions += 1;
			}
		}
	}

	`cdlog("Total zeds in this spawnlist converted to "$ string(ReplacementClass) $": "$ conversions, bLogControlledDifficulty);
}
