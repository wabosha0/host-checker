# Projects

A collection of Linux/Bash projects, built while working through a cybersecurity learning roadmap on Kali Linux.

## Setting up Git & GitHub CLI on Kali

Notes from setting this repo up — from a fresh Kali install with no git remote configured, through installing the GitHub CLI and authenticating.

### 1. Organizing the repo

Rather than turning the whole home folder into a git repo, created a dedicated project folder first:

```bash
mkdir ~/projects
cd ~/projects
mkdir host-checker
```

### 2. Initializing git

```bash
cd ~/projects
git init
```

**Lesson:** `git add` / `git commit` / `git push` all fail with `fatal: not a git repository` until `git init` has been run in that folder — it's what creates the hidden `.git/` directory git uses to track history.

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git add host-checker/
git commit -m "Add host checker script"
```

### 3. Installing the GitHub CLI (`gh`)

`gh` isn't in Kali's default repositories — installing it directly fails:

```bash
sudo apt install gh -y
# Error: Unable to locate package gh
```

Fix: add GitHub's own apt repository and signing key first.

```bash
sudo apt install curl -y

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null

sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update
sudo apt install gh -y
gh --version
```

**Lesson learned mid-way:** `sudo apt update` and `sudo apt install gh -y` must be run as **two separate commands**. Running them on one line fails with `Error: The update command takes no arguments`, because apt interprets everything after `update` as arguments to it.

### 4. Authenticating

```bash
gh auth login
```

Prompts answered in order:
- **Where do you use GitHub?** → `GitHub.com`
- **Preferred protocol?** → `HTTPS`
- **Authenticate Git with your GitHub credentials?** → `Yes`
- **How would you like to authenticate?** → `Login with a web browser`

This prints a one-time code and a prompt to open `github.com/login/device` in a browser. Pasting the code there and authorizing completes the login — confirmed afterward with:

```bash
gh auth status
```

### 5. Creating and pushing the repo

With `gh` authenticated, repo creation and push collapse into one command instead of manually creating the repo on github.com first:

```bash
cd ~/projects
gh repo create projects --public --source=. --remote=origin --push
```

### Commands reference

| Command | Purpose |
|---|---|
| `git init` | Turn the current folder into a git repository |
| `git config --global user.name/user.email` | Set the identity attached to commits (once per machine) |
| `git add <path>` | Stage files for the next commit |
| `git commit -m "message"` | Save a snapshot of staged changes with a description |
| `gh auth login` | Authenticate the GitHub CLI with a GitHub account |
| `gh auth status` | Check current authentication status |
| `gh repo create` | Create a GitHub repository directly from the terminal |
| `git push -u origin main` | Upload local commits to GitHub and remember the connection for future pushes |

## Projects in this repo

- **host-checker/** — a bash script that checks whether hosts are reachable, with optional logging. See its own README inside the folder.
