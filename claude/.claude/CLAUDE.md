# Claude Code Global Instructions

## Central Knowledge Base

Always reference the development prompts folder for established patterns, lessons, and agent prompts:

**Location**: `/Users/naidooone/Developer/claude/prompts/`

**Version**: v2.0 (agentic_prompt_pack_v1.0) - Updated 2026-01-16

### Available Subagents

| Agent | When to Use | Prompt File |
|-------|-------------|-------------|
| `solution-designer` | Starting a new project - clarify scope before detailed specs | `agents/solution-designer.md` |
| `business-analyst` | Create/update BA artifacts (spec, tasklist, rules, gates) | `agents/business-analyst.md` |
| `qa-reviewer` | After code changes - quick governance check (TDD, hexagonal, gates) | `agents/qa-reviewer.md` |
| `code-review-agent` | Deep task completion verification - interpret specs/stories/tests, produce bug docs and improvement recommendations | `agents/code-review-agent.md` |
| `lessons-advisor` | Before decisions - consult past lessons and operationalize into gates | `agents/lessons-advisor.md` |
| `persona-evaluator` | Evaluate products through composite persona scenarios - generate user stories, acceptance criteria, QA tests, and prioritized backlogs | `agents/persona-evaluator.md` |

**Agent Prompt Files Location**: `/Users/naidooone/Developer/claude/prompts/agents/`

To invoke a subagent, use the Task tool with `subagent_type` matching the agent name (e.g., `subagent_type: "lessons-advisor"`).

### Key Files to Consult (v2.0)

| File | Purpose |
|------|---------|
| `devlessons.md` | Hard-won lessons from past projects - consult before making architectural decisions |
| `system-prompts-v2/coding_system_prompt_v4_0_hex_tdd_8k.md` | Coding standards: TDD, hexagonal architecture, atomic components |
| `playbooks-v2/coding_playbook_v4_0.md` | How to implement: task loop, drift governance, component structure |
| `system-prompts-v2/ba_system_prompt_v4_0_8k.md` | BA workflow: spec creation, tasklist management, EV/D governance |
| `playbooks-v2/ba_playbook_v4_0.md` | BA practical guide: artifact creation, drift handling, escalation |
| `system-prompts-v2/solution_designer_system_prompt_v2_0.md` | Solution design patterns, handoff envelope format |
| `playbooks-v2/solution_designer_playbook_v2_0.md` | Solution design: scoping, architecture decisions, tradeoffs |
| `system-prompts-v2/persona_evaluator_system_prompt_v2_0.md` | Persona-based product evaluation (domain-neutral) |
| `playbooks-v2/persona_evaluator_playbook_v2_0.md` | Persona evaluator usage: inputs, iteration patterns, prioritization |
| `system-prompts-v2/qa_system_prompt_v2_0.md` | QA review: quick governance, TDD, hexagonal compliance |
| `system-prompts-v2/code_review_system_prompt_v1_0.md` | Deep code review: task completion verification, bug docs, improvements |
| `playbooks-v2/code_review_playbook_v1_0.md` | Code review practical guide: verification process, templates, patterns |
| `system-prompts-v2/lessons_system_prompt_v2_0.md` | Lessons operationalization into gates and checklists |
| `docs-v2/agentic_development_playbook_v1_0.md` | **Lifecycle playbook**: Persona -> Solution -> BA -> Coding -> QA -> Lessons |

### Agent Lifecycle (v2.0)

```
Persona Evaluator -> Solution Designer -> BA -> Coding -> QA Review -> Code Review -> Lessons
        |                   |              |      |           |            |            |
   scenarios          architecture    artifacts  code    governance   deep verify   improve
   + stories          + handoff       + tasks   + tests   + quick     + completion   gates
                      envelope                           pass/fail   + bug docs
```

**QA Reviewer vs Code Review Agent:**
- `qa-reviewer`: Quick governance check (5-10 min) - TDD, hexagonal, gates compliance
- `code-review-agent`: Deep verification (60 min) - actual task completion, spec fidelity, bug docs

### Handoff Contracts

Agents communicate via compact "Handoff Envelopes" (<=250 lines) containing:
- project_slug, problem_statement
- stakeholders, in_scope/out_of_scope
- key_flows, domain_objects, risks
- assumptions, open_questions
- recommended_next_agent

### Mandatory Lesson Consultation

**CRITICAL**: Lessons must be consulted at these points:

#### Before Starting ANY New Project
1. Run `lessons-advisor` agent with project context/tech stack
2. Create `{project}_lessons_applied.md` documenting applicable lessons
3. Add lesson-derived checks to `{project}_quality_gates.md`
4. Create `CHECKLIST.md` with pre-flight verification

#### After Context Compress or Session Restart
1. Check for existing `{project}_lessons_applied.md` in project directory
2. If found, READ IT FIRST to restore lesson context
3. If not found but project exists, run lessons-advisor before continuing

#### After Project Completion
1. Run lessons-advisor to capture new lessons learned
2. Append to `devlessons.md` with evidence from project
3. Update topic index if new categories emerge

**The `{project}_lessons_applied.md` file is the key artifact that survives context compresses.**

### When to Reference

1. **Starting a new project** - Read `devlessons.md` for framework selection, deployment, and architecture lessons
2. **Before coding** - Check coding agent prompt AND playbook for TDD, hexagonal architecture, and quality gate requirements
3. **During implementation** - Follow coding agent playbook for task loop discipline, drift governance, and component structure
4. **Planning features** - Consult BA agent prompt + playbook for spec/tasklist structure
5. **Making architectural decisions** - Review past decisions and their outcomes in `devlessons.md`
6. **Evaluating product from user perspective** - Use persona evaluator to generate scenarios, user stories, and QA test packs
7. **After code changes (quick check)** - Run QA reviewer to verify governance compliance
8. **After task completion (deep verification)** - Run code-review-agent to verify actual task completion against specs/stories/tests
9. **After recurring issues** - Consult lessons-advisor to operationalize fixes into gates

### Prime Directive (Non-Negotiable)

> **Every change must be task-scoped, atomic, deterministic, hexagonal, and evidenced.**

This is the foundational rule. All other instructions derive from it.

### Standing Instructions

- Follow hexagonal architecture: core depends only on ports; adapters depend on core
- Follow the atomic component pattern from the coding agent prompt + playbook
- Use strict task loop discipline: one task at a time, TDD, evidence artifacts
- Run quality gates after every task - must produce machine-readable artifacts:
  - `artifacts/quality_gates_run.json`
  - `artifacts/test_report.json`
  - `artifacts/test_failures.json`
- Use drift detection - halt and create EV entries when scope changes
- Keep domain rules in YAML files, not hardcoded (rules-first execution)
- Maintain component contracts and manifests
- Pin dependencies appropriately based on past version issues
- For Fly.io deployments, review the deployment lessons before configuring
- EV and D logs are append-only - never rewrite history

---

## Non-Negotiable Testing Requirements

Testing requirements vary by layer. These are **hard requirements**, not suggestions.

### Layer-Specific Testing (Mandatory)

| Layer | Test Type | Coverage Requirement | Tool |
|-------|-----------|---------------------|------|
| **Domain (entities, policies)** | Unit tests | 100% of public functions | pytest |
| **Services (use cases)** | Integration tests with fakes | All happy paths + error paths | pytest |
| **Adapters (I/O)** | Contract tests | Verify port protocol compliance | pytest |
| **API Endpoints** | HTTP integration tests | All routes, all status codes | pytest + httpx |
| **UI Components** | E2E tests | Critical user flows | Playwright |

### Test Evidence Requirements

A task is **NOT COMPLETE** unless:

```
[ ] artifacts/test_report.json exists
[ ] artifacts/test_failures.json exists (even if empty)
[ ] All tests relevant to the task pass
[ ] New code has corresponding new tests
```

### E2E Test Mandates (Lessons 44, 53-57)

- **All interactive elements MUST have `data-testid` attributes**
- Selectors: Prefer `data-testid` over CSS classes or text content
- Authentication: Create reusable auth helpers, not copy-paste login sequences
- Port conflicts: Check ports before starting test servers
- Database: Test seed scripts must match actual schema

### Contract Testing for APIs (Lessons 108, 109, 113)

**Every API endpoint MUST have:**

1. **Pydantic response model** - defines the contract
2. **Integration test validating ALL fields** - catches field mismatches
3. **TypeScript types generated from Pydantic** - never hand-write frontend types

```python
# REQUIRED pattern for API responses
def test_projects_response_has_all_required_fields():
    response = client.get("/api/projects")
    for project in response.json():
        ProjectResponse(**project)  # Validates contract
```

### Filter Parameter Testing (Lesson 109)

**Every filter/query parameter MUST have a test proving it works:**

```python
def test_filter_actually_filters():
    # Create data spanning the filter range
    # Apply filter
    # Assert ONLY filtered data returned
```

---

## Atomic Component Enforcement (Strict)

### Required Files (No Exceptions)

Every component in `src/components/<ComponentName>/` MUST have:

| File | Purpose | Created When |
|------|---------|--------------|
| `component.py` | Pure entry point with `run()` | Before implementation |
| `models.py` | Frozen dataclass Input/Output | Before implementation |
| `ports.py` | Protocol interfaces | Before implementation |
| `contract.md` | Human-readable specification | Before implementation |
| `__init__.py` | Re-exports public API | Before implementation |

**Enforcement:** Create ALL stubs BEFORE writing implementation code.

### contract.md Template (Required Sections)

```markdown
# ComponentName Contract

## Purpose
[One sentence describing what this component does]

## Input
[Frozen dataclass with all inputs]

## Output
[Frozen dataclass with all outputs]

## Ports (Dependencies)
[Protocol interfaces required]

## Error Cases
[What can fail and how it's signaled]

## Evidence
[How to verify this component works]
```

### Manifest Synchronization

- Manifest entry MUST exist before implementation starts (status: "in_progress")
- Manifest entry MUST be updated when complete (status: "complete")
- G3_manifest_validation MUST pass - no phantom components

---

## Determinism Requirements (Lessons 27, 107)

### Forbidden in Core/Domain Code

| Forbidden | Reason | Alternative |
|-----------|--------|-------------|
| `datetime.now()` | Non-deterministic | Inject `TimePort` |
| `datetime.utcnow()` | Deprecated in Python 3.12 | Use `datetime.now(UTC)` via `TimePort` |
| `uuid4()` | Non-deterministic | Inject `UUIDPort` |
| `random.*` | Non-deterministic | Inject `RandomPort` |
| Module-level mutable state | Hidden coupling | Inject `StoragePort` |

### Required Port Pattern

```python
# ports.py
from typing import Protocol
from datetime import datetime

class TimePort(Protocol):
    def now(self) -> datetime: ...

class UUIDPort(Protocol):
    def generate(self) -> str: ...
```

```python
# component.py
class MyService:
    def __init__(self, time_port: TimePort, uuid_port: UUIDPort):
        self._time = time_port
        self._uuid = uuid_port

    def create_event(self) -> Event:
        return Event(
            id=self._uuid.generate(),
            timestamp=self._time.now()
        )
```

### Detection Command

```bash
grep -r "datetime\.now\|datetime\.utcnow\|uuid4" src/*/core/ --include="*.py" | grep -v import
# Count MUST be zero
```

---

## API Contract Requirements (Lessons 108-113)

### Response Schema Validation

Every API callback/endpoint MUST:

1. Define explicit Pydantic response model
2. Have integration test validating ALL fields
3. Log observable data flow (not silent defaults)

### Field Naming Consistency

| Backend Returns | Frontend Expects | Status |
|-----------------|------------------|--------|
| `updated` | `updated` | ✓ Match |
| `last_updated` | `updated` | ✗ BROKEN |

**Rule:** Define field names in Pydantic model FIRST, then implement.

### Callback Type Safety (Lesson 109)

```python
# REQUIRED: Protocol-based callback typing
class DriftCallback(Protocol):
    def __call__(self, project_id: str | None, days: int) -> list[dict]: ...

def set_drift_callback(self, callback: DriftCallback) -> None:
    self._drift_callback = callback
```

Run `mypy --strict` to catch signature mismatches.

---

## Technology Quick Reference

### Databricks (Lessons 88-95)

| Issue | Solution |
|-------|----------|
| DBFS public access disabled | Use Unity Catalog Volumes |
| INT vs BIGINT mismatch | Check Spark SQL introspection types |
| Decimal precision drift | Match config and table schema exactly |
| Null in arrays | Use `filter()` expression |
| Widget defaults | Must match actual file names in Volume |
| Serverless-only workspace | Check compute capabilities first |

### MCP Server Development (Lessons 19-24, 104)

| Pattern | Requirement |
|---------|-------------|
| Token budget | Enforce max response size (e.g., 4000 tokens) |
| Response time | Target <2s for interactive tools |
| Fallback | Implement provider fallback chain |
| Atomic adapters | One adapter per external service |
| Config location | Use `~/.config/` or XDG paths |

### React/Next.js (Lessons 18, 38-43, 59, 81, 85)

| Issue | Solution |
|-------|----------|
| Radix Select empty value | Cannot use empty string as value |
| TipTap server rendering | Install `@tiptap/html` separately |
| shadcn/ui deps | Add incrementally, check peer deps |
| `"use client"` | Affects ALL exports in file |
| Static page stale data | Use `export const dynamic = 'force-dynamic'` |
| setState in useEffect | Use `useMemo` for derived state instead |

### Fly.io Deployment (Lesson Section 3)

Pre-deploy checklist:
```
[ ] Volume created BEFORE first deploy
[ ] PYTHONPATH set in fly.toml AND Dockerfile
[ ] Health check endpoint returns 200
[ ] Memory >= 512mb for Python apps
[ ] README.md exists if referenced in pyproject.toml
```

---

## Dependency Pinning Strategy (Lessons 2, 23)

### Pin Everything That Can Break

```toml
# pyproject.toml - GOOD
dependencies = [
    "fastapi>=0.109.0,<0.115.0",   # Pin major+minor range
    "websockets>=12.0,<14.0",      # Known breaking change at 14
    "pydantic>=2.0.0,<3.0.0",      # Pin major version
]

# BAD - too loose
dependencies = ["fastapi>=0.100.0"]
```

### Document WHY Each Pin Exists

```toml
# websockets<14 - Flet 0.28 incompatible with websockets 14+ (see devlessons #2)
```

### Lock File Requirement

After confirming working state:
```bash
pip freeze > requirements.lock
# OR use uv/poetry lockfile
```

---

## Quick Reference Links

### Top 30 Rules Summary

See `devlessons.md` lines 1209-1241 for the curated "Top 30 Rules for Future Projects" derived from 113 lessons.

### Lesson Topic Index

| Topic | Lessons |
|-------|---------|
| Risk Engine/Finance | 96, 97, 99 |
| Databricks | 88-95 |
| MCP/Claude | 19-24, 30, 104 |
| Testing | 44-62, 76, 78, 82, 97, 99, 108-112 |
| React/Next.js | 18, 38-43, 59, 81, 85 |
| Hexagonal/Architecture | 4, 8-13, 24, 31, 79, 87, 100, 103, 107 |
| API Design | 108, 109, 113 |
| Quality Gates | 5, 36, 51 |

Full index at `devlessons.md` lines 114-143.

## Project Artifact Standards

When working on projects with BA artifacts, look for:
- `{project}_lessons_applied.md` - **READ FIRST** after context compress - applicable lessons from devlessons.md
- `{project}_spec.md` - Requirements and architecture
- `{project}_tasklist.md` - Task tracking (dependency-ordered, 30-120 min tasks)
- `{project}_rules.yaml` - Domain rules
- `{project}_evolution.md` - Drift and scope changes (append-only)
- `{project}_decisions.md` - Architectural decisions (append-only)
- `{project}_quality_gates.md` - Quality requirements + evidence artifact specs
- `{project}_coding_agent_system_prompt.md` - Project-specific coding rules
- `CHECKLIST.md` - Pre-flight verification checklist derived from lessons

## Archive Information

Previous v3_atomic configuration archived at:
`/Users/naidooone/Developer/claude/prompts/archive/v3_atomic_backup_2026-01-16/`

Rollback instructions available at:
`/Users/naidooone/Developer/claude/prompts/ROLLBACK_PROMPT.md`

## Permissions Configuration

Settings file: `~/.claude/settings.local.json`

### Two Permission Layers

1. **Bash Command Permissions** - which shell commands can execute
2. **Directory Access Permissions** - which paths Claude can read/write/create files in

Both must be configured for full access. See devlessons.md #28-29 for details.

### Auto-Allowed Commands (no prompts)
- **Testing**: pytest, npm test, bun test, ruff, mypy
- **Build**: npm run build, bun run build, docker build
- **Git (read)**: git status, git diff, git log, git branch, git fetch
- **Git (write)**: git add, git commit, git checkout, git stash, git pull
- **Package managers**: npm install, pip install, bun install, uv, poetry
- **Utilities**: ls, cat, head, tail, grep, find, curl, tree, mkdir, cp, mv
- **Deployment**: fly deploy, fly logs, docker compose, docker ps

### Directory Access (Write/Edit permissions)
- `~/Developer/**` - Full write/edit access to Developer folder
- `~/Documents/**` - Full write/edit access to Documents folder (legacy)

### Ask-First Commands (prompts before running)
- `git push` - Prompts before pushing to remote
- `npm publish` - Prompts before publishing packages
- `fly deploy --force` - Prompts before force deployments
- `docker push` - Prompts before pushing images
- `docker rm/rmi/stop` - Container destruction operations
- `git rebase` - History rewriting
- `psql/mysql/mongosh/redis-cli` - Database clients

### Denied Commands (never allowed)
- `Read(.env*)` - Prevents reading environment files with secrets
- `rm -rf` - Prevents dangerous recursive deletions
- `sudo rm` - Prevents privileged deletions
- `chmod 777` - Prevents insecure permissions

### Enabled Plugins
- `frontend-design@claude-plugins-official` - Production-grade UI components
- `github@claude-plugins-official` - GitHub integration
- `typescript-lsp@claude-plugins-official` - TypeScript language server
- `rust-analyzer-lsp@claude-plugins-official` - Rust language server

## Startup Screen & Status Command

A startup status screen automatically displays on the first prompt of each Claude Code session, showing:
- MCP server connection and available tools
- Available agents/subagents
- Credential status (API keys in Keychain)
- Service status (Docker, NotebookLM auth)
- Prime directives

### `/status` Command

When the user types `/status` or asks to "show status", run:
```bash
python3 ~/.claude/hooks/startup_check.py --force
```

This displays the full system status screen on demand.

### Startup Hook Configuration

The startup screen is triggered by a `UserPromptSubmit` hook in `~/.claude/settings.local.json`. The screen only shows once per terminal session (tracked via `~/.claude/.current_session`).

## Migrations

### Moving Development Folders

When relocating development projects to a new directory:

1. Run the migration prompt: `migrations/MIGRATE_DEV_FOLDERS.md`
2. Update directory permissions in `~/.claude/settings.local.json`
3. Restart Claude Code session

**Migration Prompt Location**: `/Users/naidooone/Developer/claude/prompts/migrations/MIGRATE_DEV_FOLDERS.md`
