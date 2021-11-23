package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/websocket"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

var level = 20.0

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
	broadcast()

	defer c.Close()
	for {
		_, message, err := c.ReadMessage()
		if err != nil {
			break
		}
		level, err = strconv.ParseFloat(string(message), 64)
		if err != nil {
			fmt.Println(err)
		}
		broadcast()
	}
}

func broadcast() {
	data := fmt.Sprintf("%f", level)
	for c := range clients {
		err := c.WriteMessage(1, []byte(data))

		if err != nil {
			delete(clients, c)
		}
	}
}

func handle_input() {
	for {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("input: ")
		text, err := reader.ReadString('\n')
		if err != nil {
			continue
		}
		level, err = strconv.ParseFloat(string(text[:len(text)-1]), 64)
		if level > 100 || level < 0 {
			continue
		}
		if err != nil {
			continue
		}
		broadcast()
	}
}

func main() {
	go handle_input()
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
