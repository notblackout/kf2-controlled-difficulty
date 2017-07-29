class CD_SpawnCycle_Preset_albino_heavy 
	extends CD_SpawnCycle_PresetBase 
	implements (CD_SpawnCycle_Preset); 

function GetShortSpawnCycleDefs( out array<string> sink ) 
{ 
	GetLongSpawnCycleDefs( sink ); 

	// keep waves 1, 4, 7, 10 
	sink.Remove(1, 2); 
	sink.Remove(2, 2); 
	sink.remove(3, 2); 

	sink.Length = 4; 
} 

function GetNormalSpawnCycleDefs( out array<string> sink ) 
{ 
	sink.length = 0; 
} 

function GetLongSpawnCycleDefs( out array<string> sink ) 
{ 
	local int i; 

	i = 0; 

	sink.length = 0; 
	sink.length = 10; 

	// Wave 01  0/0 = 0% AlbinoCrawlers, 1/2 = 50% Gorefiends, 2/8 = 25% AlbinoClots
	sink[i++] = "4CC,3CC_1AL_1GF,6SL,4CC_1BL,2AL_1AL*_1SL,4CC,3CC_1AL_1GF*,4CC_1BL,2AL_1AL*_1SL"; 

	// Wave 02  2/12 = 16.67% albinocrawlers, 4/8 = 50% Gorefiends, 4/12 = 33.33% AlbinoClots
	sink[i++] = "3CC_1AL,3CC_1SL_1BL,2CR,2ST,3BL,1HU,1SL_1AL_1AL*_1GF,1AL_1AL*_1GF_1GF*,"$
	"3CC_1AL_1GF*,4CC,3CR_1CR*,3CC_1AL,3CC_1SL_1BL,2CR,2ST,1HU,"$            
	"1SL_1AL_1AL*_1GF*,1AL_1AL*_1GF_1GF*,3CC_1AL_1GF,4CC,3CR_1CR*"; 

	// Wave 03  4/22 = 18.18& albinocrawlers, 10/22 = 45.45% Gorefiends, 3/8 = 37.50% AlbinoClots
	sink[i++] = "3CR_1CR*,2AL_1AL*_1BL,2SL_3CR_1GF,1BL_1SI_1HU,3CC_1GF*_1SI,1SL_2GF_1GF*,1HU,3CC_1AL,"$            
	"1CR_1CR*,2CR_1GF_1GF*_2ST_1SI,4ST,2GF_2GF*,3CR_1CR*,2AL_1AL*_1BL,2SL_3CR_1GF,"$
	"3CC_1GF*_1SI,1SL_2GF_1GF*,1HU,3CC_1AL*,1CR_1CR*,2CR_1GF_1GF*_2ST_1SI,4ST,4GF_2GF*"; 

	// Wave 04  6/29 = 20.69% albinocrawlers, 15/33 = 45.45% Gorefiends, 2/6 = 33.33% AlbinoClots
	sink[i++] = "3CC_1AL,3CC_1CR_1CR*_2ST_1SI,2HU,3CR_1CR*,3CC_1BL,1AL_1AL*_1GF_1GF*,"$ 
	"3CC_1GF_1SI,5GF_4GF*,2ST,2SL_2GF_1GF*,3CC_1CR_2ST_1BL_1SI,4CR_1CR*,2GF_2GF*,"$            
	"2CR_1GF_1GF*_2ST_1SI,3CC_1AL,3CC_1CR_2ST_1BL_1SI,1HU,3CR_1CR*,3CC_1BL,"$      
	"1AL_1AL*_1GF_1GF*,3CC_1GF_1SI,2ST,1HU_1SL_1GF_2GF*,3CC_1CR_1CR*,2ST_1BL_1SI,5CR_1CR*,2GF_2GF*,"$
	"2CR_1GF_1GF*_2ST_1SI"; 
	
	// Wave 05  6/32 = 18.75% ablinocrawlers, 13/29 = 44.83% Gorefiends, 6/15 = 40.00% AlbinoClots
	sink[i++] = "2CR_1CR*,4ST,2CR_1GF_1GF*_2ST_1SI,3CR_1CR*,3CC_1CR_2ST_1BL_1SI,2ST,1SC_6ST,"$ 
	"3CC_1BL,1AL_1AL*_1GF_1HU,2GF_2GF*,4CR_1CR*,1AL_1AL*_1GF_1GF*,1SL_1GF_2GF*,3CC_1GF_1SI,"$ 
	"2AL_1AL*_1SL,2CR,4ST,2CR_2GF_1GF*_2ST_1SI,1AL_1AL*_1GF_2HU,3CR_1CR*,3CC_1CR_2ST_1BL_1SI,2ST,"$     
	"3CC_1BL,2GF_2GF*,4CR_1CR*,1AL_1AL*_1GF_1GF*,1SL_1GF_2GF*,3CC_1GF_1SI,2AL_1AL*_1SL,2GF_1GF*_1HU,2CR_1CR*_2ST,1SL_1AL_2CC_1SC"; 

	// Wave 06  8/40 = 20.00% AlbinoCrawlers, 14/30 = 46.67% Gorefiends, 7/20 = 35.00% AlbinoClots 
	sink[i++] = "1AL_1AL*_1GF_1HU,3CR_1CR*,2AL_1AL*_1SL,2SL_2CR_1GF_1GF*_2SI,1SC_4ST,3CC_1SL_1BL,"$  
	"2CR_1CR*,1AL_1AL*_1SC,2ST,1SL_2AL_1GF,2GF_2GF*,4CR_1CR*,2CR_1GF_1GF*_2ST_1SI,1HU,"$        
	"1SL_2GF_1GF*,2SL_3CR_1GF*,3CC_1CR_1CR*_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF,"$	           
	"1AL_1AL*_1GF*_1HU,3CR_1CR*,2AL_1AL*_1SL,2SL_2CR_1GF_1GF*_2SI,3CC_1SL_1BL,2CR_1CR*,"$	          
	"1AL_1AL*_1SC,2ST,1SL_1AL_1AL*_1GF*,2GF_2GF*,4CR_1CR*,2CR_1GF_1GF*_2ST_1SI,1HU,1SL_2GF_1GF*,"$        
	"2SL_3CR_1GF,3CC_1CR_1CR*_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF*";  

	// Wave 07  7/36 = 19.44% AlbinoCrawlers, 13/29 = 44.83% Gorefiends, 4/12 = 35.00% AlbinoClots
	sink[i++] = "1SL_1AL_1AL*_1GF*,1AL_1AL*_1GF_1GF*,2SL_3CR_1GF,1FP_2SC,3CC_1CR_1CR*_2ST_1BL_1SI,"$ 
	"3CC_1AL_1GF*,4ST,2GF_2GF*,2CR_1CR*_2ST_1BL_2SI,3CC_1AL,2SL_2CR_1GF_1GF*_2SI,"$ 
	"4CR_1CR*,2SL_2GF_1GF*_1SC,3CR_1CR*,3CC_1BL,2HU,4CC,1SL_1AL_1AL*_1GF,1AL_1AL*_1GF_1GF*,"$ 
	"2SL_3CR_1GF,3CC_1CR_1CR*_2ST_1BL_1SI,3CC_1AL_1GF*,4ST,2GF_2GF*,"$ 
	"2CR_2ST_1BL_2SI,3CC_1AL,2SL_2CR_1GF_1GF*_2SI,4CR_1CR*,2SL_2GF_1GF*_1SC,3CR_1CR*,"$ 
	"3CC_1BL,2HU,4CC"; 

	// Wave 08  8/38 = 21.05% AlbinoCrawlers, 14/32 = 43.75% Gorefiends, 4/11 = 36.36% AlbinoClots
	sink[i++] =  "4CC_1BL,2SL_2GF_1GF*_1SC,2CR_1CR*,1AL_1AL*_1GF_1HU,2ST,1SL_2AL_1GF*,"$         
	"2SL_2CR_1GF_1GF*_1SI,1BL,2AL_1AL*_1SL,3CR_1CR*,2AL_1GF_1GF*,1FP_1SC,2SL_3CR_1GF,"$       
	"3CC_1CR_1CR*_2ST_1BL_1SI,1HU,4ST,2AL_1SC,4CC,2GF_2GF*,2CR_1CR*_1GF_1GF*_2ST_1SI,"$        
	"3CR_1CR*,4CC_1BL,2SL_2GF_1GF*_1SC,2CR,1AL_1AL*_1GF_1HU,2ST,1SL_2AL_1GF*,"$  
	"2SL_2CR_1GF_1GF*_2SI,2AL_1AL*_1SL,3CR_1CR*,2AL_1GF_1GF*,2SL_3CR_1GF,"$ 
	"3CC_1CR_1CR*_2ST_1BL_1SI,1HU,4ST,2AL_1SC,4CC,2GF_2GF*,1CR_1GF_1GF*_2ST_1SI,4CR_1CR*"; 

	// Wave 09  8/40 = 20.00% AlbinoCrawlers , 14/30 = 46.67% Gorefiends, 6/18 = 33.33% AlbinoClots
	sink[i++] = "4ST,2HU,4CC_1BL,2CR_1CR*,2AL_1AL*_1SL,2AL_1SC,3CR_1CR*,2SL_2CR_1GF_1GF*_2SI,2GF_2GF*,"$ 
	"2ST,1SL_1AL_1AL*_1GF*,2FP_1SC,3CR_1CR*,1AL_1AL*_1GF_1GF*,2SL_2GF_1GF*_1SC,2SL_3CR_1GF,"$ 
	"3CC_1CR_1CR*_2ST_1BL_1SI,4CC,2CR_1GF_1GF*_2ST_1SI,4ST,1HU,4CC_1BL,2CR,"$ 
	"2AL_1AL*_1SL,2AL_1SC,4CR_2CR*,2SL_2CR_1GF_1GF*_2SI,2GF_2GF*,2ST,1SL_1AL_1AL*_1GF,3CR_1CR*,"$ 
	"1AL_1AL*_1GF_1GF*,2SL_3CR_1GF*,3CC_1CR_1CR*_2ST_1BL_1SI,2SL_2GF_1GF*_1SC,4CC,"$ 
	"2CR_1CR*_1GF_1GF*_2ST_1SI";

	// Wave 10  7/35 = 20.00% AlbinoCrawlers, 16/35 = 45.71% Gorefiends, 7/20 = 35.00% AlbinoClots
	sink[i++] = "1SL_1AL_1AL*_1GF,3CR_1CR*,1HU,2SI_1CS_1GF_1GF*,1AL_1AL*_1SC,3CC_1BL,2AL_1GF_1GF*_1BL,2SL_3CR_1GF*,"$
	"2SL_2CR_1CR*_1GF_1GF*_1SI,2AL_1AL*_1SL,2FP_2SC,4ST,4CC,2CR_2ST_1BL_2SI,"$ 
	"2CR_1CR*,1GF_1GF*_1SL,3CC_1AL_1GF,2SL_2GF_1GF*_1SC,3CC_2CR_2ST_1BL_1SI,2GF_2GF*,"$       
	"1SL_1AL_1AL*_1GF,3CR_1CR*,1HU,3CC_1BL,3CC_1GF_1GF*,1AL_1AL*_1SC,1AL_1AL*_1GF_1GF*,2SL_1CR_1CR*_1GF*,"$          
	"2SL_2CR_1GF_1GF*_1SI,2AL_1AL*_1SL,1HU,1GF_3CR_1CR*,4ST,4CC,"$ 
	"2CR_2ST_1BL_2SI,3CC_1AL_1GF*,2SL_2GF_1GF*,1SC_1HU,2CR,3CC_1CR_1CR*_2ST_1BL_1SI,2GF_2GF*"; 
} 

function string GetDate() 
{ 
	return "2017-07-03"; 
} 

function string GetAuthor() 
{ 
	return "blackout + dandyboy + Kore"; 
} 
