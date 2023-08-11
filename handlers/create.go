package handlers

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/caribeh/apijogos/models"
)

func Create(w http.ResponseWriter, r *http.Request) {
	var game models.Game

	err := json.NewDecoder(r.Body).Decode(&game)
	if err != nil {
		log.Printf("Erro no decode do json: %v", err)
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

}
