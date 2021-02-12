/*

Reverse Friendly-Fire (l4d_reverse_ff) by Mystik Spiral

This Left4Dead2 SourceMod plugin reverses friendly-fire... the attacker takes all of the damage and the victim takes none.
This forces players to be more precise with their shots... or they will spend a lot of time on the ground.

Although this plugin discourages griefers/team killers since they can only damage themselves and no one else, the first objective is to force players to improve their shooting tatics and aim. The second objective is to encourage new/inexperienced players to only join games with a difficulty that match their skillset, rather than trying to play at a difficulty above their ability and constantly incapping their teammates.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse explosion damage. This plugin does not reverse molotov/gascan damage and I do not intend to add it, though I may make a separate plugin to handle molotov/gascan damage.  Now reverses "friendly-fire for infected team too.

    Option to specify extra damage if attacker is using explosive/incendiary ammo. [reverseff_multiplier (default: 1.125 {12.5%})]
    Option to reverse friendly-fire when attacker is admin. [reverseff_admin (default: false)]
    Option to reverse friendly-fire when victim is a bot. [reverseff_bot (default: false)]
    Option to reverse friendly-fire when victim is incapacitated. [reverseff_incapped (default: false)]
    Option to treat friendly-fire as self damage (or reversed accusations). [reverseff_self (default: false)]
    Option to specify maximum survivor damage allowed per chapter before ban. [reverseff_survivormaxdmg (default: 180)]
    Option to specify maximum infected damage allowed per chapter before ban. [reverseff_infectedmaxdmg (default: 110)]
    Option to specify ban duration in minutes (0=permanent, -1=kick). [reverseff_banduration (default: 10)]
    Option to enable/disable plugin by game mode. [reverseff_modes_on, reverseff_modes_off, reverseff_modes_tog (default: enabled for all game modes)]

Want to contribute code enhancements?
Create a pull request using this GitHub repository: https://github.com/Mystik-Spiral/l4d_reverse_ff

*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.9"
#define CVAR_FLAGS FCVAR_NOTIFY

ConVar cvar_reverseff_admin;
ConVar cvar_reverseff_multiplier;
ConVar cvar_reverseff_bot;
ConVar cvar_reverseff_survivormaxdmg;
ConVar cvar_reverseff_infectedmaxdmg;
ConVar cvar_reverseff_banduration;
ConVar cvar_reverseff_incapped;
ConVar cvar_reverseff_self;
ConVar g_hCvarAllow, g_hCvarMPGameMode, g_hCvarModesOn, g_hCvarModesOff, g_hCvarModesTog;

bool g_bCvarReverseIfAdmin;
float g_fCvarDamageMultiplier;
bool g_bCvarReverseIfBot;
float g_fAccumDamage[MAXPLAYERS + 1];
float g_fSurvivorMaxDamage;
float g_fInfectedMaxDamage;
int g_iBanDuration;
bool g_bCvarReverseIfIncapped;
bool g_bCvarSelfDamage;
bool g_bGrace[MAXPLAYERS + 1];
bool g_bToggle[MAXPLAYERS + 1];
bool g_bCvarAllow, g_bMapStarted;

public Plugin myinfo =
{
	name = "[L4D & L4D2] Reverse Friendly-Fire",
	author = "Mystic Spiral",
	description = "Team attacker takes friendly-fire damage, victim takes no damage.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2727641#post2727641"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if ( test == Engine_Left4Dead2 || test == Engine_Left4Dead )
	{
		return APLRes_Success;
	}
	strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
	return APLRes_SilentFailure;
}

public void OnPluginStart()
{
	CreateConVar("reverseff_version", PLUGIN_VERSION, "Reverse Friendly-Fire", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvar_reverseff_admin = CreateConVar("reverseff_admin", "0", "0=Do not ReverseFF if attacker is admin, 1=ReverseFF if attacker is admin", CVAR_FLAGS);
	cvar_reverseff_bot = CreateConVar("reverseff_bot", "0", "0=Do not ReverseFF if victim is bot, 1=ReverseFF if victim is bot", CVAR_FLAGS);
	cvar_reverseff_incapped = CreateConVar("reverseff_incapped", "0", "0=Do not ReverseFF if victim is incapped, 1=ReverseFF if victim is incapped", CVAR_FLAGS);
	cvar_reverseff_self = CreateConVar("reverseff_self", "0", "0=Treat ReverseFF as reversed accusations, 1=Treat ReverseFF as self damage", CVAR_FLAGS);
	cvar_reverseff_multiplier = CreateConVar("reverseff_multiplier", "1.125", "Special ammo damage multiplier (default=12.5%)", CVAR_FLAGS);
	cvar_reverseff_survivormaxdmg = CreateConVar("reverseff_survivormaxdmg", "180", "Maximum damage allowed before kick/ban survivor", CVAR_FLAGS);
	cvar_reverseff_infectedmaxdmg = CreateConVar("reverseff_infectedmaxdmg", "110", "Maximum damage allowed before kick/ban infected", CVAR_FLAGS);
	cvar_reverseff_banduration = CreateConVar("reverseff_banduration", "10", "Ban duration in minutes (0=permanent, -1=kick)", CVAR_FLAGS);
	g_hCvarAllow = CreateConVar("reverseff_enabled", "1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	g_hCvarModesOn = CreateConVar("reverseff_modes_on", "", "Game mode names on, comma separated, no spaces. (Empty=all).", CVAR_FLAGS );
	g_hCvarModesOff = CreateConVar("reverseff_modes_off", "", "Game mode names off, comma separated, no spaces. (Empty=none).", CVAR_FLAGS );
	g_hCvarModesTog = CreateConVar("reverseff_modes_tog", "0", "Game type bitflags on, add #s together. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge", CVAR_FLAGS );
	AutoExecConfig(true, "l4d_reverse_ff");
	
	cvar_reverseff_admin.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_multiplier.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_bot.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_survivormaxdmg.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_infectedmaxdmg.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_banduration.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_incapped.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_self.AddChangeHook(action_ConVarChanged);
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOn.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	
	HookEvent("choke_stopped", Event_StartGrace);
	HookEvent("pounce_stopped", Event_StartGrace);
	HookEvent("jockey_ride_end", Event_StartGrace);
	HookEvent("charger_pummel_end", Event_StartGrace);
	
	LoadTranslations("l4d_reverse_ff_phrases.txt");
}

public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

public int action_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarReverseIfAdmin = cvar_reverseff_admin.BoolValue;
	g_fCvarDamageMultiplier = cvar_reverseff_multiplier.FloatValue;
	g_bCvarReverseIfBot = cvar_reverseff_bot.BoolValue;
	g_fSurvivorMaxDamage = cvar_reverseff_survivormaxdmg.FloatValue;
	g_fInfectedMaxDamage = cvar_reverseff_infectedmaxdmg.FloatValue;
	g_iBanDuration = cvar_reverseff_banduration.IntValue;
	g_bCvarReverseIfIncapped = cvar_reverseff_incapped.BoolValue;
	g_bCvarSelfDamage = cvar_reverseff_self.BoolValue;
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 && iCvarModesTog != 15 )
	{
		if( g_bMapStarted == false )
			return false;

		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModesOn.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

public void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bGrace[client] = false;
	g_fAccumDamage[client] = 0.0;
}

public void OnClientPostAdminCheck(int client)
{
	CreateTimer(16.0, RFFNotice, client);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bGrace[client] = false;
	g_fAccumDamage[client] = 0.0;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	//debug plugin enabled flag
	//PrintToServer("g_bCvarAllow: %b", g_bCvarAllow);
	if (!g_bCvarAllow)
	{
		return Plugin_Continue;
	}
	//debug damage
	//PrintToServer("Vic: %i, Atk: %i, Inf: %i, Dam: %f, DamTyp: %i, Wpn: %i", victim, attacker, inflictor, damage, damagetype, weapon);
	//attacker and victim survivor checks
	if (IsValidClientAndInGameAndSurvivor(attacker) && IsValidClientAndInGameAndSurvivor(victim) && victim != attacker)
	{
		char sInflictorClass[64];
		if (inflictor > MaxClients)
		{
			GetEdictClassname(inflictor, sInflictorClass, sizeof(sInflictorClass));
		}
		//is weapon grenade launcher
		bool bWeaponGL = IsWeaponGrenadeLauncher(sInflictorClass);
		//is weapon minigun
		bool bWeaponMG = IsWeaponMinigun(sInflictorClass);
		//debug weapon
		//PrintToServer("GL: %b, MG: %b, InfCls: %s, weapon: %i", bWeaponGL, bWeaponMG, sInflictorClass, weapon);
		//if weapon caused damage
		if (weapon > 0 || bWeaponGL || bWeaponMG)
		{
			//do not reverse friendly-fire for these situations (attacker is admin, victim is bot, victim is incapped, victim in grace period)
			if (!((IsClientAdmin(attacker) && !g_bCvarReverseIfAdmin) || (IsFakeClient(victim) && !g_bCvarReverseIfBot) || (IsClientIncapped(victim) && !g_bCvarReverseIfIncapped)) && (!g_bGrace[victim]))
			{
				//special ammo checks
				if (IsSpecialAmmo(weapon, attacker, inflictor, damagetype, bWeaponGL))
				{
					//damage * "reverseff_multiplier"
					damage *= g_fCvarDamageMultiplier;
				}
				//accumulate damage total for attacker
				g_fAccumDamage[attacker] += damage;
				//debug acculated damage
				//PrintToServer("Survivor Atk: %N, Dmg: %f, AcmDmg: %f, SurvMaxDmg: %f", attacker, damage, g_fAccumDamage[attacker], g_fSurvivorMaxDamage);
				//does accumulated damage exceed "reverseff_survivormaxdamage"
				if (g_fAccumDamage[attacker] > g_fSurvivorMaxDamage)
				{
					if (g_iBanDuration == -1)
					{
						//kick attacker
						KickClient(attacker, "%t", "ExcessiveFF");
					}
					else
					{
						//ban attacker for "reverseff_banduration"
						char BanMsg[50];
						Format(BanMsg, sizeof(BanMsg), "%t", "ExcessiveFF", attacker);
						BanClient(attacker, g_iBanDuration, BANFLAG_AUTO, "ExcessiveFF", BanMsg, _, attacker);
					}
					//reset accumulated damage
					g_fAccumDamage[attacker] = 0.0;
					//do not inflict damage since player was kicked/banned
					return Plugin_Handled;
				}
				//check whether to treat FF as self-damage
				int vicatk = victim;
				if (g_bCvarSelfDamage)
				{
					vicatk = attacker;
				}
				//inflict damage to attacker
				SDKHooks_TakeDamage(attacker, inflictor, vicatk, damage, damagetype, weapon, damageForce, damagePosition);
				if (damage > 0 && !IsFakeClient(attacker))
				{
					if (!g_bToggle[attacker])
					{
						PrintToServer("%N %t %N", attacker, "Attacked", victim);
						PrintToChat(attacker, "[RFF] %t %N, %t.", "YouAttacked", victim, "SurvivorFF");
						g_bToggle[attacker] = true;
						CreateTimer(0.15, FlipToggle, attacker);
					}
				}
			}
			//no damage for victim
			return Plugin_Handled;
		}
	}
	else
	{
		//attacker and victim infected checks
		if (IsValidClientAndInGameAndInfected(attacker) && IsValidClientAndInGameAndInfected(victim) && victim != attacker)
		{
			//do not reverse friendly-fire for these two situations
			if (!((IsClientAdmin(attacker) && !g_bCvarReverseIfAdmin) || (IsFakeClient(victim) && !g_bCvarReverseIfBot)))
			{
				//accumulate damage total for infected attacker
				g_fAccumDamage[attacker] += damage;
				//debug acculated damage
				//PrintToServer("Infected Atk: %N, Dmg: %f, AcmDmg: %f, InfdMaxDmg: %f", attacker, damage, g_fAccumDamage[attacker], g_fInfectedMaxDamage);
				//does accumulated damage exceed "reverseff_infectedmaxdamage"
				if (g_fAccumDamage[attacker] > g_fInfectedMaxDamage)
				{
					if (g_iBanDuration == -1)
					{
						//kick attacker
						KickClient(attacker, "%t", "ExcessiveTA");
					}
					else
					{
						//ban attacker for "reverseff_banduration"
						char BanMsg[50];
						Format(BanMsg, sizeof(BanMsg), "%t", "ExcessiveTA", attacker);
						BanClient(attacker, g_iBanDuration, BANFLAG_AUTO, "ExcessiveTA", BanMsg, _, attacker);
					}
					//reset accumulated damage
					g_fAccumDamage[attacker] = 0.0;
					//do not inflict damage since player was kicked/banned
					return Plugin_Handled;
				}
				//inflict damage to attacker
				SDKHooks_TakeDamage(attacker, inflictor, victim, damage, damagetype, weapon, damageForce, damagePosition);
				PrintToServer("%N %t %N", attacker, "Attacked", victim);
				PrintToChat(attacker, "[RFF] %t %N, %t.", "YouAttacked", victim, "InfectedFF");
			}
			//no damage for victim
			return Plugin_Handled;
		}
	}
	//all other damage behaves normal
	return Plugin_Continue;
}

stock bool IsWeaponGrenadeLauncher(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "grenade_launcher_projectile"));
}

stock bool IsWeaponMinigun(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "prop_minigun") || StrEqual(sInflictorClass, "prop_minigun_l4d1") || StrEqual(sInflictorClass, "prop_mounted_machine_gun"));
}

stock bool IsSpecialAmmo(int weapon, int attacker, int inflictor, int damagetype, bool bWeaponGL)
{
	//damage from gun with special ammo
	if ((weapon > 0 && attacker == inflictor) && (damagetype & DMG_BURN || damagetype & DMG_BLAST))
	{
		return true;
	}
	//damage from grenade launcher with incendiary ammo
	if ((bWeaponGL) && (damagetype & DMG_BURN))
	{
		return true;
	}
	//damage from melee weapon or weapon with regular ammo
	return false;
}

stock bool IsClientAdmin(int client)
{
    return CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false);
}

stock bool IsValidClientAndInGameAndSurvivor(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

stock bool IsValidClientAndInGameAndInfected(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3);
}

stock bool IsClientIncapped(int client)
{
	//convert integer to boolean for return value
	return !!GetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
}

public Action RFFNotice(Handle timer, int client)
{
	if (IsClientInGame(client) && g_bCvarAllow)
	{
		PrintToChat(client, "[RFF] %t", "Announce");
	}
}

public Action Event_StartGrace (Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("victim"));
	g_bGrace[client] = true;
	//debug grace period
	//PrintToServer("Start grace period for %i %N", client, client);
	CreateTimer(2.5, EndGrace, client);
}

public Action EndGrace (Handle timer, int client)
{
	if (IsClientInGame(client))
	{
		g_bGrace[client] = false;
		//debug grace period
		//PrintToServer("End grace period for %i %N", client, client);
	}
}

public Action FlipToggle(Handle timer, int attacker)
{
  g_bToggle[attacker] = false;
}
