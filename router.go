package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
)

// SetupRouter 定义路由
func SetupRouter() *mux.Router {
	r := mux.NewRouter()
	// /hello 路由
	r.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "hello,my name is chen")
	}).Methods("GET")
	return r
}
