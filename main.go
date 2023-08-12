package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/caribeh/apijogos/models"
	"github.com/gorilla/mux"
)

var games []models.Game
var currentID int

func main() {

	err := ReadGamesFromFile("games.json")
	if err != nil {
		log.Fatal(err)
	}

	router := mux.NewRouter()

	router.HandleFunc("/games", getGames).Methods("GET")
	router.HandleFunc("/games/{id}", getGame).Methods("GET")
	router.HandleFunc("/games", addGame).Methods("POST")
	router.HandleFunc("/games/{id}", updateGame).Methods("PUT")
	router.HandleFunc("/games/{id}", deleteGame).Methods("DELETE")

	fmt.Println("Server started at :8080")
	log.Fatal(http.ListenAndServe(":8080", router))
}

func getGames(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(games)
}

func getGame(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)
	gameID, err := strconv.Atoi(params["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for _, game := range games {
		if game.ID == gameID {
			json.NewEncoder(w).Encode(game)
			return
		}
	}

	http.NotFound(w, r)
}

func addGame(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var newGame models.Game
	err := json.NewDecoder(r.Body).Decode(&newGame)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	newGame.ID = currentID
	currentID++
	games = append(games, newGame)

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(newGame)
}

func updateGame(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)
	gameID, err := strconv.Atoi(params["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var updatedGame models.Game
	err = json.NewDecoder(r.Body).Decode(&updatedGame)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for i, game := range games {
		if game.ID == gameID {
			games[i] = updatedGame
			json.NewEncoder(w).Encode(updatedGame)
			return
		}
	}

	http.NotFound(w, r)
}

func deleteGame(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)
	gameID, err := strconv.Atoi(params["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for i, game := range games {
		if game.ID == gameID {
			games = append(games[:i], games[i+1:]...)
			w.WriteHeader(http.StatusNoContent)
			return
		}
	}

	http.NotFound(w, r)
}

func ReadGamesFromFile(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	var newGames []models.Game
	err = json.NewDecoder(file).Decode(&newGames)
	if err != nil {
		return err
	}

	lastID := 0
	for _, game := range games {
		if game.ID > lastID {
			lastID = game.ID
		}
	}

	for i := range newGames {
		lastID++
		newGames[i].ID = lastID
		games = append(games, newGames[i])
	}

	return nil
}
