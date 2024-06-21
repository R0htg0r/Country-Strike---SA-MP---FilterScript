/* 
   | -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- |
   |           Sistema de Country Strike. Desenvolvido por R0htg0r!!                 |
   |                 Se for repostar não retire os creditos                          |
   | -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- |
*/

#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <zcmd>

#if defined FILTERSCRIPT
public OnFilterScriptInit(){
    CarregarPrincipal();
}

public OnFilterScriptExit(){
    print("\n--------------------------------------");
    print("MiniGames descarregou");
    print("--------------------------------------\n");
    return 1;
}
#else
main(){
    CarregarPrincipal();
}
#endif

// Variáveis
enum Ficha{
    bool:EntrouCS,
    bool:BettleRoyale,
    Rival[2],
    Abates,
    Morreu,
    Partidas_total,
    Partidas_vencidas,
    Partidas_perdidas
};

new ObterFichaUsuario[MAX_PLAYERS][Ficha];

new Float:TeamsPos[2][3] = {
    {-27.6899,1402.5272,9.2683},
    {30.2298,1331.1143,9.7723}
};

public OnPlayerConnect(playerid){
    // Lobby
    RemoveBuildingForPlayer(playerid, 8931, 2162.4766, 1403.4375, 14.6563, 0.25);
    RemoveBuildingForPlayer(playerid, 718, 2147.1563, 1424.7422, 9.7656, 0.25);
    RemoveBuildingForPlayer(playerid, 8839, 2162.4766, 1403.4375, 14.6563, 0.25);
    RemoveBuildingForPlayer(playerid, 8840, 2162.7891, 1401.4141, 14.3750, 0.25);
    RemoveBuildingForPlayer(playerid, 718, 2171.8672, 1424.6406, 9.7656, 0.25);

    return 1;
}

public OnPlayerRequestClass(playerid, classid){
    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
    if(ObterFichaUsuario[playerid][EntrouCS] == true && ObterFichaUsuario[killerid][EntrouCS] == true){
        // ARMAZENAMENTO DE ESTATÍSTICAS.
        ObterFichaUsuario[killerid][Abates] += 1; // Abates!!
        ObterFichaUsuario[playerid][Morreu] += 1; // Morreu!!
        
        ObterFichaUsuario[killerid][Partidas_total] += 1; // Partidas Total
        ObterFichaUsuario[playerid][Partidas_total] += 1; // Partidas Total

        ObterFichaUsuario[killerid][Partidas_vencidas] += 1; // Partidas Vencidas
        ObterFichaUsuario[playerid][Partidas_perdidas] += 1; // Partidas Perdidas
        
        // TAREFA DE RETORNO
        ResetPlayerWeapons(killerid); // Remover as armas
        ResetPlayerWeapons(playerid); // Remover as armas

        ObterFichaUsuario[playerid][EntrouCS] = false; // Desconectar os dois.
        ObterFichaUsuario[killerid][EntrouCS] = false; // Desconectar os dois.
        
        ObterFichaUsuario[playerid][Rival][0] = -1; // Desfazer equipe!!
        ObterFichaUsuario[killerid][Rival][0] = -1; // Desfazer equipe!!

        SendClientMessage(playerid, -1, "Sua morte fez voce perder R$ 1.000,00 da partida.");
        SendClientMessage(killerid, -1, "Parabens, voce venceu a partida e ganhou R$ 1.000,00 para gastar.");
        
        GivePlayerMoney(killerid, 1000);
        GivePlayerMoney(playerid, -1000);

        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerVirtualWorld(killerid, 0);
        SetPlayerPos(killerid, 860.0649,-1280.4231,14.2054);
    }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
    if (newkeys == 65536){ // SE "Y" FOR CHAMADO PELO TECLADO.
        VerEstatisticasRemover(playerid);

        if(IsPlayerInRangeOfPoint(playerid, 2.0, 2149.8560,1412.4043,10.8203)){
            EntrarCS(playerid);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2151.9702,1414.6661,10.8203)){
            print("OK");
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2152.0623,1418.5389,10.8203)){
            VerEstatisticas(playerid);
        }
    }
    return 1;
}

stock ObterUsuario(playerid){ new UsuarioN[MAX_PLAYER_NAME]; GetPlayerName(playerid, UsuarioN, MAX_PLAYER_NAME); return UsuarioN; }
stock ObterIP(playerid){ new UsuarioIP[MAX_PLAYER_NAME]; GetPlayerIP(playerid, UsuarioIP, sizeof(UsuarioIP)); return UsuarioIP; }

forward VerEstatisticas(playerid);
forward CarregarPrincipal();
forward VerEstatisticasRemover(playerid);
forward EntrarCS(playerid);
forward SairCS(playerid);

public EntrarCS(playerid){
    if(ObterFichaUsuario[playerid][EntrouCS] == true) return SendClientMessage(playerid, -1, "{BEBEBE}[ERROR] : Voce ja esta no modo Country Strike, use /saircs");
    
    ObterFichaUsuario[playerid][EntrouCS] = true; // Agora ele entrou!!
    SendClientMessage(playerid, -1, "[PROCURANDO] Aguardando nova partida....");
    
    for(new i = 0; i <= GetMaxPlayers(); i++){ // TODOS OS PLAYERID
        if(ObterFichaUsuario[i][Rival][0] == -1){ // VAGO!
            if(ObterFichaUsuario[i][EntrouCS] == true){ // VAGO E DESEJA JOGAR!
                if(i != playerid){ // NÃO É REPITIDO!
                    if(IsPlayerConnected(i)){ // VAGO, DESEJA JOGAR E ESTÁ LOGADO!!
                        new Ox001 = random(1);

                        ObterFichaUsuario[i][Rival][0] = playerid; // Rival playerid
                        ObterFichaUsuario[playerid][Rival][0] = i; // Rival i

                        SendClientMessage(playerid, -1, "Uma partida foi encontrada para voce!!.");
                        SendClientMessage(i, -1, "Uma partida foi encontrada para voce!!.");

                        if(Ox001 == 0) {
                            SetPlayerVirtualWorld(playerid, playerid+1);
                            SetPlayerVirtualWorld(i, playerid+1);

                            SetPlayerPos(playerid, TeamsPos[0][0], TeamsPos[0][1], TeamsPos[0][2]);
                            SetPlayerPos(i, TeamsPos[1][0], TeamsPos[1][1], TeamsPos[1][2]);
                        } else {
                            SetPlayerVirtualWorld(playerid, i+1);
                            SetPlayerVirtualWorld(i, i+1);

                            SetPlayerPos(i, TeamsPos[0][0], TeamsPos[0][1], TeamsPos[0][2]);
                            SetPlayerPos(playerid, TeamsPos[1][0], TeamsPos[1][1], TeamsPos[1][2]);
                        }

                        GivePlayerWeapon(i, 31, 200);
                        GivePlayerWeapon(playerid, 31, 200);

                        SetPlayerHealth(i, 100.0);
                        SetPlayerHealth(playerid, 100.0);
                        break;
                    }
                }
            }
        }
    }
    return 1;
}

public SairCS(playerid){
    if(ObterFichaUsuario[playerid][EntrouCS] == false) return SendClientMessage(playerid, -1, "{BEBEBE}[ERROR] : Voce nao está no modo Country Strike, use /entrarcs");
    
    // Não está mais disponível para jogar.
    ObterFichaUsuario[playerid][EntrouCS] = false; // Agora ele entrou!!
    SendClientMessage(playerid, -1, "[SYSTEM] Novas partidas canceladas.");
    
    if(ObterFichaUsuario[playerid][Rival][0] != -1){
        new euid, rivalid, buffer[128];

        rivalid = ObterFichaUsuario[playerid][Rival][0]; // Rival
        euid = ObterFichaUsuario[rivalid][Rival][0]; // Eu

        ObterFichaUsuario[rivalid][EntrouCS] = false;
        ObterFichaUsuario[euid][EntrouCS] = false;

        ObterFichaUsuario[rivalid][Rival][0] = -1; // Rival
        ObterFichaUsuario[euid][Rival][0] = -1; // Eu

        format(buffer, sizeof(buffer), "A partida foi encerrada por %s", ObterUsuario(playerid));
        SendClientMessage(rivalid, -1, buffer);

        format(buffer, sizeof(buffer), "Você cancelou a partida e perdeu seu R$ 1.000,00 da aposta.");
        SendClientMessage(euid, -1, buffer);

        GivePlayerMoney(rivalid, 1000);
        GivePlayerMoney(euid, -1000);

        ResetPlayerWeapons(rivalid);
        ResetPlayerWeapons(euid);

        SetPlayerVirtualWorld(rivalid, 0);
        SetPlayerVirtualWorld(euid, 0);

        SpawnPlayer(rivalid);
        SpawnPlayer(euid);
    }
    return 1;
}

public CarregarPrincipal(){
    print("Sistema de Country Strike. Desenvolvido por R0htg0r!!");
    AddPlayerClass(0,2136.2703,1416.6705,10.8203,267.4676,0,0,0,0,0,0); // Renascimento
    
    // Veículos
    new VeiculosFixos[10];
    VeiculosFixos[0] = AddStaticVehicle(482,2149.1223,1408.6764,10.9398,180.4561,48,48); // Burrito 1
    VeiculosFixos[1] = AddStaticVehicle(482,2154.4490,1411.7684,10.9405,235.2404,52,52); // Burrito 2
    VeiculosFixos[2] = AddStaticVehicle(482,2155.5735,1417.2737,10.9406,270.1273,64,64); // Burrito 3
    VeiculosFixos[3] = AddStaticVehicle(420,2152.6140,1423.3907,10.6006,49.9178,6,1); // Taxi

    SetVehicleParamsCarDoors(VeiculosFixos[0], 0, 0, 1, 1);
    SetVehicleParamsCarDoors(VeiculosFixos[1], 0, 0, 1, 1);
    SetVehicleParamsCarDoors(VeiculosFixos[2], 0, 0, 1, 1);

    SetVehicleParamsEx(VeiculosFixos[0], 0, 0, 0, 1, 0, 0, 0);
    SetVehicleParamsEx(VeiculosFixos[1], 0, 0, 0, 1, 0, 0, 0);
    SetVehicleParamsEx(VeiculosFixos[2], 0, 0, 0, 1, 0, 0, 0);
    SetVehicleParamsEx(VeiculosFixos[3], 0, 0, 0, 1, 0, 0, 0);

    // NPC - Proxímo ao Burrito
    CreateActor(264,2149.8560,1412.4043,10.8203,56.2385); // V_1
    CreateActor(264,2151.9702,1414.6661,10.8203,56.2385); // V_2
    CreateActor(264,2152.0623,1418.5389,10.8203,121.4687); // V_3

    // NPC - Frases
    Create3DTextLabel("1 vs 1\nTecle 'Y' para entrar.", 0x008080FF, 2149.2405,1412.7405,10.8203, 500.0, 0, 0);
    Create3DTextLabel("Em breve!!", 0x008080FF, 2151.3430,1414.3477,10.8203, 500.0, 0, 0);
    Create3DTextLabel("Suas estatisticas", 0x008080FF, 2151.5334,1418.0745,10.8203, 500.0, 0, 0);

    print("Carregando valores.");
    for(new i = 0; i <= GetMaxPlayers(); i++) {
        ObterFichaUsuario[i][Rival][0] = -1;
        new texto[200]; format(texto, sizeof(texto), "Carregado: %d", ObterFichaUsuario[i][Rival][0]);
        print(texto);
    }
    print("Carregado!!!");

    // Lobby
    CreateDynamicObject(3571, 2131.31714, 1428.03345, 11.24107,   0.00000, 0.00000, 359.92081);
    CreateDynamicObject(3571, 2159.02856, 1404.28491, 11.08281,   0.00000, 0.00000, 180.18777);
    CreateDynamicObject(3571, 2138.85205, 1404.28760, 11.07875,   0.00000, 0.00000, 0.33353);
    CreateDynamicObject(3571, 2131.20605, 1404.22827, 11.07875,   0.00000, 0.00000, 0.33353);
    CreateDynamicObject(3571, 2158.94653, 1427.95154, 11.24107,   0.00000, 0.00000, 180.02908);
    CreateDynamicObject(3571, 2150.94336, 1427.98047, 11.24107,   0.00000, 0.00000, 180.02908);
    CreateDynamicObject(3571, 2143.10278, 1428.05273, 11.24107,   0.00000, 0.00000, 180.02908);
    CreateDynamicObject(3571, 2135.24707, 1428.00391, 11.24107,   0.00000, 0.00000, 180.02908);
    CreateDynamicObject(3571, 2131.19507, 1404.36963, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2128.53052, 1416.17126, 11.24107,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2128.56592, 1423.27490, 11.24107,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2146.51416, 1404.30981, 11.07875,   0.00000, 0.00000, 0.33353);
    CreateDynamicObject(3571, 2154.15430, 1404.27991, 11.07875,   0.00000, 0.00000, 0.33353);
    CreateDynamicObject(3571, 2161.70947, 1423.01123, 11.18281,   0.00000, 0.00000, 269.74265);
    CreateDynamicObject(3571, 2161.72754, 1414.95886, 11.08281,   0.00000, 0.00000, 269.74265);
    CreateDynamicObject(3571, 2161.75977, 1407.57861, 11.08281,   0.00000, 0.00000, 269.74265);
    CreateDynamicObject(3571, 2128.48193, 1408.93628, 11.24107,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2128.47437, 1408.93604, 13.68647,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2128.49756, 1416.98999, 13.68647,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2128.51025, 1425.07813, 13.68647,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2161.82056, 1407.02930, 13.68647,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2161.82520, 1414.84119, 13.68647,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2161.85645, 1422.57935, 13.68647,   0.00000, 0.00000, 269.38919);
    CreateDynamicObject(3571, 2133.14600, 1427.88391, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2140.90698, 1427.89941, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2148.44141, 1427.76111, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2159.12183, 1427.77100, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2152.57227, 1427.82129, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2157.10034, 1404.24768, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2149.72998, 1404.18140, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2142.13892, 1404.26440, 13.68647,   0.00000, 0.00000, 179.46556);
    CreateDynamicObject(3571, 2134.17358, 1404.35950, 13.68647,   0.00000, 0.00000, 179.46556);

    new vs_transparent[18];
    // 1 vs 1
    vs_transparent[0] = CreateDynamicObject(4238, -35.81648, 1405.19043, 11.92855,   0.00000, 0.00000, 67.14254);
    vs_transparent[1] = CreateDynamicObject(4238, -23.58055, 1410.41382, 11.74188,   0.00000, 0.00000, 43.48585);
    vs_transparent[2] = CreateDynamicObject(4238, -3.77285, 1412.22644, 11.92293,   0.00000, 0.00000, 28.00528);
    vs_transparent[3] = CreateDynamicObject(4238, 15.12008, 1406.65698, 11.93314,   0.00000, 0.00000, 359.48627);
    vs_transparent[4] = CreateDynamicObject(4238, 31.66056, 1397.04529, 11.84496,   0.00000, 0.00000, 0.76165);
    vs_transparent[5] = CreateDynamicObject(4238, 45.39566, 1384.93652, 11.91536,   0.00000, 0.00000, 338.72522);
    vs_transparent[6] = CreateDynamicObject(4238, 50.82069, 1368.06079, 11.91536,   0.00000, 0.00000, 299.25247);
    vs_transparent[7] = CreateDynamicObject(4238, 49.24807, 1350.41370, 11.91536,   0.00000, 0.00000, 292.07529);
    vs_transparent[8] = CreateDynamicObject(4238, 43.07282, 1334.84412, 11.91536,   0.00000, 0.00000, 264.64825);
    vs_transparent[9] = CreateDynamicObject(4238, 43.07282, 1334.84412, 11.91536,   0.00000, 0.00000, 264.64825);
    vs_transparent[10] = CreateDynamicObject(4238, 30.54869, 1326.22839, 11.91536,   0.00000, 0.00000, 223.07755);
    vs_transparent[11] = CreateDynamicObject(4238, 12.40942, 1323.70886, 11.91536,   0.00000, 0.00000, 214.23167);
    vs_transparent[12] = CreateDynamicObject(4238, -7.15414, 1324.84485, 11.91536,   0.00000, 0.00000, 200.70076);
    vs_transparent[13] = CreateDynamicObject(4238, -25.65719, 1328.66589, 11.91536,   0.00000, 0.00000, 196.24995);
    vs_transparent[14] = CreateDynamicObject(4238, -37.00821, 1340.07617, 11.92593,   0.00000, 0.00000, 134.30191);
    vs_transparent[15] = CreateDynamicObject(4238, -40.51466, 1358.29871, 11.92593,   0.00000, 0.00000, 127.57232);
    vs_transparent[16] = CreateDynamicObject(4238, -42.61771, 1377.77734, 11.92593,   0.00000, 0.00000, 125.17099);
    vs_transparent[17] = CreateDynamicObject(4238, -40.43611, 1396.18433, 11.92593,   0.00000, 0.00000, 102.20221);
    
    for(new i; i< 10; i++){
        SetObjectMaterial(vs_transparent[0], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[1], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[2], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[3], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[4], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[5], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[6], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[7], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[8], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[9], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[10], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[11], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[12], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[13], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[14], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[15], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[16], i, 0, "none", "none", 0x00000000);
        SetObjectMaterial(vs_transparent[17], i, 0, "none", "none", 0x00000000);
    }
}

new BufferEs[1024];
new PlayerText: EstatisticasP[MAX_PLAYERS][27];
public VerEstatisticas(playerid){
    EstatisticasP[playerid][0] = CreatePlayerTextDraw(playerid, 170.000, 143.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][0], 307.000, 172.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][0], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][0], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][0], 1);

    EstatisticasP[playerid][1] = CreatePlayerTextDraw(playerid, 171.000, 145.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][1], 305.000, 168.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][1], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][1], 6553855);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][1], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][1], 1);

    EstatisticasP[playerid][2] = CreatePlayerTextDraw(playerid, 206.000, 164.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][2], 261.000, 125.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][2], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][2], 1433087999);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][2], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][2], 1);

    EstatisticasP[playerid][3] = CreatePlayerTextDraw(playerid, 214.000, 168.000, "LD_DRV:goboat");
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][3], 37.000, 34.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][3], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][3], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][3], 1);

    format(BufferEs, sizeof(BufferEs), "%d", ObterFichaUsuario[playerid][Abates]);
    EstatisticasP[playerid][4] = CreatePlayerTextDraw(playerid, 282.000, 224.000, BufferEs);
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][4], 0.180, 0.999);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][4], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][4], 40);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][4], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][4], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][4], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][4], 1);

    format(BufferEs, sizeof(BufferEs), "%d", ObterFichaUsuario[playerid][Morreu]);
    EstatisticasP[playerid][5] = CreatePlayerTextDraw(playerid, 344.000, 224.000, BufferEs);
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][5], 0.180, 0.999);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][5], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][5], 40);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][5], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][5], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][5], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][5], 1);

    EstatisticasP[playerid][6] = CreatePlayerTextDraw(playerid, 246.000, 292.000, "Carteira de Identidade");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][6], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][6], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][6], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][6], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][6], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][6], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][6], 1);

    EstatisticasP[playerid][7] = CreatePlayerTextDraw(playerid, 212.000, 207.000, "_");
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][7], 63.000, 72.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][7], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][7], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][7], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][7], 85);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][7], 5);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][7], 0);
    PlayerTextDrawSetPreviewModel(playerid, EstatisticasP[playerid][7], 0);
    PlayerTextDrawSetPreviewRot(playerid, EstatisticasP[playerid][7], 0.000, 0.000, 0.000, 1.000);
    PlayerTextDrawSetPreviewVehCol(playerid, EstatisticasP[playerid][7], 0, 0);

    EstatisticasP[playerid][8] = CreatePlayerTextDraw(playerid, 341.000, 207.000, "TOTAL");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][8], 0.259, 1.199);
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][8], 0.000, -7.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][8], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][8], -65281);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][8], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][8], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][8], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][8], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][8], 1);

    EstatisticasP[playerid][9] = CreatePlayerTextDraw(playerid, 278.000, 240.000, "MORTES");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][9], 0.259, 1.199);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][9], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][9], -65281);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][9], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][9], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][9], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][9], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][9], 1);

    EstatisticasP[playerid][10] = CreatePlayerTextDraw(playerid, 340.000, 240.000, "VENCIDAS");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][10], 0.259, 1.199);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][10], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][10], -65281);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][10], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][10], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][10], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][10], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][10], 1);

    EstatisticasP[playerid][11] = CreatePlayerTextDraw(playerid, 278.000, 207.000, "ABATES");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][11], 0.259, 1.199);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][11], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][11], -65281);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][11], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][11], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][11], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][11], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][11], 1);

    EstatisticasP[playerid][12] = CreatePlayerTextDraw(playerid, 406.000, 207.000, "PERDIDAS");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][12], 0.259, 1.199);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][12], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][12], -65281);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][12], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][12], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][12], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][12], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][12], 1);

    format(BufferEs, sizeof(BufferEs), "%s", ObterUsuario(playerid));
    EstatisticasP[playerid][13] = CreatePlayerTextDraw(playerid, 300.000, 179.000, BufferEs);
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][13], 0.180, 0.999);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][13], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][13], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][13], 40);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][13], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][13], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][13], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][13], 1);

    EstatisticasP[playerid][14] = CreatePlayerTextDraw(playerid, 263.000, 177.000, "NOME");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][14], 0.239, 1.299);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][14], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][14], -65281);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][14], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][14], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][14], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][14], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][14], 1);

    EstatisticasP[playerid][15] = CreatePlayerTextDraw(playerid, 468.000, 143.000, "Y");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][15], 0.300, 1.500);
    PlayerTextDrawTextSize(playerid, EstatisticasP[playerid][15], 0.000, -15.000);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][15], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][15], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][15], 0);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][15], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][15], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][15], 1);

    format(BufferEs, sizeof(BufferEs), "%d", ObterFichaUsuario[playerid][Partidas_total]);
    EstatisticasP[playerid][16] = CreatePlayerTextDraw(playerid, 344.000, 255.000, BufferEs);
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][16], 0.180, 0.999);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][16], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][16], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][16], 40);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][16], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][16], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][16], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][16], 1);

    format(BufferEs, sizeof(BufferEs), "%d", ObterFichaUsuario[playerid][Partidas_vencidas]);
    EstatisticasP[playerid][17] = CreatePlayerTextDraw(playerid, 282.000, 255.000, BufferEs);
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][17], 0.180, 0.999);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][17], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][17], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][17], 40);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][17], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][17], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][17], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][17], 1);

    format(BufferEs, sizeof(BufferEs), "%d", ObterFichaUsuario[playerid][Partidas_perdidas]);
    EstatisticasP[playerid][18] = CreatePlayerTextDraw(playerid, 409.000, 224.000, BufferEs);
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][18], 0.180, 0.999);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][18], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][18], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][18], 40);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][18], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][18], 255);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][18], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][18], 1);

    EstatisticasP[playerid][19] = CreatePlayerTextDraw(playerid, 186.000, 165.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][19], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][19], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][19], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][19], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][19], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][19], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][19], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][19], 1);

    EstatisticasP[playerid][20] = CreatePlayerTextDraw(playerid, 186.000, 218.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][20], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][20], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][20], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][20], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][20], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][20], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][20], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][20], 1);

    EstatisticasP[playerid][21] = CreatePlayerTextDraw(playerid, 186.000, 237.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][21], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][21], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][21], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][21], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][21], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][21], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][21], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][21], 1);

    EstatisticasP[playerid][22] = CreatePlayerTextDraw(playerid, 186.000, 256.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][22], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][22], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][22], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][22], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][22], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][22], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][22], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][22], 1);

    EstatisticasP[playerid][23] = CreatePlayerTextDraw(playerid, 186.000, 201.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][23], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][23], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][23], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][23], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][23], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][23], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][23], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][23], 1);

    EstatisticasP[playerid][24] = CreatePlayerTextDraw(playerid, 186.000, 274.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][24], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][24], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][24], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][24], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][24], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][24], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][24], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][24], 1);

    EstatisticasP[playerid][25] = CreatePlayerTextDraw(playerid, 186.000, 183.000, "$");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][25], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][25], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][25], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][25], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][25], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][25], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][25], 1);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][25], 1);

    EstatisticasP[playerid][26] = CreatePlayerTextDraw(playerid, 227.000, 147.000, "REPUBLICA FEDERATIVA DO BRASIL");
    PlayerTextDrawLetterSize(playerid, EstatisticasP[playerid][26], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, EstatisticasP[playerid][26], 1);
    PlayerTextDrawColor(playerid, EstatisticasP[playerid][26], -1);
    PlayerTextDrawSetShadow(playerid, EstatisticasP[playerid][26], 1);
    PlayerTextDrawSetOutline(playerid, EstatisticasP[playerid][26], 1);
    PlayerTextDrawBackgroundColor(playerid, EstatisticasP[playerid][26], 150);
    PlayerTextDrawFont(playerid, EstatisticasP[playerid][26], 2);
    PlayerTextDrawSetProportional(playerid, EstatisticasP[playerid][26], 1);

    PlayerTextDrawShow(playerid, EstatisticasP[playerid][0]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][1]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][2]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][3]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][4]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][5]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][6]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][7]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][8]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][9]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][10]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][11]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][12]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][13]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][14]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][15]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][16]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][17]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][18]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][19]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][20]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][21]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][22]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][23]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][24]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][25]);
    PlayerTextDrawShow(playerid, EstatisticasP[playerid][26]);
    return 1;
}

public VerEstatisticasRemover(playerid){
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][0]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][1]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][2]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][3]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][4]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][5]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][6]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][7]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][8]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][9]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][10]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][11]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][12]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][13]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][14]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][15]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][16]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][17]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][18]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][19]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][20]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][21]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][22]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][23]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][24]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][25]);
    PlayerTextDrawHide(playerid, EstatisticasP[playerid][26]);
    return 1;
}

CMD:status(playerid){
    VerEstatisticas(playerid);
    return 1;
}

CMD:entrarcs(playerid){
    EntrarCS(playerid);
    return 1;
}

CMD:saircs(playerid){
    SairCS(playerid);
    return 1;
}