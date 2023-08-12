package models

type Game struct {
	ID       int    `json:"id"`
	Title    string `json:"title"`
	Platform string `json:"platform"`
	Genre    string `json:"genre"`
}
