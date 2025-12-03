# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**CRITICAL**

- Always update CLAUDE.md and README.md When changing a feature that requires major work or essential changes to the content of the document. Ignore minor changes.
- Never create branches or make commits autonomously - always ask the user to do it manually
- ⚠️ MANDATORY SKILL LOADING - BEFORE editing files, READ relevant skills:
  - .ts → typescript
  - .tsx → typescript + react
  - .go → golang
  - .test.ts, .spec.ts → typescript-test + typescript
  - .test.go, \_test.go → go-test + golang
  - .graphql, resolvers, schema → graphql + typescript
  - package.json, go.mod → dependency-management
  - Path-based (add as needed): apps/web/** → nextjs, apps/api/** → nestjs
  - Skills path: .claude/skills/{name}/SKILL.md
  - 📚 REQUIRED: Display loaded skills at response END: `📚 Skills loaded: {skill1}, {skill2}, ...`
- If Claude repeats the same mistake, add an explicit ban to CLAUDE.md (Failure-Driven Documentation)
- Follow project language conventions for ALL generated content (comments, error messages, logs, test descriptions, docs)
  - Check existing codebase to detect project language (Korean/English/etc.)
  - Do NOT mix languages based on conversation language - always follow project convention
  - Example: English project → `describe("User authentication")`, NOT `describe("사용자 인증")`
- Respect workspace tooling conventions
  - Always use workspace's package manager (detect from lock files: pnpm-lock.yaml → pnpm, yarn.lock → yarn, package-lock.json → npm)
  - Prefer just commands when task exists in justfile or adding recurring tasks
  - Direct command execution acceptable for one-off operations
- Dependencies: exact versions only (`package@1.2.3`), forbid `^`, `~`, `latest`, ranges
  - New installs: check latest stable version first, then pin it (e.g., `pnpm add --save-exact package@1.2.3`)
  - CI must use frozen mode (`npm ci`, `pnpm install --frozen-lockfile`)
- Clean up background processes: always kill dev servers, watchers, etc. after use (prevent port conflicts)

**IMPORTANT**

- Avoid unfounded assumptions - verify critical details
  - Don't guess file paths - use Glob/Grep to find them
  - Don't guess API contracts or function signatures - read the actual code
  - Reasonable inference based on patterns is OK
  - When truly uncertain about important decisions, ask the user
- Always gather context before starting work
  - Read related files first (don't work blind)
  - Check existing patterns in codebase
  - Review project conventions (naming, structure, etc.)
- Always assess issue size and scope accurately - avoid over-engineering simple tasks
  - Apply to both implementation and documentation
  - Verbose documentation causes review burden for humans

## Project Overview

Reusable GitHub Actions workflows for issue and PR automation with GitHub Projects V2. This toolkit provides:
- **Issue Automation**: Auto-assign, add to project, move bug issues to "Ready" status
- **PR Automation**: Auto-assign, sync labels from linked issue, update project status based on draft state, Gemini review integration

## Repository Structure

```
.github/
├── workflows/
│   ├── issue-automation.yml    # Reusable workflow for issue events
│   └── pr-automation.yml       # Reusable workflow for PR events
└── actions/
    └── project-status/         # Composite action for GitHub Projects V2
        ├── action.yml          # Main action definition
        └── scripts/            # Shell scripts for GraphQL operations
            ├── get-project-data.sh
            ├── get-item-status.sh
            ├── get-linked-issue.sh
            ├── find-project-item.sh
            └── update-item-status.sh
```

## Architecture

### Workflow Design
- **workflow_call** trigger: Both workflows are reusable, called from consumer repos
- Workflows use `actions/checkout` to fetch this repo, then invoke local composite action
- GraphQL operations handled via shell scripts in `project-status/scripts/`

### Key Patterns
- Issue/PR node IDs passed for GraphQL mutations
- Status field management via `project-status` composite action (add-to-project, update-status)
- Linked issue detection for PR → Issue status sync

## Development Commands

```bash
# Format check
npx prettier --check .

# Format fix
npx prettier --write .

# Pre-commit hooks via husky
npm run prepare
```

## Code Style

- Prettier config: `.prettierrc` (double quotes, 100 width, ES5 trailing commas)
- Shell scripts: Use `set -e` for error handling, output key=value for GitHub Actions outputs

## Slash Commands

Key workflow commands available:
- `/workflow:analyze [task]` - Generate analysis document with solution approaches
- `/workflow:plan` - Create implementation plan with commit-level tasks
- `/workflow:execute` - Execute commits from plan
- `/workflow:validate` - Validate implementation with tests
- `/commit` - Generate Conventional Commits messages (Korean/English)
- `/review-pr [URL]` - Review GitHub PR
- `/handover` - Generate conversation summary for AI handoff
