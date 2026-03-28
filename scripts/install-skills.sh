#!/usr/bin/env bash
set -euo pipefail

echo "Installing all skills from obra/superpowers..."
npx skills add -g -y obra/superpowers

echo "Installing skill-creator from anthropics/skills..."
npx skills add -g -y -s skill-creator anthropics/skills

echo "Installing playwright-interactive, screenshot, playwright from openai/skills..."
npx skills add -g -y -s playwright-interactive,screenshot,playwright openai/skills

echo "Done."
