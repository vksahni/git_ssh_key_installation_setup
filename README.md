# GitHub Setup Using SSH (Linux)

This guide explains how to install Git, generate an SSH key, connect it to GitHub, and use GitHub securely without passwords.

---

## 1. Install Git

Update system packages and install Git:

```bash
sudo apt update
sudo apt install git -y
```

Verify installation:

```bash
git --version
```

---

## 2. Configure Git (First Time Only)

Set your GitHub username and email:

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

Verify configuration:

```bash
git config --global --list
```

---

## 3. Generate SSH Key for GitHub

Generate a new ED25519 SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter to accept default location:
~/.ssh/id_ed25519

(Optional) Set a passphrase for extra security.

---

## 4. Start SSH Agent and Add Key

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add the private key (do NOT add .pub):

```bash
ssh-add ~/.ssh/id_ed25519
```

Verify key is loaded:

```bash
ssh-add -l
```

---

## 5. Add SSH Key to GitHub

Copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

1. Go to GitHub → Settings → SSH and GPG keys
2. Click New SSH key
3. Add a title (example: Linux-PC)
4. Paste the public key
5. Click Add SSH key

---

## 6. Test GitHub SSH Connection

Test authentication:

```bash
ssh -T git@github.com
```

Expected output:

Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.

This message means SSH is working correctly.

---

## 7. Clone or Connect a Repository Using SSH

Clone a repository:

```bash
git clone git@github.com:USERNAME/REPOSITORY.git
```

OR change existing repo from HTTPS to SSH:

```bash
git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
```

Check remote URL:

```bash
git remote -v
```

---

## 8. Basic Git Workflow

```bash
git status
git add .
git commit -m "Initial commit"
git push origin main
git pull
```

---

## 9. Recommended SSH Configuration (Optional)

Create SSH config file:

```bash
nano ~/.ssh/config
```

Add:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

---

## 10. Make SSH Default for GitHub (Optional)

```bash
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

---

## Done

Your GitHub SSH setup is complete and ready for development, CI/CD, and automation.
# git_ssh_key_installation_setup
