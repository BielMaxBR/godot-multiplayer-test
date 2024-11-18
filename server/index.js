import { WebSocketServer } from 'ws';

const wss = new WebSocketServer({ port: 8080 });

const clients = new Set();

let clientCounter = 0

wss.on('connection', (ws) => {
	init_player(ws)
	ws.on('message', (message) => {
		const data = JSON.parse(message.toString())
		if (!data.type) return
		const body = data.body

		switch (data.type) {
			case "move":
				ws.pos = body.pos
				var new_data = {
					type: "move",
					body: {
						id: ws.id,
						pos: ws.pos
					}
				}
				broadcast(Buffer.from(JSON.stringify(new_data)), ws)
				break
		}
	});


	ws.on('close', () => {
		console.log('Um cliente desconectou.');
		const message = {
			type: "disconnected",
			body: {
				id: ws.id
			}
		}
		broadcast(Buffer.from(JSON.stringify(message)),ws)
		clients.delete(ws);
	});
});
function init_player(ws) {
	clients.add(ws);
	ws.id = clientCounter
	clientCounter++
	console.log('Um novo cliente se conectou: ', ws.id);
	ws.pos = { x: 300, y: 200 }
	let playerlist = []

	clients.forEach(client => {
		if (client != ws) {
			playerlist.push({
				id: client.id,
				pos: client.pos
			})
		}
	})
	ws.send(JSON.stringify({
		type: "init",
		body: {
			id: ws.id,
			pos: ws.pos,
			playerlist
		}
	}))
}
function broadcast(message, sender) {
	for (const client of clients) {
		if (client !== sender && client.readyState === client.OPEN) {
			client.send(message);
		}
	}
}

console.log('Servidor WebSocket está rodando na porta 8080.');
