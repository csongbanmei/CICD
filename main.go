package main

import (
	"fmt"
	"net/http"
)

func main() {
	r := SetupRouter()
	fmt.Println("🚀 Server running at http://localhost:8080")
	http.ListenAndServe(":8081", r)
}
