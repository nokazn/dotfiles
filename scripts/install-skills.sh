#!/usr/bin/env bash
set -euo pipefail

echo "Installing all skills from obra/superpowers..."
skills add obra/superpowers -g -y

echo "Installing skill-creator from anthropics/skills..."
skills add anthropics/skills -g -y --skill skill-creator

echo "Installing playwright, figma skills from openai/skills..."
skills add openai/skills -g -y --skill \
    playwright-interactive screenshot playwright \
    figma figma-code-connect-components figma-create-design-system-rules figma-create-new-file \
    figma-generate-design figma-generate-library figma-implement-design figma-use

echo "Installing find-skills from vercel-labs/skills..."
skills add vercel-labs/skills -g -y --skill find-skills

echo "Installing gh-stack from github/gh-stack..."
skills add github/gh-stack -g -y --skill gh-stack

echo "Installing show-me from humanlayer/skills..."
skills add humanlayer/skills -g -y --skill show-me

echo "Done."
