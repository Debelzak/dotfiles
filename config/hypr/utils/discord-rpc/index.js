const RPC = require('discord-rpc');
const psList = require('ps-list');
const fetch = require('node-fetch'); // Certifique-se de que 'node-fetch' está instalado!

let client = new RPC.Client({ transport: 'ipc' });
let clientId = "259392830932254721"; //Initial
let wasInGame = false;

const executablesMap = new Map();

async function refreshActivity() {
    const rpcRequest = await fetch(`https://discordapp.com/api/v8/applications/${clientId}/rpc`);
    const rpcData = await rpcRequest.json();

    await client.setActivity({
        //details: 'Jogando', // Descrição principal
        //state: '', // Estado secundário
        startTimestamp: new Date(), // Marca o tempo de início
        largeImage: rpcData.icon ? `https://cdn.discordapp.com/app-icons/${clientId}/${rpcData.icon}.webp`: null, // Imagem do aplicativo
        largeImageText: rpcData.name, // Texto ao passar o mouse sobre a imagem
    });
}

async function renewClient(newClientId) {
    if(newClientId == clientId) {
        return;
    }

    client.destroy()
    client = new RPC.Client({ transport: 'ipc' });

    client.on('ready', () => {
        refreshActivity();
    });

    try {
        await client.login({ clientId });
    } catch (error) {
        console.error(`Erro ao logar o cliente RPC: ${error.message}`);
    }
}

async function watchProcesses() {
    const processes = await psList.default();

    let found = false;

    for (const proc of processes) {
        const executableName = proc.cmd.toLowerCase();
        //console.log(executableName);
        for (const [name, id] of executablesMap) {
            if (executableName.includes(name)) {
                found = true;

                if(clientId == id) break;

                clientId = id;

                try {
                    await renewClient(clientId);
                    console.log(`Jogo detectado! appId: ${id}, binário: ${name}`);
                } catch (error) {
                    console.error(`Erro ao definir atividade RPC: ${error.message}`);
                }
                break;
            }
        }

        if (found) break; // Sai do loop se encontrar o cliente
    }

    if (!found && wasInGame) {
        await client.clearActivity();
        console.warn('Saiu do jogo. Limpando atividade...');
    }

    wasInGame = found;
}

async function main() {
    console.log("Adquirindo lista de aplicativos detectáveis do Discord...");

    try {
        const detectablesRequest = await fetch("https://discordapp.com/api/v8/applications/detectable");
        const detectables = await detectablesRequest.json();

        for (const detectable of detectables) {
            if (detectable.executables) {
                for (const executable of detectable.executables) {
                    executablesMap.set(executable.name.toLowerCase(), detectable.id);
                }
            }
        }

        if (executablesMap.size < 1) {
            console.error("Nenhum executável detectável encontrado. Encerrando...");
            return;
        }

        console.log(`${executablesMap.size} binários detectáveis encontrados.`);
        console.log("Iniciando detecção de jogos...");

        setInterval(() => {
            watchProcesses();
        }, 10_000);

        await client.login({ clientId });
    } catch (error) {
        console.error(`Erro ao adquirir detectáveis: ${error.message}`);
    }
}

main().catch((error) => console.error(`Erro na inicialização: ${error.message}`));
