//=============================================================================
// CD_SpawnManager_Long
//=============================================================================
class CD_SpawnManager_Long extends CD_SpawnManager;

DefaultProperties
{
    EarlyWaveIndex=5

    // ---------------------------------------------
    // Wave settings
    // Normal
    DifficultyWaveSettings(0)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave1_Long_Norm',
                              	Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave2_Long_Norm',
                              	Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave3_Long_Norm',
                              	Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave4_Long_Norm',
                              	Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave5_Long_Norm',
                              	Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave6_Long_Norm',
                              	Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave7_Long_Norm',
                              	Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave8_Long_Norm',
                              	Waves[8]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave9_Long_Norm',
                              	Waves[9]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Wave10_Long_Norm',
                              	Waves[10]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Norm.ZED_Boss_Long_Norm')}

    // Hard
    DifficultyWaveSettings(1)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave1_Long_Hard',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave2_Long_Hard',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave3_Long_Hard',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave4_Long_Hard',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave5_Long_Hard',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave6_Long_Hard',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave7_Long_Hard',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave8_Long_Hard',
                                Waves[8]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave9_Long_Hard',
                                Waves[9]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Wave10_Long_Hard',
                                Waves[10]=KFAIWaveInfo'GP_Spawning_ARCH.Long.Hard.ZED_Boss_Long_Hard')}

    // Suicidal
    DifficultyWaveSettings(2)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave1_Long_Sui',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave2_Long_Sui',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave3_Long_Sui',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave4_Long_Sui',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave5_Long_Sui',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave6_Long_Sui',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave7_Long_Sui',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave8_Long_Sui',
                                Waves[8]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave9_Long_Sui',
                                Waves[9]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Wave10_Long_Sui',
                                Waves[10]=KFAIWaveInfo'GP_Spawning_ARCH.Long.SUI.ZED_Boss_Long_Sui')}

    // Hell On Earth
    DifficultyWaveSettings(3)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave1_Long_HOE',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave2_Long_HOE',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave3_Long_HOE',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave4_Long_HOE',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave5_Long_HOE',
                                Waves[5]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave6_Long_HOE',
                                Waves[6]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave7_Long_HOE',
                                Waves[7]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave8_Long_HOE',
                                Waves[8]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave9_Long_HOE',
                                Waves[9]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Wave10_Long_HOE',
                                Waves[10]=KFAIWaveInfo'GP_Spawning_ARCH.Long.HOE.ZED_Boss_Long_HOE')}

    // Normal
    SoloWaveSpawnRateModifier(0)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5,     // Wave 4
                                   RateModifier[4]=1.5,     // Wave 5
                                   RateModifier[5]=1.5,     // Wave 6
                                   RateModifier[6]=1.5,     // Wave 7
                                   RateModifier[7]=1.5,     // Wave 8
                                   RateModifier[8]=1.5,     // Wave 9
                                   RateModifier[9]=1.5)}    // Wave 10


    // Hard
    SoloWaveSpawnRateModifier(1)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5,     // Wave 4
                                   RateModifier[4]=1.5,     // Wave 5
                                   RateModifier[5]=1.5,     // Wave 6
                                   RateModifier[6]=1.5,     // Wave 7
                                   RateModifier[7]=1.5,     // Wave 8
                                   RateModifier[8]=1.5,     // Wave 9
                                   RateModifier[9]=1.5)}    // Wave 10

    // Suicidal
    SoloWaveSpawnRateModifier(2)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5,     // Wave 2
                                   RateModifier[2]=1.5,     // Wave 3
                                   RateModifier[3]=1.5,     // Wave 4
                                   RateModifier[4]=1.5,     // Wave 5
                                   RateModifier[5]=1.5,     // Wave 6
                                   RateModifier[6]=1.5,     // Wave 7
                                   RateModifier[7]=1.5,     // Wave 8
                                   RateModifier[8]=1.5,     // Wave 9
                                   RateModifier[9]=1.5)}    // Wave 10

    // Hell On Earth
    SoloWaveSpawnRateModifier(3)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0,     // Wave 4
                                   RateModifier[4]=1.0,     // Wave 5
                                   RateModifier[5]=1.0,     // Wave 6
                                   RateModifier[6]=1.0,     // Wave 7
                                   RateModifier[7]=1.0,     // Wave 8
                                   RateModifier[8]=1.0,     // Wave 9
                                   RateModifier[9]=1.0)}    // Wave 10

}

//DefaultProperties
//{
//	EarlyWaveIndex = class'KFAISpawnManager_Long'.default.EarlyWaveIndex;
//
//	DifficultyWaveSettings(0) = class'KFAISpawnManager_Long'.default.DifficultyWaveSettings(0);
//	DifficultyWaveSettings(1) = class'KFAISpawnManager_Long'.default.DifficultyWaveSettings(1);
//	DifficultyWaveSettings(2) = class'KFAISpawnManager_Long'.default.DifficultyWaveSettings(2);
//	DifficultyWaveSettings(3) = class'KFAISpawnManager_Long'.default.DifficultyWaveSettings(3);
//
//	SoloWaveSpawnRateModifier(0) = class'KFAISpawnManager_Long'.default.SoloWaveSpawnRateModifier(0);
//	SoloWaveSpawnRateModifier(1) = class'KFAISpawnManager_Long'.default.SoloWaveSpawnRateModifier(1);
//	SoloWaveSpawnRateModifier(2) = class'KFAISpawnManager_Long'.default.SoloWaveSpawnRateModifier(2);
//	SoloWaveSpawnRateModifier(3) = class'KFAISpawnManager_Long'.default.SoloWaveSpawnRateModifier(3);
//}
