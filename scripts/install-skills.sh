#!/usr/bin/env bash
set -euo pipefail

echo "Installing all skills from obra/superpowers..."
skills add obra/superpowers -g -y

echo "Installing skill-creator from anthropics/skills..."
skills add anthropics/skills -g -y --skill skill-creator

echo "Installing playwright-interactive, screenshot, playwright from openai/skills..."
skills add openai/skills -g -y --skill playwright-interactive screenshot playwright

echo "Installing playwright-interactive, screenshot, playwright from openai/skills..."
skills add openai/skills -g -y --skill playwright-interactive screenshot playwright

echo "Installing empirical-prompt-tuning from mizchi/chezmoi-dotfiles..."
skills add mizchi/chezmoi-dotfiles -g -y --skill empirical-prompt-tuning

echo "Done."
