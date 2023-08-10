package models

type Game struct {
	Name     string `json:"name"`
	Platform string `json:"platform"`
	Gender   string `json:"gender"`
}
