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
		fmt.Fprintln(w, "你好，我是开发者-小陈")
	}).Methods("GET")
	return r
}
