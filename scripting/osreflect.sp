#include <sourcemod>
#include <sdktools>
#include <cstrike>


public Plugin:myinfo = {
    name = "OSReflect",
    author = "Pintuz",
    description = "A plugin to punish TD",
    version = "0.01",
    url = "https://github.com/Pintuzoft/OSReflect"
};

public void OnPluginStart ( ) {
    HookEvent ( "player_hurt" , Event_PlayerHurt ) ;
    HookEvent ( "player_death" , Event_PlayerDeath ) ;
}

/* EVENTS */
public void Event_PlayerHurt ( Event event, const char[] name, bool dontBroadcast ) {
    int attackerid = GetEventInt ( event, "attacker" ) ;
    int attacker = GetClientOfUserId ( attackerid );
    int victimid = GetEventInt ( event, "userid" );
    int victim = GetClientOfUserId ( victimid );
    int damage = GetEventInt ( event, "dmg_health" );
    int armor = GetEventInt ( event, "dmg_armor" );
    char attackerMessage[256];
    char victimMessage[256];
    char adminMessage[256];
    char attackerName[64];
    char victimName[64];

    if (  isWarmup ( ) ||
          attackerid == victimid ||
        ( damage == 0 && armor == 0) ||
          GetClientTeam ( attacker ) != GetClientTeam ( victim ) ) {
        return;
    }

    GetClientName ( attacker, attackerName, sizeof ( attackerName ) ) ;
    GetClientName ( victim, victimName, sizeof ( victimName ) ) ;

    Format ( attackerMessage, sizeof(attackerMessage), " \x07[OSReflect]: BE CAREFUL! You hurt your teammate: \x04%s \x08[%d damage, %d armor]", victimName, damage, armor );
    Format ( victimMessage, sizeof(victimMessage), " \x04[OSReflect]\x01: You was damaged by teammate \x07%s \x08[%d damage, %d armor]", attackerName, damage, armor );
    Format ( adminMessage, sizeof(adminMessage), " \x04[AdminsOnly]\x01: \x07%s\x01 TD \x06%s \x08[%d damage, %d armor]", attackerName, victimName, damage, armor );

    PrintToAdmins ( adminMessage, attacker, victim );
    PrintToChat ( attacker, attackerMessage );
    PrintToChat ( victim, victimMessage );

    /* REMOVE SAME AMOUNT OF DAMAGE FROM ATTACKER */
    SlapPlayer ( attacker, damage, true );
    SetEntProp ( attacker, Prop_Send, "m_ArmorValue", GetEntProp ( attacker, Prop_Send, "m_ArmorValue" ) - armor );
}

public void Event_PlayerDeath ( Event event, const char[] name, bool dontBroadcast ) {
    int attackerid = GetEventInt ( event, "attacker" ) ;
    int attacker = GetClientOfUserId ( attackerid );
    int victimid = GetEventInt ( event, "userid" );
    int victim = GetClientOfUserId ( victimid );
    int damage = GetEventInt ( event, "dmg_health" );
    int armor = GetEventInt ( event, "dmg_armor" );
    char attackerMessage[256];
    char victimMessage[256];
    char adminMessage[256];
    char attackerName[64];
    char victimName[64];

    if (  isWarmup ( ) ||
          attackerid == victimid ||
          GetClientTeam ( attacker ) != GetClientTeam ( victim ) ) {
        return;
    }

    GetClientName ( attacker, attackerName, sizeof ( attackerName ) ) ;
    GetClientName ( victim, victimName, sizeof ( victimName ) ) ;

    Format ( attackerMessage, sizeof(attackerMessage), " \x07[OSReflect]: BE CAREFUL! You killed your teammate: %s", victimName );
    Format ( victimMessage, sizeof(victimMessage), " \x04[OSReflect]\x01: You was killed by teammate \x07%s", attackerName );
    Format ( adminMessage, sizeof(adminMessage), " \x04[AdminsOnly]\x01: \x07%s\x01 TK \x06%s", attackerName, victimName );

    PrintToAdmins ( adminMessage, -1, -1 );
    PrintToChat ( attacker, attackerMessage );
    PrintToChat ( victim, victimMessage );

    /* REMOVE SAME AMOUNT OF DAMAGE FROM ATTACKER */
    SlapPlayer ( attacker, damage, true );
    SetEntProp ( attacker, Prop_Send, "m_ArmorValue", GetEntProp ( attacker, Prop_Send, "m_ArmorValue" ) - armor );
}

/* SEND MESSAGE TO ADMINS */
public void PrintToAdmins ( const char[] message, int attacker, int victim ) {
    for ( int player = 1; player <= MaxClients; player++ ) {
        if ( player != attacker &&
             player != victim &&
             playerIsReal ( player ) && 
             playerIsAdmin ( player ) ) {
            PrintToChat ( player, message ) ;
        }
    }
}
 
/* RETURN TRUE IF PLAYER IS REAL */
public bool playerIsReal ( int player ) {
    return ( IsClientInGame ( player ) && ! IsFakeClient ( player ) ) ;
}

/* RETURN TRUE IF PLAYER IS AN ADMIN */
public bool playerIsAdmin ( int player ) {
    return ( GetUserFlagBits ( player ) > 0 );
}
/* isWarmup */
public bool isWarmup ( ) {
    if ( GameRules_GetProp ( "m_bWarmupPeriod" ) == 1 ) {
        return true;
    } 
    return false;
}