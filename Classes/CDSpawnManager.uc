//=============================================================================
// CDSpawnManager
//
// This is the common parent class for CD's various game-length-specific
// SpawnManager subclasses.  Having one subclass per game-length is a
// convention inherited from the base game.
// This lets us override GetMaxMonsters() once for all of the
// game-length-specific subclasses.
//=============================================================================
class CDSpawnManager extends KFAISpawnManager
	within CD_Survival;


var array<CD_AIWaveInfo> CustomWaves;

var int ForcedBossIndex;

function SetCustomWaves( array<CD_AIWaveInfo> inWaves )
{
	CustomWaves = inWaves;
}

// This function is invoked by the spawning system in the base game.
// Its return value is the maximum number of simultaneously live zeds
// allowed on the map at one time.
function int GetMaxMonsters()
{
	local int mm;

	// We must be careful when accessing CD_Survival's MaxMonsters variable,
	// because we inherited a MaxMonsters field from KFAISpawnManager.  We generally
	// want to ignore the KFAISpawnManager variable and consider only Outer.MaxMonsters,
	// which is the user-specified CD_Survival setting.

	mm = Outer.MaxMonsters;

	if (0 < mm)
	{
		`log("GetMaxMonsters(): Returning custom value "$mm, bLogControlledDifficulty);
	}
	else
	{
		mm = super.GetMaxMonsters();
		`log("GetMaxMonsters(): Returning default value "$mm, bLogControlledDifficulty);
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
		`log("Copying squads from custom wave info");
	}
	else
	{
		super.GetAvailableSquads(MyWaveIndex, bNeedsSpecialSquad);
		`log("Using unmodded, randomly-selected squads");
	}
}

/** I overrode this function to change exactly one detail:
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
    appends encroachers to the tail of the leftovers list.  The leftovers list
    is processed from its head to its tail, and it can get quite long
    (double digits) during ordinary play, so this can result in severely
    out-of-order spawns.

    It might be possible to avoid duplication by calling the supermethod first
    and then attempting to conditionally post-process AIToSpawn and
    LeftoverSpawnSquads.  I may try that later.
*/
function int SpawnSquad( array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
	local KFSpawnVolume KFSV;
	local int SpawnerAmount, VolumeAmount, FinalAmount, i;
    local bool bCanSpawnPlayerBoss;

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
		KFSV = GetBestSpawnVolume(AIToSpawn);

		if( KFSV != None )
		{
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
    	// Add any failed spawns back into the LeftoverSpawnSquad to rapidly spawn somewhere else
        for ( i = AIToSpawn.Length - 1 ; 0 <= i ; i-- )
    	{
			LeftoverSpawnSquad.Insert(0, 1);
            LeftoverSpawnSquad[0] = AIToSpawn[i];
    	}

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


//function int GetWaveTotalAI(byte NextWaveIndex)
//{
//	local int tot;
//	local bool scaleup;
//	local CD_AIWaveInfo wi;
//
//	if ( 0 < CustomWaves.length )
//	{
//		wi = CustomWaves[NextWaveIndex];
//		scaleup = wi.CanRecycleWave();
//		tot = wi.GetMaxAI();
//	}
//	else
//	{
//		scaleup = WaveSettings.Waves[NextWaveIndex].bRecycleWave;
//		tot = WaveSettings.Waves[NextWaveIndex].MaxAI;
//	}
//
//	if (scaleup)
//	{
//		tot = tot * 
//					DifficultyInfo.GetPlayerNumMaxAIModifier( GetNumHumanTeamPlayers() ) *
//					DifficultyInfo.GetDifficultyMaxAIModifier();
//	}
//
//	return tot;
//}

/** Returns a random AIGroup from the "waiting" list */
function array< class<KFPawn_Monster> > GetNextSpawnList()
{
	local array< class<KFPawn_Monster> >  NewSquad, RequiredSquad;
	local int RandNum, AINeeded;
    local bool bNeedsNewDesiredSquadType;
    local int EntryIdx;

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

	// select a random squad from the list
	if (0 < CustomWaves.length && MyKFGRI.WaveNum - 1 < CustomWaves.length )
	{
		RandNum = 0;
	}
	else
	{
		RandNum = Rand(AvailableSquads.Length);
	}

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

    // Use the LeftoverSpawnSquad if it exists
    if( LeftoverSpawnSquad.Length > 0 )
    {
        if( bLogAISpawning )
        {
            LogMonsterList(LeftoverSpawnSquad, "Leftover LeftoverSpawnSquad");
        }

        // Insert the leftover squad, in order, before the new squad
        while( LeftoverSpawnSquad.Length > 0 )
        {
            EntryIdx = LeftoverSpawnSquad.Length-1;
            NewSquad.Insert( 0, 1 );
            NewSquad[0] = LeftoverSpawnSquad[EntryIdx];
            LeftoverSpawnSquad.Length = EntryIdx;
        }

        // Set our desired squad type at the end of the function
        bNeedsNewDesiredSquadType = true;
    }

	// Clamp list by NumAINeeded()
	AINeeded = GetNumAINeeded();
	if( AINeeded < NewSquad.Length )
	{
		LeftoverSpawnSquad = NewSquad;
		// Clear out the monsters we're about to spawn from the leftover list
        LeftoverSpawnSquad.Remove(0,AINeeded);

        // Cut off the leftovers from the new monster list
        NewSquad.Length = AINeeded;

        // Set our desired squad type at the end of the function
        bNeedsNewDesiredSquadType = true;
	}
	else
	{
        // If we're spawning all the monsters in the list, there are no leftovers
        LeftoverSpawnSquad.Length = 0;
	}

    if( bLogAISpawning )
    {
    	LogMonsterList(NewSquad, "NewSquad");
    	LogMonsterList(LeftoverSpawnSquad, "LeftoverSpawnSquad");
    }

    if( bNeedsNewDesiredSquadType )
    {
        // Make sure we properly initialize the DesiredSquadType for the leftover squads,
        // otherwise they will just use whatever size data was left in the system
        SetDesiredSquadTypeForZedList( NewSquad );
    }

	return NewSquad;
}



// This function is invoked by the spawning system in the base game.
// It is obnoxiously difficult to modify the spawn chances for albino/regular
// crawlers without introducing a new pawn class.  I would have much rather
// they made this spawn chance table part of DifficultyInfo instead of hardcoding
// it into defaultproperties and then reading it by static method invocation.
//
// The point of this method is to replace the standard crawler pawn class (with
// hardcoded albino chances) with a CD pawn class that never spawns albinos, if
// and only if the user set AlbinoCrawlers=False.
function GetSpawnListFromSquad(byte SquadIdx, out array< KFAISpawnSquad > SquadsList, out array< class<KFPawn_Monster> >  AISpawnList)
{
	local int crawlersForcedRegular;

/////////////////////
/////////////////////

	local KFAISpawnSquad Squad;
	local EAIType AIType;
	local int i, j, RandNum, waveIndex;
	local ESquadType LargestMonsterSquadType;
    local array<class<KFPawn_Monster> > TempSpawnList;
	local array<AISquadElement> SquadElements;
	local CD_AISpawnSquad CustomSquad;
	local bool usingCustom;

	Squad = SquadsList[SquadIdx];

	// Start with the smallest size, and the crank it up if the squad is larger
	LargestMonsterSquadType = EST_Crawler;

	waveIndex = MyKFGRI.WaveNum - 1;
	usingCustom = 0 < CustomWaves.length && waveIndex < CustomWaves.length;

	if ( usingCustom )
	{
		CustomSquad = CD_AISpawnSquad( Squad );
		SquadElements = CustomSquad.CustomMonsterList;
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
					if ( 0 <= ForcedBossIndex && ForcedBossIndex < AIBossClassList.Length )
					{
						TempSpawnList.AddItem(AIBossClassList[ForcedBossIndex]);
						// TODO logging
					}
					else
					{
						TempSpawnList.AddItem(AIBossClassList[Rand(AIBossClassList.Length)]);
						// TODO logging
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
        // Copy temp spawn list to AISpawnList
        while( TempSpawnList.Length > 0 )
		{
			// TODO logging
			if ( usingCustom )
			{
				RandNum = 0;
			}
			else
			{
				RandNum = Rand( TempSpawnList.Length );
			}
			AISpawnList.AddItem( TempSpawnList[RandNum] );
			TempSpawnList.Remove( RandNum, 1 );
		}

		DesiredSquadType = Squad.MinVolumeType;

		if( LargestMonsterSquadType < DesiredSquadType )
        {
            DesiredSquadType = LargestMonsterSquadType;
            //`log("adjusted largest squad for squad "$Squad$" to "$GetEnum(enum'ESquadType',DesiredSquadType));
        }
	}

/////////////////////
/////////////////////

	if ( !AlbinoCrawlers )
	{
		crawlersForcedRegular = 0;

		`log("AlbinoCrawlers="$AlbinoCrawlers$": scanning AISpawnList of length "$AISpawnList.Length$" at squadidx "$SquadIdx);
		// Replace all standard crawler classes with forced-regular crawers
		for ( i = 0; i < AISpawnList.Length; i++ )
		{
			if ( AISpawnList[i] == AIClassList[AT_Crawler] )
			{
				AISpawnList[i] = class'ControlledDifficulty.CDPawn_ZedCrawler';
				`log("Forcing crawler at AISpawnList["$i$"] to spawn as a regular crawler");
				crawlersForcedRegular += 1;
			}
		}

		`log("Total crawlers forced regular in this AISpawnList: "$crawlersForcedRegular);
	}
	else
	{
		`log("AlbinoCrawlers="$AlbinoCrawlers$": allowing albino crawlers to spawn normally");
	}
}

defaultproperties
{
	ForcedBossIndex = -1;
}
