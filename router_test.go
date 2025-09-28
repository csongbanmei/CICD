package main

import (
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHelloRoute(t *testing.T) {
	router := SetupRouter()

	req, _ := http.NewRequest("GET", "/hello", nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	if resp.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", resp.Code)
	}

	body, _ := ioutil.ReadAll(resp.Body)
	if !strings.Contains(string(body), "Hello, Jenkins CI/CD from Test-CICD!") {
		t.Errorf("Expected response to contain 'Hello, Jenkins CI/CD from Test-CICD!', got %s", string(body))
	}
}
