package llm

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestOpenAICompatClient_JSONFlag(t *testing.T) {
	var capturedBody []byte
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var err error
		capturedBody, err = json.Marshal(map[string]any{"choices": []any{map[string]any{"message": map[string]any{"content": "ok"}}}})
		if err != nil {
			t.Fatal(err)
		}
		
		// Actually capture what was SENT to us
		decoder := json.NewDecoder(r.Body)
		var req map[string]any
		if err := decoder.Decode(&req); err != nil {
			t.Fatal(err)
		}
		capturedBody, _ = json.Marshal(req)

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"choices":[{"message":{"content":"response"}}]}`))
	}))
	defer server.Close()

	client := NewOpenAICompatClient(ProviderConfig{
		Provider: "openai",
		BaseURL:  server.URL,
		APIKey:   "test",
	})

	_, err := client.Complete(context.Background(), CompletionRequest{
		Model:    "test-model",
		Messages: []Message{{Role: "user", Content: "hi"}},
		JSON:     true,
	})
	if err != nil {
		t.Fatalf("Complete failed: %v", err)
	}

	var req map[string]any
	if err := json.Unmarshal(capturedBody, &req); err != nil {
		t.Fatalf("failed to unmarshal captured body: %v", err)
	}

	format, ok := req["response_format"].(map[string]any)
	if !ok {
		t.Fatalf("response_format missing or invalid: %v", req)
	}
	if format["type"] != "json_object" {
		t.Errorf("expected type=json_object, got %v", format["type"])
	}
}
