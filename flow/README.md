# n8n Workflows

Workflows exportados de n8n en formato JSON.

## Workflows disponibles

### logs-analyzer.json
Workflow para análisis de logs de BigQuery mediante Slack slash command.

**Comando:** `/logs <UUID> [fecha] [entorno]`

Ver `WORKFLOW_LOGS_ANALYZER.md` para especificación completa.

## Importar workflow en n8n

**Opción 1: Via UI**
1. Accede a http://localhost:5678
2. Click en menú → Import from File
3. Selecciona el archivo JSON
4. Configura credenciales necesarias

**Opción 2: Via MCP de n8n**
```
Pide a Claude: "Importa el workflow desde flow/logs-analyzer.json"
```

**Opción 3: Via CLI (si aplica)**
```bash
# Copiar el contenido del JSON y usar la API de n8n
curl -X POST http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d @flow/logs-analyzer.json
```

## Notas

- Los workflows exportados no incluyen credenciales (por seguridad)
- Después de importar, configura las credenciales necesarias
- Los IDs de los nodos se mantienen para facilitar referencias
