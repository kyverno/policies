# PSA release issues

The `PSA release issues` workflow (`.github/workflows/psa-release-issues.yaml`) opens a GitHub issue for each
Kubernetes Pod Security Admission (PSA) minor release whose upstream changes the policies in `pod-security-vpol/`
may need. The policies follow the newest PSA version, so each issue tells maintainers what to update to keep them
there. The workflow never changes a policy and never opens a pull request.

| File | Purpose |
|---|---|
| `psa-release-issues.py` | Detects releases, analyzes them, maps them to policies, and opens the issues |
| `config.yaml` | The baseline release (`since`) and the map from PSA check IDs to policies (`checks`) |
| `test-psa-release-issues.py` | Offline tests |

The release detection and analysis come from the same workflow in kyverno/kyverno (`scripts/psa-release-issues.py`),
which opens `psa-cel-update` issues for the `kyverno-policies` chart. They're ported from commit
[`d2289aae`](https://github.com/kyverno/kyverno/blob/d2289aae73dad7ce884d4fa6fa343bf5e34e39ad/scripts/psa-release-issues.py)
(kyverno/kyverno#18235). When you fix the detection or the analysis in one repository, make the same fix in the other.
To see what changed in kyverno/kyverno since then, run:

```sh
gh api 'repos/kyverno/kyverno/commits?path=scripts/psa-release-issues.py' -q '.[] | .sha + " " + (.commit.message | split("\n")[0])'
```

## How it works

PSA is developed in `kubernetes/kubernetes` under `staging/src/k8s.io/pod-security-admission`. The Kubernetes
publishing bot mirrors that directory to the read-only `kubernetes/pod-security-admission` repository, and tags
each release there as `kubernetes-1.<minor>.<patch>` and `v0.<minor>.<patch>` on the same commit. The script
fetches the `kubernetes-1.*` tags into a blobless clone, and diffs two tags to get the change.

GitHub can't start a workflow from a release in another owner's repository, so the workflow runs quarterly, on
January 1, April 1, July 1, and October 1. Kubernetes ships a minor release about every 4 months, so an issue opens
1 to 13 weeks after the release. GitHub can delay scheduled runs, and turns them off in a public repository after
60 days without activity. Run the workflow manually to check sooner.

Only minor releases are checked, and each one is compared with the previous minor: `v1.38.0` with `v1.37.0`.
Patches and pre-releases, such as `v1.37.2` or `v1.38.0-rc.0`, are skipped. A PSA fix that a patch backports also
lands in the next minor, so the minor comparison includes it.

Every change in `policy/`, `api/`, or `test/` needs an issue, except fixtures that a new
`test/testdata/<level>/v1.<N>/` directory copies unchanged from `v1.<N - 1>`. Only a release with no other change
is reported as **no action needed**.

The script maps each changed `policy/check_*.go` file or fixture to its check ID, and through `checks` to a policy
in `pod-security-vpol/<level>/<policy>/<policy>.yaml`. It finds the policy's test folders: `.kyverno-test`,
`.kyverno-test-controllers`, `.kyverno-test-exceptions`, `.chainsaw-test`, and any other `.kyverno-test*` or
`.chainsaw-test*` folder, such as `.kyverno-test-regressions`. From the Go diff, it reads new
`MajorMinorVersion(1, N)` version gates and changed string values, and checks whether the policy already has the
values. These signals are string matches, not a semantic analysis, so read the comparison before you decide. The
issue doesn't include the diff: it links the comparison, and each changed Go file links to its section of it.

The policies have no version gates, because they follow only the newest PSA version. A new upstream gate means
that the gated behavior must apply to every Pod:

- When the gate comes with added or removed values, and the policy already has every added value and none of the
  removed ones, the issue asks a person to confirm that the policy already handles the change.
- When the gate comes with no value change, it's a logic change that the script can't check, so the issue asks for
  an update.

### Issue kinds

| Kind | Title ends with | `needs-manual-review` | When |
|---|---|---|---|
| Update required | `update the pod-security-vpol policies` | No | A policy lacks an upstream value, keeps a removed value, has a new version gate without a value change, or only the upstream fixtures for its check changed |
| Confirmation required | `confirm the pod-security-vpol policies need no change` | No | Only test code changed, or the policies already seem to handle a check change |
| Manual review required | `review the pod-security-vpol policies (manual review)` | Yes | A change can't be mapped or analyzed with confidence |

These changes need manual review, and appear under **Not mapped**:

- Shared `policy/` code, such as `helpers.go`, or base fixtures, which can affect every check.
- A change in `api/`.
- An upstream check ID that isn't in `checks`, or an entry in `checks` that upstream no longer declares.
- A check file that was renamed or split, a removed version gate, or a mapped policy without a policy file.
- A check code change in which the script finds no version gate or value change.

### Issue structure

Every issue has the same sections: **Summary**, **Release details**, **What changed**, **Policy impact**,
**Required actions**, **Validation**, and **Upstream evidence**. **Release details** links the `psa-cel-update`
issues in kyverno/kyverno, whose chart CEL can serve as a reference. An update's checklist keeps the `exceptions.*`
checks that the policy uses and the controller match rules, updates the tests, and refreshes the Artifact Hub digests. Every issue ends
with moving `since`.

Upstream text can't ping anyone or link elsewhere: commit subjects are in code spans, the issue links commits
rather than pull requests, and no upstream code goes into the issue body.

### Release tracking and duplicates

The script stores no state. Each run checks every minor release after `since`, so a failed or skipped run misses
nothing.

Each issue ends with a hidden marker, such as `<!-- psa-vpol-update: kubernetes-1.38.0 -->`, and the script skips
each release whose marker is in an open or closed issue with the `psa-vpol-update` label. A release's tags don't
change, so its issue is never edited after it opens. For concurrent runs:

1. The workflow runs one `Check releases` job at a time per repository, for every ref.
1. The script reads the issues again right before it creates one.
1. After creating one, it reads them once more, and closes its own issue as a duplicate if another run opened one
   first.

Don't remove the `psa-vpol-update` label from these issues, and don't edit the marker.

## Enable the scheduled runs

Scheduled runs are off until a repository admin adds the repository variable `PSA_VPOL_UPDATE_ISSUES` with the
value `true`, under **Settings** > **Secrets and variables** > **Actions** > **Variables**. Set it to `false` to
pause them.

The workflow uses the default `GITHUB_TOKEN` with `contents: read` and `issues: write`, and no secret. It creates
the `psa-vpol-update` and `needs-manual-review` labels if they don't exist. When a scheduled run fails, the
`sync-issue` job opens a `workflow-failure` issue with the failing log, and closes it when a later scheduled run
succeeds. It calls the `failure-issue` action from kyverno/kyverno, pinned to a commit.

The repository must have Issues turned on. Every run, including a dry run, checks this first and fails with a clear
message when they're off. Forks have Issues off by default.

## Run the workflow manually

1. Go to **Actions** > **PSA release issues** > **Run workflow**.
1. Set the inputs:

   | Input | Default | Description |
   |---|---|---|
   | `dry-run` | `true` | Writes the issues to the job summary and an artifact instead of opening them |
   | `tag` | none | Checks only this minor release tag, such as `kubernetes-1.38.0` |
   | `since` | none | Overrides the baseline tag, a `kubernetes-1.<minor>.0` tag |
   | `repository` | none | For testing only: reads releases from this PSA fork, such as `https://github.com/OWNER/pod-security-admission` |

1. Click **Run workflow**, and read the job summary.

Only a run of the default branch opens issues.

## Handle an issue

1. Read **What changed** and **Policy impact**, and open the comparison for each changed Go file. The matching
   `psa-cel-update` issue in kyverno/kyverno, if there's one, shows how the chart handled the same release.
1. Do the items under **Required actions**. For a policy change, open a pull request that references the issue.
1. Check each item under **Validation**.
1. In the same pull request, move `since` in `config.yaml` to the release.
1. Close the issue. A closed issue is never reopened or recreated.

When upstream adds a check, add it to `checks`. The tests fail when a mapped policy has no file, or when a policy in
`pod-security-vpol/` isn't mapped.

## Test a change

The `Test PSA release issues` job runs `test-psa-release-issues.py` on each pull request that changes the
workflow, the files in this folder, or `pod-security-vpol/`. The tests use a local git repository shaped like the mirror, a fake GitHub API,
and a fake `gh` process, and they read the workflow file to check its permissions, pinned actions, timeouts,
inputs, defaults, and concurrency group. They don't run the workflow.

To run the tests and a dry run locally, you need Python 3 with PyYAML and Git, and, for the dry run, the GitHub CLI
signed in with read access to `OWNER/NAME`, the repository that holds the issues:

```bash
python3 .hack/psa-release-issues/test-psa-release-issues.py
python3 .hack/psa-release-issues/psa-release-issues.py --repo OWNER/NAME --out /tmp/psa-release --dry-run --since kubernetes-1.34.0
```

A dry run only reads: the repository settings and the issue list. It writes `summary.md` and one file per issue to
`--out`. `--since kubernetes-1.34.0` checks three past releases, so you can read real issue bodies. The script exits
with `1` when it can't fetch the mirror or handle a release, and the next run retries. It opens at most five issues
per run, and a minor release without the previous minor to compare with fails the run, so a person checks it.

Only a real run verifies the workflow. Before you rely on it, in a fork:

1. Turn on Issues and Actions in the fork.
1. Run the workflow with `dry-run` set, and read the job summary.
1. Run it with `dry-run` cleared and `since` set to `kubernetes-1.36.0`, and check the issue for `v1.37.0` and its
   labels.
1. Run it again, and check that it doesn't open a second issue.
1. Close the test issue.
