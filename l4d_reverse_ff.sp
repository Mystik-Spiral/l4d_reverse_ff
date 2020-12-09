/*

Reverse Friendly-Fire plugin (l4d_reverse_ff) by Mystik Spiral

This plugin reverses all friendly-fire... the attacker takes all of the damage and the victim takes none.
This forces players to be more precise with their shots... or they will spend a lot of time on the ground.
This also discourages griefers/team killers since they can only damage themselves and no one else.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse bomb/explosion damage.
This plugin does not reverse molotov/fire damage and I do not intend to add it.
Players with the generic admin flag will not have friendly-fire reversed or do damage to teammates.

*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.2"
#define CVAR_FLAGS FCVAR_NOTIFY

ConVar cvar_ReverseFFenabled;
ConVar cvar_AdminImmune;
ConVar cvar_SpclAmmoDamage;

bool g_bCvarReverseFFenabled;
bool g_bCvarAdminImmune;
float g_fCvarSpclAmmoDamage;

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
	CreateConVar("reverse_ff_version", PLUGIN_VERSION, "Reverse Friendly-Fire", CVAR_FLAGS|FCVAR_DONTRECORD);
	cvar_ReverseFFenabled = CreateConVar("reverse_ff_enabled", "1", "Enable this plugin", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_AdminImmune = CreateConVar("reverse_ff_admin_immune", "1", "Admin immune to reversing FF", CVAR_FLAGS, true, 0.0, true, 1.0);
	cvar_SpclAmmoDamage = CreateConVar("reverse_ff_spcl_ammo_damage_mult", "1.125", "Special ammo damage multiplier", CVAR_FLAGS, true, 1.0, true, 2.0);
	AutoExecConfig(true, "l4d_reverse_ff");
	
	GetCvars();
	
	cvar_ReverseFFenabled.AddChangeHook(action_ConVarChanged);
	cvar_AdminImmune.AddChangeHook(action_ConVarChanged);
	cvar_SpclAmmoDamage.AddChangeHook(action_ConVarChanged);
}

public int action_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarReverseFFenabled = cvar_ReverseFFenabled.BoolValue;
	g_bCvarAdminImmune = cvar_AdminImmune.BoolValue;
	g_fCvarSpclAmmoDamage = cvar_SpclAmmoDamage.FloatValue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	//PrintToServer("Vic: %i, Atk: %i, Inf: %i, Dam: %f, DamTyp: %i, Wpn: %i", victim, attacker, inflictor, damage, damagetype, weapon);
	if (IsValidClient(attacker) && IsClientInGame(attacker) && GetClientTeam(attacker) == 2) 							//attacker is valid, in game, and survivor
	{
		if (IsValidClient(victim) && IsClientInGame(victim) && GetClientTeam(victim) == 2 && victim != attacker)				//victim is valid, in game, and survivor
		{
			if (weapon > 0 || IsWeaponGrenadeLauncher(inflictor)) 										//if weapon caused damage proceed to reverse damage
			{
				if (!(IsClientAdmin(attacker) && g_bCvarAdminImmune == true))								//check admin immunity
				{
					if (IsSpecialAmmo(weapon, attacker, inflictor))									//if weapon has explosive or incendiary ammo
					{
						damage = damage * 1.125;										//increase damage by 12.5%
					}
					SDKHooks_TakeDamage(attacker, inflictor, victim, damage, damagetype, weapon, damageForce, damagePosition);	//inflict damage to attacker
				}
				return Plugin_Handled; 													//no damage for victim
			}
		}
	}
	return Plugin_Continue; //all other damage behaves normal
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

stock bool IsSpecialAmmo(int weapon, int attacker, int inflictor)
{
	if (weapon > 0 && attacker == inflictor) 										//prevent error with melee weapons which have different inflictor
	{
		int iAmmoBits = GetEntProp(weapon, Prop_Send, "m_upgradeBitVec");
		if (iAmmoBits == 1 || iAmmoBits == 5 || iAmmoBits == 2 || iAmmoBits == 6)					//0=none, 1=incendiary, 2=explosive, (4=laser), 5=incendiary+laser, 6=explosive+laser
		{
			return true;
		}
	}
	//have not figured out yet how to determine if grenade launcher ammo is incendiary/explosive
	//if(IsWeaponGrenadeLauncher(inflictor))
	//{
	//	int iAmmoBits = GetEntProp("grenade_launcher_projectile", Prop_Send, "m_upgradeBitVec");
	//	if (iAmmoBits == 1 || iAmmoBits == 5 || iAmmoBits == 2 || iAmmoBits == 6)
	//	{
	//		return true;
	//	}
	//}
	return false;
}

stock bool IsClientAdmin(int client)
{
    return CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false);
}
