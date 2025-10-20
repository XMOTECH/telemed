#!/usr/bin/env bash
# Build script pour Render.com

set -e

echo "🚀 Build Telemed pour production..."

# Install Hex + Rebar
mix local.hex --force
mix local.rebar --force

echo "📦 Installation dépendances..."
mix deps.get --only prod

echo "🔨 Compilation assets..."
mix assets.deploy

echo "⚙️  Compilation application..."
MIX_ENV=prod mix compile

echo "✅ Build terminé !"

