//=============================================================================
// CD_ZedNameUtils
//=============================================================================
// Static helper methods for manipulating zed name strings and their
// equivalent EAIType enum values
//=============================================================================

class CD_ZedNameUtils extends Object
	Abstract;

`include(CD_Log.uci)

/**
    Get a zed EAIType from the name.

    This is based on the LoadMonsterByName from KFCheatManager, but I have a separate copy here
    for several reasons:
    0. I need EAIType instead of a class, and there does not seem to be an easy way to convert those
    1. To allow for a few more abbreviations than KFCheatManager knows (e.g. for clots: CC, CA, CS)
    2. To accept a slightly smaller universe of legal input strings, so that the effective API
       created by this function is as small as possible.
    3. So that a hypothetical future KF2 update that might change KFCheatManager's zed abbreviations
       will not change the behavior of this method, which is used to parse wave squad schedules and
       generally represents a public API that must not change.
    5. I have no need for the "friendly-to-player" zed AI names here, and I want to accept the absolute
       minimum universe of correct inputs, so that this is easy to maintain.  Same for "TestHusk".
*/

enum ECDZedNameResolv
{
	ZNR_OK,
	ZNR_INVALID_NAME,
	ZNR_INVALID_SPECIAL,
	ZNR_INVALID_RAGE
};

static function ECDZedNameResolv GetZedType(
	/* Input parameters */
	const out string ZedName, const bool IsSpecial, const bool IsRagedOnSpawn,
	/* Output parameters */
	out EAIType ZedType, out class<KFPawn_Monster> ZedClass )
{
	local int ZedLen;
	local bool ZedTypeCanBeSpecial, ZedTypeCanBeRaged;

	ZedLen = Len( ZedName );
	ZedClass = None;
	ZedTypeCanBeSpecial = false;
	ZedTypeCanBeRaged = false;
	
	if ( ZedName ~= "CLOTA" || ZedName ~= "CA" || (2 <= ZedLen && ZedLen <= 5 && ZedName ~= Left("ALPHA", ZedLen)) )
	{
		ZedType = AT_AlphaClot;
		ZedClass = IsSpecial ?
			class'CD_Pawn_ZedClot_Alpha_Special' :
			class'CD_Pawn_ZedClot_Alpha_Regular' ;
		ZedTypeCanBeSpecial = true;
	}
	else if ( ZedName ~= "CLOTS" || ZedName ~= "CS" || (2 <= ZedLen && ZedLen <= 7 && ZedName ~= Left("SLASHER", ZedLen)) )
	{
		ZedType = AT_SlasherClot;
	}
	else if ( ZedName ~= "CLOTC" || ZedName ~= "CC" || (2 <= ZedLen && ZedLen <= 4 && ZedName ~= Left("CYST", ZedLen)) )
	{
		ZedType = AT_Clot;
	}
	else if ( ZedName ~= "FP" || (1 <= ZedLen && ZedLen <= 10 && ZedName ~= Left("FLESHPOUND", ZedLen)) )
	{
		ZedType = AT_FleshPound;
		ZedClass = IsRagedOnSpawn ?
			class'CD_Pawn_ZedFleshpound_RS' :
			class'CD_Pawn_ZedFleshpound_NRS' ;
		ZedTypeCanBeRaged = true;
	}
	else if ( ZedName ~= "MF" || ZedName ~= "MFP" || (2 <= ZedLen && ZedLen <= 14 && ZedName ~= Left("MINIFLESHPOUND", ZedLen)) )
	{
		ZedType = AT_FleshpoundMini;
		ZedClass = IsRagedOnSpawn ?
			class'CD_Pawn_ZedFleshpoundMini_RS' :
			class'CD_Pawn_ZedFleshpoundMini_NRS' ;
		ZedTypeCanBeRaged = true;
	}
	else if ( ZedName ~= "KF" || ZedName ~= "KFP" || (2 <= ZedLen && ZedLen <= 14 && ZedName ~= Left("KINGFLESHPOUND", ZedLen)) )
	{
		ZedType = AT_FleshPound;
		ZedClass = class'CD_Pawn_ZedFleshpoundKing_NoMinions';
	}
	else if ( ZedName ~= "G" || ZedName ~= "GF" || (1 <= ZedLen && ZedLen <= 8 && ZedName ~= Left("GOREFAST", ZedLen)) )
	{
		ZedType = AT_GoreFast;
		ZedClass = IsSpecial ?
			class'CD_Pawn_ZedGorefast_Special' :
			class'CD_Pawn_ZedGorefast_Regular' ;
		ZedTypeCanBeSpecial = true;
	}
	else if ( 2 <= ZedLen && ZedLen <= 7 && ZedName ~= Left("STALKER", ZedLen) )
	{
		ZedType = AT_Stalker;
	}
	else if ( 1 <= ZedLen && ZedLen <= 5 && ZedName ~= Left("BLOAT", ZedLen) )
	{
		ZedType = AT_Bloat;
	}
	else if ( 2 <= ZedLen && ZedLen <= 6 && ZedName ~= Left("SCRAKE", ZedLen) )
	{
		ZedType = AT_Scrake;
	}
	else if ( 2 <= ZedLen && ZedLen <= 7 && ZedName ~= Left("CRAWLER", ZedLen) )
	{
		ZedType = AT_Crawler;
		ZedClass = IsSpecial ?
			class'CD_Pawn_ZedCrawler_Special' :
			class'CD_Pawn_ZedCrawler_Regular' ;
		ZedTypeCanBeSpecial = true;
	}
	else if ( 1 <= ZedLen && ZedLen <= 4 && ZedName ~= Left("HUSK", ZedLen) )
	{
		ZedType = AT_Husk;
	}
	else if ( 2 <= ZedLen && ZedLen <= 5 && ZedName ~= Left("SIREN", ZedLen) )
	{
		ZedType = AT_Siren;
	}
	else
	{
		return ZNR_INVALID_NAME;
	}

	// Return OK only if this zed type is allowed to be raged/albino

	if ( IsSpecial && !ZedTypeCanBeSpecial )
	{
		return ZNR_INVALID_SPECIAL;
	}

	if ( IsRagedOnSpawn && !ZedTypeCanBeRaged )
	{
		return ZNR_INVALID_RAGE;
	}

	return ZNR_OK;
}

static function GetZedFullName( const AISquadElement SquadElement, out string ZedName )
{
	ZedName = "";

	if ( SquadElement.Type == AT_AlphaClot )
	{
		ZedName = "Alpha";
	}
	else if ( SquadElement.Type == AT_SlasherClot )
	{
		ZedName = "Slasher";
	}
	else if ( SquadElement.Type == AT_Clot ) 
	{
		ZedName = "Cyst";
	}
	else if ( SquadElement.Type == AT_FleshPound )
	{
		if ( SquadElement.CustomClass == class'CD_Pawn_ZedFleshpoundKing_NoMinions' )
		{
			ZedName = "KingFleshpound";
		}
		else
		{
			ZedName = "Fleshpound";
		}
	}
	else if ( SquadElement.Type == AT_FleshpoundMini )
	{
		ZedName = "MiniFleshpound";
	}
	else if ( SquadElement.Type == AT_Gorefast )
	{
		ZedName = "Gorefast";
	}
	else if ( SquadElement.Type == AT_Stalker )
	{
		ZedName = "Stalker";
	}
	else if ( SquadElement.Type == AT_Bloat )
	{
		ZedName = "Bloat";
	}
	else if ( SquadElement.Type == AT_Scrake )
	{
		ZedName = "Scrake";
	}
	else if ( SquadElement.Type == AT_Crawler )
	{
		ZedName = "Crawler";
	}
	else if ( SquadElement.Type == AT_Husk )
	{
		ZedName = "Husk";
	}
	else if ( SquadElement.Type == AT_Siren )
	{
		ZedName = "Siren";
	}

	AppendModifierChars( SquadElement.CustomClass, ZedName );
}

static function GetZedTinyName( const AISquadElement SquadElement, out string ZedName )
{
	ZedName = "";

	if ( SquadElement.Type == AT_AlphaClot )
	{
		ZedName = "AL";
	}
	else if ( SquadElement.Type == AT_SlasherClot )
	{
		ZedName = "SL";
	}
	else if ( SquadElement.Type == AT_Clot ) 
	{
		ZedName = "CY";
	}
	else if ( SquadElement.Type == AT_FleshPound )
	{
		if ( SquadElement.CustomClass == class'CD_Pawn_ZedFleshpoundKing_NoMinions' )
		{
			ZedName = "KF";
		}
		else
		{
			ZedName = "F";
		}
	}
	else if ( SquadElement.Type == AT_FleshpoundMini )
	{
		ZedName = "MF";
	}
	else if ( SquadElement.Type == AT_Gorefast )
	{
		ZedName = "G";
	}
	else if ( SquadElement.Type == AT_Stalker )
	{
		ZedName = "ST";
	}
	else if ( SquadElement.Type == AT_Bloat )
	{
		ZedName = "B";
	}
	else if ( SquadElement.Type == AT_Scrake )
	{
		ZedName = "SC";
	}
	else if ( SquadElement.Type == AT_Crawler )
	{
		ZedName = "CR";
	}
	else if ( SquadElement.Type == AT_Husk )
	{
		ZedName = "H";
	}
	else if ( SquadElement.Type == AT_Siren )
	{
		ZedName = "SI";
	}

	AppendModifierChars( SquadElement.CustomClass, ZedName );
}

static function GetZedShortName( const AISquadElement SquadElement, out string ZedName )
{
	ZedName = "";

	if ( SquadElement.Type == AT_AlphaClot )
	{
		ZedName = "AL";
	}
	else if ( SquadElement.Type == AT_SlasherClot )
	{
		ZedName = "SL";
	}
	else if ( SquadElement.Type == AT_Clot ) 
	{
		ZedName = "CY";
	}
	else if ( SquadElement.Type == AT_FleshPound )
	{
		if ( SquadElement.CustomClass == class'CD_Pawn_ZedFleshpoundKing_NoMinions' )
		{
			ZedName = "KF";
		}
		else
		{
			ZedName = "FP";
		}
	}
	else if ( SquadElement.Type == AT_FleshpoundMini )
	{
		ZedName = "MF";
	}
	else if ( SquadElement.Type == AT_Gorefast )
	{
		ZedName = "GF";
	}
	else if ( SquadElement.Type == AT_Stalker )
	{
		ZedName = "ST";
	}
	else if ( SquadElement.Type == AT_Bloat )
	{
		ZedName = "BL";
	}
	else if ( SquadElement.Type == AT_Scrake )
	{
		ZedName = "SC";
	}
	else if ( SquadElement.Type == AT_Crawler )
	{
		ZedName = "CR";
	}
	else if ( SquadElement.Type == AT_Husk )
	{
		ZedName = "HU";
	}
	else if ( SquadElement.Type == AT_Siren )
	{
		ZedName = "SI";
	}

	AppendModifierChars( SquadElement.CustomClass, ZedName );
}

static function AppendModifierChars( const class CustomClass, out string ZedName )
{
	local string s;

	if ( CustomClass != None )
	{
	 	s = Locs( string( CustomClass.name ) );

		if ( Left(s, 7) != "cd_pawn")
		{
			return;
		}

		if ( 0 < InStr( s, "_spec" ) )
		{
			ZedName = ZedName $ "*";
		}

		if ( 0 < InStr( s, "_rs" ) )
		{
			ZedName = ZedName $ "!";
		}
	}
}

static function class CheckClassRemap( const class OrigClass, const string InstigatorName, const bool EnableLogging )
{
	local class<KFPawn_Monster> MonsterClass;

	if ( ClassIsChildOf( OrigClass, class'KFPawn_Monster' ) )
	{
		MonsterClass = class<KFPawn_Monster>( OrigClass );
		return CheckMonsterClassRemap( MonsterClass, InstigatorName, EnableLogging );
	}

	`cdlog("Letting non-monster class "$OrigClass$" stand via "$InstigatorName, EnableLogging );
	return OrigClass;
}

static function class<Pawn> CheckPawnClassRemap( const class<Pawn> OrigClass, const string InstigatorName, const bool EnableLogging )
{
	local class<KFPawn_Monster> MonsterClass;

	if ( ClassIsChildOf( OrigClass, class'KFPawn_Monster' ) )
	{
		MonsterClass = class<KFPawn_Monster>( OrigClass );
		return CheckMonsterClassRemap( MonsterClass, InstigatorName, EnableLogging );
	}

	`cdlog("Letting non-monster class "$OrigClass$" stand via "$InstigatorName, EnableLogging );
	return OrigClass;
}

static function class<KFPawn_Monster> CheckMonsterClassRemap( const class<KFPawn_Monster> OrigClass, const string InstigatorName, const bool EnableLogging )
{
	local class<KFPawn_Monster> NewClass;

	NewClass = OrigClass;

	if ( OrigClass == class'CD_Pawn_ZedCrawler_Special' || 
	     OrigClass == class'CD_Pawn_ZedCrawler_Regular' )
	{
		NewClass = class'KFPawn_ZedCrawler';
	}
	else if ( OrigClass == class'CD_Pawn_ZedClot_Alpha_Special' ||
	          OrigClass == class'CD_Pawn_ZedClot_Alpha_Regular' )
	{
		NewClass = class'KFPawn_ZedClot_Alpha';
	}
	else if ( OrigClass == class'CD_Pawn_ZedGorefast_Special' ||
	          OrigClass == class'CD_Pawn_ZedGorefast_Regular' )
	{
		NewClass = class'KFPawn_ZedGorefast';
	}
	else if ( OrigClass == class'CD_Pawn_ZedFleshpound_NRS' ||
	          OrigClass == class'CD_Pawn_ZedFleshpound_RS' )
	{
		NewClass = class'KFPawn_ZedFleshpound';
	}
	else if ( OrigClass == class'CD_Pawn_ZedFleshpoundMini_NRS' ||
	          OrigClass == class'CD_Pawn_ZedFleshpoundMini_RS' )
	{
		NewClass = class'KFPawn_ZedFleshpoundMini';
	}
	else if ( OrigClass == class'CD_Pawn_ZedFleshpoundKing_NoMinions' )
	{
		NewClass = class'KFPawn_ZedFleshpoundKing';
	}
	else if ( OrigClass == class'CD_Pawn_ZedScrake_v1053Hotfix' )
	{
		NewClass = class'KFPawn_ZedScrake';
	}

	// Log what we just did
	if ( OrigClass != NewClass )
	{
		`cdlog("Masked monster class "$OrigClass$" with substitute class "$NewClass$" via "$InstigatorName, EnableLogging );
	}
	else
	{
		`cdlog("Letting monster class "$OrigClass$" stand via "$InstigatorName, EnableLogging );
	}

	return NewClass;
}
