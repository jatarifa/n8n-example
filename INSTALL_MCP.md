# Instalación del MCP de n8n

## Prerequisitos

- n8n corriendo en http://localhost:5678
- Claude CLI instalado
- API Key de n8n generada

## API Key

Genera una API key desde n8n:
1. Accede a http://localhost:5678/settings/api
2. Click en "Create API key"
3. Label: `n8n-mcp`
4. Copia la key generada

## Comando de instalación

```bash
claude mcp add --transport stdio n8n-mcp \
  --env MCP_MODE=stdio \
  --env LOG_LEVEL=error \
  --env DISABLE_CONSOLE_OUTPUT=true \
  --env N8N_API_URL=http://localhost:5678 \
  --env N8N_API_KEY=TU_API_KEY_AQUI \
  -- npx n8n-mcp
```

**Nota:** Reemplaza `TU_API_KEY_AQUI` con la API key que generaste en el paso anterior.

## Verificación

```bash
# Listar MCPs instalados
claude mcp list

# Verificar estado dentro de Claude Code
/mcp
```

## Gestión

```bash
# Ver detalles del MCP
claude mcp get n8n-mcp

# Eliminar el MCP
claude mcp remove n8n-mcp
```

## Capacidades

**Con API Key:**
- Crear, modificar y eliminar workflows
- Ejecutar workflows
- Gestionar credenciales
- Administrar la instancia de n8n

**Documentación:**
- Acceso a 543 nodos de n8n
- 2,709 plantillas de workflows
- Referencias y ejemplos de código
- Nodos con capacidades de IA (271 nodos)

## Renovación de API Key

Si la API key expira, genera una nueva desde n8n:

1. Accede a http://localhost:5678/settings/api
2. Crea una nueva API key
3. Elimina y vuelve a añadir el MCP con la nueva key

```bash
claude mcp remove n8n-mcp
claude mcp add --transport stdio n8n-mcp \
  --env MCP_MODE=stdio \
  --env LOG_LEVEL=error \
  --env DISABLE_CONSOLE_OUTPUT=true \
  --env N8N_API_URL=http://localhost:5678 \
  --env N8N_API_KEY=TU_NUEVA_API_KEY_AQUI \
  -- npx n8n-mcp
```
