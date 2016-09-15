//=============================================================================
// CDSpawnManager_Short
//=============================================================================
class CDSpawnManager_Short extends CDSpawnManager;

DefaultProperties
{
	EarlyWaveIndex=2

	// ---------------------------------------------
	// Wave settings
	// Normal
	DifficultyWaveSettings(0)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Norm.ZED_Wave1_Short_Norm',
								Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Norm.ZED_Wave2_Short_Norm',
								Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Norm.ZED_Wave3_Short_Norm',
								Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Norm.ZED_Wave4_Short_Norm',
								Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Norm.ZED_Boss_Short_Norm')}

	// Hard
	DifficultyWaveSettings(1)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Hard.ZED_Wave1_Short_Hard',
								Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Hard.ZED_Wave2_Short_Hard',
								Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Hard.ZED_Wave3_Short_Hard',
								Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Hard.ZED_Wave4_Short_Hard',
								Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Short.Hard.ZED_Boss_Short_Hard')}

	// Suicidal
	DifficultyWaveSettings(2)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Short.SUI.ZED_Wave1_Short_Sui',
								Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Short.SUI.ZED_Wave2_Short_Sui',
								Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Short.SUI.ZED_Wave3_Short_Sui',
								Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Short.SUI.ZED_Wave4_Short_Sui',
								Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Short.SUI.ZED_Boss_Short_Sui')}

	// Hell On Earth
	DifficultyWaveSettings(3)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Short.HOE.ZED_Wave1_Short_HOE',
								Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Short.HOE.ZED_Wave2_Short_HOE',
								Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Short.HOE.ZED_Wave3_Short_HOE',
								Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Short.HOE.ZED_Wave4_Short_HOE',
								Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Short.HOE.ZED_Boss_Short_HOE')}

	// ---------------------------------------------
	// Solo Spawn Rates
	// Normal
	SoloWaveSpawnRateModifier(0)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5)}    // Wave 4

	// Hard
	SoloWaveSpawnRateModifier(1)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5)}    // Wave 4

	// Suicidal
	SoloWaveSpawnRateModifier(2)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5)}    // Wave 4

	// Hell On Earth
	SoloWaveSpawnRateModifier(3)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0)}    // Wave 4
}

//DefaultProperties
//{
//	EarlyWaveIndex = class'KFAISpawnManager_Short'.default.EarlyWaveIndex;
//
//	DifficultyWaveSettings(0) = class'KFAISpawnManager_Short'.default.DifficultyWaveSettings(0);
//	DifficultyWaveSettings(1) = class'KFAISpawnManager_Short'.default.DifficultyWaveSettings(1);
//	DifficultyWaveSettings(2) = class'KFAISpawnManager_Short'.default.DifficultyWaveSettings(2);
//	DifficultyWaveSettings(3) = class'KFAISpawnManager_Short'.default.DifficultyWaveSettings(3);
//
//	SoloWaveSpawnRateModifier(0) = class'KFAISpawnManager_Short'.default.SoloWaveSpawnRateModifier(0);
//	SoloWaveSpawnRateModifier(1) = class'KFAISpawnManager_Short'.default.SoloWaveSpawnRateModifier(1);
//	SoloWaveSpawnRateModifier(2) = class'KFAISpawnManager_Short'.default.SoloWaveSpawnRateModifier(2);
//	SoloWaveSpawnRateModifier(3) = class'KFAISpawnManager_Short'.default.SoloWaveSpawnRateModifier(3);
//}
