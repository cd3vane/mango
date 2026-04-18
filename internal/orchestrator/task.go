package orchestrator

import (
	"time"

	"github.com/carlosmaranje/mango/internal/llm"
)

const (
	StatusPending = "pending"
	StatusRunning = "running"
	StatusDone    = "done"
	StatusFailed  = "failed"
)

type Task struct {
	ID        string        `json:"id"`
	Goal      string        `json:"goal"`
	AgentName string        `json:"agent_name,omitempty"`
	Status    string        `json:"status"`
	Result    string        `json:"result,omitempty"`
	Error     string        `json:"error,omitempty"`
	CreatedAt time.Time     `json:"created_at"`
	UpdatedAt time.Time     `json:"updated_at"`
	History   []llm.Message `json:"-"`
}
