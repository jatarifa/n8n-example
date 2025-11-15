#!/bin/bash

# Script para detener n8n con Docker Compose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🛑 Deteniendo n8n..."

docker compose down

echo ""
echo "✅ n8n se ha detenido correctamente"
echo ""
echo "Para eliminar también los datos (volúmenes), usa:"
echo "  docker compose down -v"
echo ""
