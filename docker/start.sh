#!/bin/bash

# Script para levantar n8n con Docker Compose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Iniciando n8n..."

# Verificar si existe .env, si no copiar de .env.example
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env desde .env.example..."
    cp .env.example .env
    echo "⚠️  Revisa y ajusta las variables en .env si es necesario"
fi

# Crear directorio para datos de n8n si no existe
mkdir -p data

# Levantar los contenedores
docker compose up -d

echo ""
echo "✅ n8n está corriendo!"
echo "🌐 Accede a: http://localhost:5678"
echo ""
echo "Comandos útiles:"
echo "  - Ver logs: docker compose logs -f"
echo "  - Detener: ./stop.sh"
echo "  - Reiniciar: docker compose restart"
echo ""
