//=============================================================================
// CDSpawnManager_Normal
//=============================================================================
class CDSpawnManager_Normal extends CDSpawnManager;

DefaultProperties
{
    EarlyWaveIndex=4

    // ---------------------------------------------
    // Wave settings
    // Normal
    DifficultyWaveSettings(0)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave1_Med_Norm',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave2_Med_Norm',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave3_Med_Norm',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave4_Med_Norm',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave5_Med_Norm',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave6_Med_Norm',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Wave7_Med_Norm',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Norm.ZED_Boss_Med_Norm')}

    // Hard
    DifficultyWaveSettings(1)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave1_Med_Hard',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave2_Med_Hard',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave3_Med_Hard',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave4_Med_Hard',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave5_Med_Hard',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave6_Med_Hard',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Wave7_Med_Hard',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Hard.ZED_Boss_Med_Hard')}

    // Suicidal
    DifficultyWaveSettings(2)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave1_Med_SUI',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave2_Med_SUI',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave3_Med_SUI',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave4_Med_SUI',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave5_Med_SUI',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave6_Med_SUI',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Wave7_Med_SUI',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.Suicidal.ZED_Boss_Med_SUI')}

    // Hell On Earth
    DifficultyWaveSettings(3)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave1_Med_HOE',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave2_Med_HOE',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave3_Med_HOE',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave4_Med_HOE',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave5_Med_HOE',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave6_Med_HOE',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Wave7_Med_HOE',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Normal.HOE.ZED_Boss_Med_HOE')}

    // ---------------------------------------------
    // Solo Spawn Rates
    // Normal
    SoloWaveSpawnRateModifier(0)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5,     // Wave 4
                                   RateModifier[4]=1.5,     // Wave 5
                                   RateModifier[5]=1.5,     // Wave 6
                                   RateModifier[6]=1.5)}    // Wave 7

    // Hard
    SoloWaveSpawnRateModifier(1)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5,     // Wave 4
                                   RateModifier[4]=1.5,     // Wave 5
                                   RateModifier[5]=1.5,     // Wave 6
                                   RateModifier[6]=1.5)}    // Wave 7

    // Suicidal
    SoloWaveSpawnRateModifier(2)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5,     // Wave 4
                                   RateModifier[4]=1.5,     // Wave 5
                                   RateModifier[5]=1.5,     // Wave 6
                                   RateModifier[6]=1.5)}    // Wave 7

    // Hell On Earth
    SoloWaveSpawnRateModifier(3)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0,     // Wave 4
                                   RateModifier[4]=1.0,     // Wave 5
                                   RateModifier[5]=1.0,     // Wave 6
                                   RateModifier[6]=1.0)}    // Wave 7
}

//DefaultProperties
//{
//	EarlyWaveIndex = class'KFAISpawnManager_Normal'.default.EarlyWaveIndex;
//
//	DifficultyWaveSettings(0) = class'KFAISpawnManager_Normal'.default.DifficultyWaveSettings(0);
//	DifficultyWaveSettings(1) = class'KFAISpawnManager_Normal'.default.DifficultyWaveSettings(1);
//	DifficultyWaveSettings(2) = class'KFAISpawnManager_Normal'.default.DifficultyWaveSettings(2);
//	DifficultyWaveSettings(3) = class'KFAISpawnManager_Normal'.default.DifficultyWaveSettings(3);
//
//	SoloWaveSpawnRateModifier(0) = class'KFAISpawnManager_Normal'.default.SoloWaveSpawnRateModifier(0);
//	SoloWaveSpawnRateModifier(1) = class'KFAISpawnManager_Normal'.default.SoloWaveSpawnRateModifier(1);
//	SoloWaveSpawnRateModifier(2) = class'KFAISpawnManager_Normal'.default.SoloWaveSpawnRateModifier(2);
//	SoloWaveSpawnRateModifier(3) = class'KFAISpawnManager_Normal'.default.SoloWaveSpawnRateModifier(3);
//}
