/*

Reverse Friendly-Fire plugin (l4d_reverse_ff) by Mystik Spiral

This plugin reverses all friendly-fire... the attacker takes all of the damage and the victim takes none.
This forces players to be more precise with their shots... or they will spend a lot of time on the ground.
This also discourages griefers/team killers since they can only damage themselves and no one else.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse bomb/explosion damage.
This plugin does not reverse molotov/fire damage and I do not intend to add it.
Option to specify extra damage if attacker is using explosive/incendiary ammo. (default=12.5%)
Option to not reverse friendly-fire when attacker is an admin. (default)
Option to not reverse friendly-fire when victim is a bot. (default)

*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.4.1"
#define CVAR_FLAGS FCVAR_NOTIFY

ConVar cvar_reverseff_enabled;
ConVar cvar_reverseff_immunity;
ConVar cvar_reverseff_multiplier;
ConVar cvar_reverseff_bot;
ConVar cvar_reverseff_maxdamage;
ConVar cvar_reverseff_banduration;

bool g_bCvarRffPluginEnabled;
bool g_bCvarAdminImmunity;
float g_fCvarDamageMultiplier;
bool g_bCvarReverseIfBot;
float g_fAccumDamage[MAXPLAYERS+1];
float g_fMaxAlwdDamage;
int g_iBanDuration;

public Plugin myinfo =
{
	name = "[L4D2] Reverse Friendly-Fire",
	author = "Mystic Spiral",
	description = "Team attacker takes friendly-fire damage, victim takes no damage.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2727641#post2727641"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if ( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("reverseff_version", PLUGIN_VERSION, "Reverse Friendly-Fire", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvar_reverseff_enabled = CreateConVar("reverseff_enabled", "1", "Enable this plugin", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_reverseff_immunity = CreateConVar("reverseff_immunity", "1", "Admin immune to reversing FF", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_reverseff_multiplier = CreateConVar("reverseff_multiplier", "1.125", "Special ammo damage multiplier", CVAR_FLAGS, true, 1.0, true, 2.0);
	cvar_reverseff_bot = CreateConVar("reverseff_bot", "0", "Reverse FF if victim is bot", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_reverseff_maxdamage = CreateConVar("reverseff_maxdamage", "180", "Maximum damage allowed before kicking", CVAR_FLAGS, true, 0.0, true, 999.0);
	cvar_reverseff_banduration = CreateConVar("reverseff_banduration", "10", "Ban duration in minutes (0=permanent)", CVAR_FLAGS, true, 0.0, false);
	AutoExecConfig(true, "l4d_reverse_ff");
	
	GetCvars();
	
	cvar_reverseff_enabled.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_immunity.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_multiplier.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_bot.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_maxdamage.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_banduration.AddChangeHook(action_ConVarChanged);
}

public int action_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarRffPluginEnabled = cvar_reverseff_enabled.BoolValue;
	g_bCvarAdminImmunity = cvar_reverseff_immunity.BoolValue;
	g_fCvarDamageMultiplier = cvar_reverseff_multiplier.FloatValue;
	g_bCvarReverseIfBot = cvar_reverseff_bot.BoolValue;
	g_fMaxAlwdDamage = cvar_reverseff_maxdamage.FloatValue;
	g_iBanDuration = cvar_reverseff_banduration.IntValue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_fAccumDamage[client] = 0.0;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (!g_bCvarRffPluginEnabled)
	{
		return Plugin_Continue;
	}
	//PrintToServer("Vic: %i, Atk: %i, Inf: %i, Dam: %f, DamTyp: %i, Wpn: %i", victim, attacker, inflictor, damage, damagetype, weapon);
	if (IsValidClientAndInGameAndSurvivor(attacker) && IsValidClientAndInGameAndSurvivor(victim) && victim != attacker)				//attacker and victim checks
	{
		bool bWeaponGL = IsWeaponGrenadeLauncher(inflictor);											//is weapon grenade launcher
		//PrintToServer("bWeaponGL: %b, weapon: %i", bWeaponGL, weapon);
		if (weapon > 0 || bWeaponGL) 														//if weapon caused damage
		{
			//PrintToServer("g_bCvarAdminImmunity: %b, g_bCvarReverseIfBot: %b", g_bCvarAdminImmunity, g_bCvarReverseIfBot);
			if (!((IsClientAdmin(attacker) && g_bCvarAdminImmunity == true) || (IsFakeClient(victim) && g_bCvarReverseIfBot == false)))	//check admin immunity or bot
			{
				if (IsSpecialAmmo(weapon, attacker, inflictor, damagetype, bWeaponGL))							//special ammo checks
				{
					damage *= g_fCvarDamageMultiplier;										//damage * "reverseff_multiplier"
				}
				g_fAccumDamage[attacker] += damage;											//accumulate damage total for attacker
				PrintToServer("Plyr: %N, Dmg: %f, AcmDamage: %f", attacker, damage, g_fAccumDamage[attacker]);
				if (g_fAccumDamage[attacker] > g_fMaxAlwdDamage)									//does accumulated damage exceed "reverseff_maxdamage"
				{
					BanClient(attacker, g_iBanDuration, BANFLAG_AUTO, "ExcessiveFF", "Excessive Friendly-Fire", _, attacker);	//ban attacker for "reverseff_banduration"
					g_fAccumDamage[attacker] = 0.0;											//reset accumulated damage
					return Plugin_Handled;												//do not inflict damage since player was banned
				}
				SDKHooks_TakeDamage(attacker, inflictor, attacker, damage, damagetype, weapon, damageForce, damagePosition);		//inflict damage to attacker
			}
			return Plugin_Handled; 														//no damage for victim
		}
	}
	return Plugin_Continue;																//all other damage behaves normal
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients);
}

stock bool IsWeaponGrenadeLauncher(int inflictor)
{
	if (inflictor > MaxClients)
	{
		char sInflictorClass[64];
		GetEdictClassname(inflictor, sInflictorClass, sizeof(sInflictorClass));
		if (StrEqual(sInflictorClass, "grenade_launcher_projectile"))
		{
			return true;
		}
	}
	return false;
}

stock bool IsSpecialAmmo(int weapon, int attacker, int inflictor, int damagetype, bool bWeaponGL)
{
	if (weapon > 0 && attacker == inflictor) 						//prevent error with melee weapons which have different inflictor
	{
		if (damagetype & DMG_BURN || damagetype & DMG_BLAST)				//damage from gun with special ammo
		{
			return true;
		}
	}
	if (bWeaponGL)
	{
		if (damagetype & DMG_BURN)							//damage from grenade launcher with incendiary ammo
		{
			return true;
		}
	}
	return false;										//damage from weapon with regular ammo
}

stock bool IsClientAdmin(int client)
{
    return CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false);
}

stock bool IsValidClientAndInGameAndSurvivor(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}
