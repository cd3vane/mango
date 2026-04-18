package llm

import "context"

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type CompletionRequest struct {
	Model     string
	Messages  []Message
	MaxTokens int
	JSON      bool // If true, request JSON response format from the provider
}

type Client interface {
	Complete(ctx context.Context, req CompletionRequest) (string, error)
}
