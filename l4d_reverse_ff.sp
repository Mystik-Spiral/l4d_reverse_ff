/*

Reverse Friendly-Fire plugin (l4d_reverse_ff) by Mystik Spiral

This plugin reverses all friendly-fire... the attacker takes all of the damage and the victim takes none.
This forces players to be more precise with their shots... or they will spend a lot of time on the ground.

Although this plugin discourages griefers/team killers since they can only damage themselves and no one else,
the first objective is to force players to improve their shooting tatics and aim.  The second objective is to
encourage new/inexperienced players to only join servers that match their skillset, rather than trying to play
in expert mode.  Before this plugin, beginners had no penalty for joining an expert game and constantly
incapping their teammates.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse explosion damage.
This plugin does not reverse molotov/gascan damage and I do not intend to add it, though I may make a
separate plugin to handle molotov/gascan damage.

Option to specify extra damage if attacker is using explosive/incendiary ammo. (default=12.5%)
Option to not reverse friendly-fire when attacker is an admin. (default)
Option to not reverse friendly-fire when victim is a bot. (default)

*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3"
#define CVAR_FLAGS FCVAR_NOTIFY

ConVar cvar_reverseff_enabled;
ConVar cvar_reverseff_immunity;
ConVar cvar_reverseff_multiplier;
ConVar cvar_reverseff_bot;

bool g_bCvarPluginEnabled;
bool g_bCvarAdminImmunity;
float g_fCvarDamageMultiplier;
bool g_bCvarReverseIfBot;

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
	CreateConVar("reverseff_version", PLUGIN_VERSION, "Reverse Friendly-Fire", CVAR_FLAGS|FCVAR_DONTRECORD);
	cvar_reverseff_enabled = CreateConVar("reverseff_enabled", "1", "Enable this plugin", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_reverseff_immunity = CreateConVar("reverseff_immunity", "1", "Admin immune to reversing FF", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_reverseff_multiplier = CreateConVar("reverseff_multiplier", "1.125", "Special ammo damage multiplier", CVAR_FLAGS, true, 1.0, true, 2.0);
	cvar_reverseff_bot = CreateConVar("reverseff_bot", "0", "Reverse FF if victim is bot", CVAR_FLAGS, true, 0.0, true, 1.0);
	AutoExecConfig(true, "l4d_reverse_ff");
	
	GetCvars();
	
	cvar_reverseff_enabled.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_immunity.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_multiplier.AddChangeHook(action_ConVarChanged);
	cvar_reverseff_bot.AddChangeHook(action_ConVarChanged);
}

public int action_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarPluginEnabled = cvar_reverseff_enabled.BoolValue;
	g_bCvarAdminImmunity = cvar_reverseff_immunity.BoolValue;
	g_fCvarDamageMultiplier = cvar_reverseff_multiplier.FloatValue;
	g_bCvarReverseIfBot = cvar_reverseff_bot.BoolValue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (!g_bCvarPluginEnabled)
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
					damage = damage * g_fCvarDamageMultiplier;									//damage * "reverseff_multiplier"
				}
				SDKHooks_TakeDamage(attacker, inflictor, victim, damage, damagetype, weapon, damageForce, damagePosition);		//inflict damage to attacker
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
