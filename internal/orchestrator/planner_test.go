package orchestrator

import (
	"context"
	"testing"

	"github.com/carlosmaranje/goclaw/internal/agent"
	"github.com/carlosmaranje/goclaw/internal/llm"
)

type mockLLM struct {
	response string
}

func (m *mockLLM) Complete(ctx context.Context, req llm.CompletionRequest) (string, error) {
	return m.response, nil
}

func TestPlannerRun_NonJSONResponseTreatedAsFinalAnswer(t *testing.T) {
	mock := &mockLLM{response: "Nice to meet you, Carlos!"}
	a := &agent.Agent{
		Name:         "test-orchestrator",
		Role:         "orchestrator",
		Model:        "gemma",
		LLM:          mock,
		SystemPrompt: "You are the orchestrator.",
	}
	reg := agent.NewRegistry()
	p := NewPlanner(a, reg)
	d := NewDispatcher(reg, nil, p)

	result, err := p.Run(context.Background(), "my name is Carlos", nil, d)
	if err != nil {
		t.Fatalf("expected non-JSON reply to be treated as final answer, got error: %v", err)
	}
	if result != "Nice to meet you, Carlos!" {
		t.Errorf("expected raw text returned as final answer, got %q", result)
	}
}

func TestPlannerRun_JSONWithPreamble(t *testing.T) {
	mock := &mockLLM{response: `Sure! Here is my plan: {"action":"finish","final":"hello there"}`}
	a := &agent.Agent{
		Name:         "test-orchestrator",
		Role:         "orchestrator",
		Model:        "gemma",
		LLM:          mock,
		SystemPrompt: "You are the orchestrator.",
	}
	reg := agent.NewRegistry()
	p := NewPlanner(a, reg)
	d := NewDispatcher(reg, nil, p)

	result, err := p.Run(context.Background(), "greet me", nil, d)
	if err != nil {
		t.Fatalf("expected JSON with preamble to parse, got error: %v", err)
	}
	if result != "hello there" {
		t.Errorf("expected %q, got %q", "hello there", result)
	}
}
