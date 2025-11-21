# workflow-toolkit

Reusable GitHub Actions workflows for issue and PR automation with GitHub Projects V2.

## Features

- **Issue Automation**: Auto-assign, add to project, move bug issues to "In Progress"
- **PR Automation**: Auto-assign, sync labels from linked issue, update project status based on draft state, Gemini review

## Usage

### Issue Automation

```yaml
# .github/workflows/issue-automation.yml
name: Issue Automation

on:
  issues:
    types: [opened, labeled, closed]

jobs:
  automation:
    uses: KubrickCode/workflow-toolkit/.github/workflows/issue-automation.yml@main
    with:
      project-number: "4"
      event-action: ${{ github.event.action }}
      issue-number: ${{ github.event.issue.number }}
      issue-node-id: ${{ github.event.issue.node_id }}
      issue-user-login: ${{ github.event.issue.user.login }}
      label-name: ${{ github.event.label.name || '' }}
      has-bug-label: ${{ contains(github.event.issue.labels.*.name, 'bug') }}
    secrets:
      GH_PAT: ${{ secrets.GH_PAT }}
```

### PR Automation

```yaml
# .github/workflows/pr-automation.yml
name: PR Automation

on:
  pull_request:
    types: [opened, ready_for_review, converted_to_draft]

jobs:
  automation:
    uses: KubrickCode/workflow-toolkit/.github/workflows/pr-automation.yml@main
    with:
      project-number: "4"
      event-action: ${{ github.event.action }}
      pr-number: ${{ github.event.pull_request.number }}
      pr-user-login: ${{ github.event.pull_request.user.login }}
      pr-is-draft: ${{ github.event.pull_request.draft }}
    secrets:
      GH_PAT: ${{ secrets.GH_PAT }}
```

## Inputs

### Issue Automation

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `project-number` | Yes | - | GitHub Project number |
| `event-action` | Yes | - | The action that triggered the workflow |
| `issue-number` | Yes | - | Issue number |
| `issue-node-id` | Yes | - | Issue node ID for GraphQL |
| `issue-user-login` | Yes | - | Issue creator login |
| `label-name` | No | `""` | Label name (for labeled event) |
| `has-bug-label` | No | `false` | Whether issue has bug label on creation |
| `status-backlog` | No | `"Backlog"` | Status name for Backlog |
| `status-progress` | No | `"Progress"` | Status name for In Progress |

### PR Automation

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `project-number` | Yes | - | GitHub Project number |
| `event-action` | Yes | - | The action that triggered the workflow |
| `pr-number` | Yes | - | PR number |
| `pr-user-login` | Yes | - | PR creator login |
| `pr-is-draft` | Yes | - | Whether PR is draft |
| `status-progress` | No | `"Progress"` | Status name for In Progress |
| `status-review` | No | `"Review"` | Status name for Review |
| `enable-gemini-review` | No | `true` | Enable /gemini review comment |

## Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `GH_PAT` | Yes | GitHub Personal Access Token with `project` scope |

## License

MIT
