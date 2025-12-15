# Development Process & Collaboration Workflow

This document outlines the recommended Git workflow for this repository, including branch protection, pull request (PR) creation, reviewer management, code checks, and release management. Use this as a reference for safe and collaborative development.

---

## 1. Repository & Branch Protection Setup

### a. Protect the `master` Branch
- Go to your repository on GitHub.
- Navigate to **Settings** > **Branches**.
- Click **Add branch ruleset**.
- Set the branch pattern to `master`.
- Enable:
  - **Require a pull request before merging**
  - **Require status checks to pass before merging** (if CI is set up)
  - **Restrict who can push to matching branches**
  - **Require pull request reviews before merging** (recommended)
- Save the ruleset.

### b. (Optional) Protect Other Branches
- Repeat the above for any other important branches (e.g., `develop`).

---

## 2. Creating a Feature or Hotfix Branch
- Always create a new branch from `master` for your work:
  ```bash
  git checkout master
  git pull origin master
  git checkout -b feature/your-feature-name
  # or for hotfixes:
  git checkout -b hotfix/your-hotfix-name
  ```
- Make your changes, commit, and push the branch:
  ```bash
  git push -u origin feature/your-feature-name
  ```

---

## 3. Creating a Pull Request (PR)
- Go to your repository on GitHub.
- Click the **Pull requests** tab.
- Click **New pull request**.
- Set the base branch to `master` and the compare branch to your feature/hotfix branch.
- Fill in the PR template (choose the appropriate one if multiple are available).
- Submit the PR.

---

## 4. Inviting a Reviewer
- On the PR page, find the **Reviewers** section on the right.
- Click the gear icon or dropdown.
- Search for and select the GitHub username of the reviewer (must be a collaborator).
- The reviewer will be notified and can review/approve the PR.

---

## 5. Automated Checks & PR Requirements
- The repository uses GitHub Actions to enforce that only branches named `feature/*` or `hotfix/*` can be merged into `master`.
- Status checks (such as CI, lint, or tests) must pass before merging (if configured).
- At least one reviewer must approve the PR (if required by branch protection).

---

## 6. Merging the PR
- Once all checks pass and the PR is approved, click **Merge pull request** on the PR page.
- Optionally, delete the source branch after merging.

---

## 7. Tagging and Creating a Release
- After merging, sync your local `master`:
  ```bash
  git checkout master
  git pull origin master
  ```
- Create a new tag for the release:
  ```bash
  git tag -a vX.Y.Z -m "Release vX.Y.Z: <short description>"
  git push origin vX.Y.Z
  ```
- Go to the **Releases** tab on GitHub.
- Click **Draft a new release**.
- Select the new tag, add a title and description, and publish the release.

---

## 8. Summary of Best Practices
- Never push directly to `master`.
- Always use feature/hotfix branches and PRs.
- Use PR templates for clarity and completeness.
- Ensure all checks and reviews are complete before merging.
- Tag and document all releases for traceability.

---

For questions or onboarding, refer to this document or contact the repository maintainer.

