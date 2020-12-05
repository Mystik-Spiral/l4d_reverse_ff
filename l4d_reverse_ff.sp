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

public Plugin myinfo =
{
	name = "[L4D2] Reverse Friendly-Fire",
	author = "Mystic Spiral",
	description = "Team attacker takes friendly-fire damage, victim takes no damage.",
	version = "1.0",
	url = "tbd"
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	int IsWeaponGrenadeLauncher = 0;
	if (inflictor > MaxClients)
	{
		char sInflictorClass[64];
		GetEdictClassname(inflictor, sInflictorClass, sizeof(sInflictorClass));
		if (StrEqual(sInflictorClass, "grenade_launcher_projectile"))
		{
			IsWeaponGrenadeLauncher = 1;
		}
	}
	if (IsValidClient(attacker) && IsClientInGame(attacker) && GetClientTeam(attacker) == 2)
	{
		if (IsValidClient(victim) && IsClientInGame(victim) && GetClientTeam(victim) == 2 && victim != attacker)
		{
			if (weapon > 0 || IsWeaponGrenadeLauncher == 1)
			{
				if (!IsClientAdmin(attacker))
				{
					SDKHooks_TakeDamage(attacker, inflictor, attacker, damage, damagetype, weapon, damageForce, damagePosition);
				}
				return Plugin_Handled;
			}
			return Plugin_Continue;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients);
}

stock bool IsClientAdmin(int client)
{
    return CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false);
}
