#include <sourcemod>
#include <sdktools>
#include <cstrike>


public Plugin:myinfo = {
    name = "OSReflect",
    author = "Pintuz",
    description = "A plugin to punish TK/TD",
    version = "0.01",
    url = "https://github.com/Pintuzoft/OSReflect"
};

public void OnPluginStart ( ) {
    HookEvent ( "player_hurt" , Event_PlayerHurt ) ;
}

/* EVENTS */
public void Event_PlayerHurt ( Event event, const char[] name, bool dontBroadcast ) {
    int attackerid = GetEventInt ( event, "attacker" ) ;
    int attacker = GetClientOfUserId ( attackerid );
    int victimid = GetEventInt ( event, "userid" );
    int victim = GetClientOfUserId ( victimid );
    int damage = GetEventInt ( event, "dmg_health" );
    int armor = GetEventInt ( event, "dmg_armor" );
    char userMessage[256];
    char adminMessage[256];
    char attackerName[64];
    char victimName[64];

    if (  attackerid == victimid ||
        ( damage == 0 && armor == 0) ||
        ( GetClientTeam ( attacker ) != GetClientTeam ( victim ) ) ) {
        return;
    }

    GetClientName ( attacker, attackerName, sizeof ( attackerName ) ) ;
    GetClientName ( victim, victimName, sizeof ( victimName ) ) ;

    Format ( userMessage, sizeof(userMessage), " \x04[OSReflect]\x07: %s TeamDamaged %s [%d damage, %d armor]", attackerName, victimName, damage, armor );
    Format ( adminMessage, sizeof(adminMessage), " \x04[AdminsOnly]\x07: %s TD %s [%d damage, %d armor]", attackerName, victimName, damage, armor );

    PrintToAdmins ( adminMessage );
    PrintToChat ( attacker, userMessage );
    PrintToChat ( victim, userMessage );

    /* REMOVE SAME AMOUNT OF DAMAGE FROM ATTACKER */
    SlapPlayer ( attacker, damage, true );
    SetEntProp ( attacker, Prop_Send, "m_ArmorValue", GetEntProp ( attacker, Prop_Send, "m_ArmorValue" ) - armor );
}

/* SEND MESSAGE TO ADMINS */
public void PrintToAdmins ( const char[] message ) {
    for ( int player = 1; player <= MaxClients; player++ ) {
        if ( playerIsReal ( player ) && playerIsAdmin ( player ) ) {
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