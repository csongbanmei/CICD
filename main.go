package main

import (
	"net/http"
)

func main() {
	r := SetupRouter()
	http.ListenAndServe(":8080", r)
}
