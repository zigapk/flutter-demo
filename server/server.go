package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/websocket"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
} // use default options

var clients = make(map[*websocket.Conn]bool)

func handler(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}

	clients[c] = true
}

func broadcast(message string) {
	for c := range clients {
		err := c.WriteMessage(1, []byte(message))

		if err != nil {
			delete(clients, c)
		}
	}
}

func handle_input() {
	for {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("input: ")
		text, _ := reader.ReadString('\n')
		broadcast(text)
	}
}

func main() {
	go handle_input()
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
