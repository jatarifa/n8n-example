# Workflow: Logs Analyzer

## Descripción

Comando de Slack que analiza logs de BigQuery usando un LLM.

## Comando Slack

```
/logs <UUID> [fecha] [entorno]
```

**Parámetros:**
- `UUID`: obligatorio - Identificador del workflow/proceso
- `fecha`: opcional - Formato yyyyMMdd (default: fecha actual del sistema)
- `entorno`: opcional - "sta" o "prod" (default: "sta")

## Flujo

1. Recibir comando desde Slack (webhook/slash command)
2. Parsear parámetros y aplicar defaults
3. Construir y ejecutar query en BigQuery
4. Obtener logs en formato JSON
5. Construir prompt con logs
6. Llamar API de Google Gemini para análisis
7. Extraer respuesta de Gemini
8. Responder a Slack con el análisis

## BigQuery Configuration

### Entorno STA (default)
- PROJECT_ID: `mm-provision-osp-sta`
- DATASET: `provision_osp_sta_containers_logs`
- table_name: `stdout_${date}` (date en formato yyyyMMdd)

### Entorno PROD
- PROJECT_ID: `mm-provision-osp-prod`
- DATASET: `provision_osp_prod_containers_logs`
- table_name: `stdout_${date}` (date en formato yyyyMMdd)

### Query Template

```sql
SELECT
  timestamp,
  jsonPayload.metadata.workflowtype,
  jsonPayload.metadata.activitytype,
  jsonPayload.message,
  httpRequest.requestUrl,
  jsonPayload.requestBody.content AS request,
  jsonPayload.responseBody.content AS response,
  httpRequest.status
FROM
  `${PROJECT_ID}.${DATASET}.${table_name}`
WHERE
  jsonPayload.loggername != 'org.hibernate.SQL'
  AND ( jsonPayload.message LIKE '%${uuid}%'
    OR jsonPayload.metadata.workflowId LIKE '${uuid}%' )
ORDER BY
  timestamp ASC
```

**Variables a reemplazar:**
- `${PROJECT_ID}`
- `${DATASET}`
- `${table_name}`
- `${uuid}`

## LLM Analysis

### API de Google Gemini

**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent`
**Método:** POST
**Auth:** API Key via query parameter `?key=GEMINI_API_KEY`
**Modelo:** `gemini-2.0-flash-exp`

**Configuración:** Ver `GEMINI_API_KEY_SETUP.md` para obtener y configurar la API key

### Prompt Template

```
Analyze the following BigQuery logs from a provisioning workflow execution.

IMPORTANT: Structure your response with the analysis first, then separate each JSON with "###JSON###".

Format rules for ANALYSIS section:
- Use *bold*, _italic_ for emphasis where needed
- Emojis: 🚀 ✅ ❌ ⚠️ 🔍 📊

Structure EXACTLY:

*🚀 SUMMARY*
Resume the execution status, process times and representative information

*🔍 EXECUTION FLOW*
Structure references to external system calls, with exceptions and success messages if any

*🏗️ TMF ANALYSIS*
Analyze input JSON and describe hierarchy of TMF format items and accounts. Include graphical representation with hints of JSON structure intent

*⚠️ KENAN ANALYSIS*
Analyze Kenan multiple service invocations payloads and describe the accounts and elements being processed

###JSON###
*📄 TMF ORDER JSON*
{...complete TMF order JSON formatted and indented...}

###JSON###
*📄 KENAN REQUEST #n*
{...complete kenan request JSON formatted and indented...}

###JSON###
*📄 KENAN RESPONSE #n*
{...complete kenan response JSON formatted and indented...}

Repeat for each Kenan call. DO NOT use ```json tags, just output the raw JSON.

Follow a strict order of the sections, do not mix them.

Here are the logs:
{bigquery-logs}
```

**Placeholder:**
- `{bigquery-logs}`: Reemplazar con resultados de BigQuery en JSON

**Separador:** La respuesta se divide usando `###JSON###` para separar el análisis de los JSONs individuales.

## Arquitectura del Workflow Final

El workflow consta de 15 nodos conectados en la siguiente secuencia:

1. **Webhook** - Recibe POST de Slack con comando `/logs`
2. **Respond to Webhook** - Responde inmediatamente a Slack (< 0.1s) con mensaje de procesamiento
3. **Parse Parameters** - Parsea UUID, fecha y entorno; aplica defaults y validaciones; genera nombre del canal
4. **Create Slack Channel** - Crea canal público en Slack con nombre `logs-{uuid}-{fecha}-{entorno}`
5. **Check Channel Created** - Verifica si el canal fue creado o ya existía; obtiene channel_id
6. **Invite User to Channel** - Invita al usuario que ejecutó el comando al canal
7. **Send Initial Message** - Envía mensaje inicial al canal ("⏳ Analizando logs...")
8. **BigQuery** - Ejecuta query SQL contra BigQuery para recuperar logs
9. **Build Prompt** - Construye prompt para Gemini con los logs en formato JSON
10. **Call Gemini API** - Llama a API REST de Gemini con el prompt
11. **Extract Gemini Response** - Extrae respuesta y divide en secciones por separador `###JSON###`
12. **Prepare Slack Message** - Prepara bloques Slack con `rich_text_preformatted` para JSONs
13. **Split In Batches** - Procesa mensajes uno por uno para garantizar orden secuencial
14. **Wait** - Añade delay de 1 segundo entre mensajes
15. **Send to Slack** - Envía mensaje al canal vía HTTP Request → Loop back to Split In Batches

**Flujo clave:**
- Webhook → respuesta inmediata → creación de canal → procesamiento asíncrono → envío secuencial
- Sin timeouts (respuesta en < 0.1s)
- Cada análisis se envía a un canal dedicado creado automáticamente
- Canal público con nombre descriptivo: `logs-{uuid}-{fecha}-{entorno}`
- Usuario invitado automáticamente al canal
- Orden garantizado con Split In Batches + Wait + loop
- JSONs con formato de extracto usando `rich_text_preformatted`
- Delays de 1 segundo entre mensajes

## Estado

- [x] Workflow implementado en n8n
- [x] Workflow exportado a `flow/logs-analyzer.json`
- [x] Credenciales de GCP/BigQuery configuradas (Service Account: n8n-bigquery-logs@mm-provision-osp-sta.iam.gserviceaccount.com)
- [x] Gemini API integrada directamente (gemini-2.0-flash-exp)
- [x] GEMINI_API_KEY configurada en docker-compose.yml
- [x] Workflow activado en n8n
- [x] Workflow probado end-to-end con éxito (44 logs analizados, respuesta generada correctamente)
- [x] Configuración de Slack Slash Command completada
- [x] ngrok configurado para webhook público
- [x] Formato Slack Blocks con markdown implementado
- [x] Mensajes divididos en secciones con orden correcto
- [x] Manejo de límite de 3000 caracteres por bloque
- [x] Validación de parámetro fecha (yyyyMMdd)
- [x] Respuesta inmediata a webhook para evitar timeout

## Información del Workflow

**ID en n8n:** `pI5VIZDiGAataU0N`
**Versión:** 111 (actual)
**Webhook URL:** `http://localhost:5678/webhook/slack-logs`
**Archivo exportado:** `flow/logs-analyzer.json`

## Configuración de Slack Slash Command

### 1. Crear Slack App

1. Accede a https://api.slack.com/apps
2. Click en "Create New App" → "From scratch"
3. Nombre: "Logs Analyzer" (o el que prefieras)
4. Selecciona tu workspace
5. Click "Create App"

### 2. Crear Slash Command

1. En el menú lateral, ve a "Slash Commands"
2. Click "Create New Command"
3. Configura:
   - **Command:** `/logs`
   - **Request URL:** `http://localhost:5678/webhook/slack-logs` (o tu URL pública)
   - **Short Description:** "Analyze BigQuery logs with AI"
   - **Usage Hint:** `<UUID> [fecha] [entorno]`
4. Click "Save"

### 3. Instalar App en Workspace

1. En el menú lateral, ve a "Install App"
2. Click "Install to Workspace"
3. Autoriza los permisos
4. La app estará disponible en tu workspace

### 4. Usar URL Pública (Producción)

Para producción, necesitas exponer tu n8n con una URL pública:

**Opción 1: ngrok (desarrollo/testing)**
```bash
ngrok http 5678
# Usa la URL https://xxxxx.ngrok.io/webhook/slack-logs
```

**Opción 2: Dominio propio**
- Configura un reverse proxy (nginx/caddy)
- Apunta a tu instancia de n8n
- Usa certificado SSL (Let's Encrypt)

### 5. Actualizar Request URL

Una vez tengas la URL pública:
1. Ve a tu Slack App → Slash Commands
2. Edita el comando `/logs`
3. Actualiza Request URL con tu URL pública
4. Guarda los cambios

## Resumen de Configuración Completada

✅ **Workflow implementado y activo**
- ID: `pI5VIZDiGAataU0N`
- Estado: **ACTIVO**
- Versión: 111 (actual)
- Nodos: 15 (incluyendo creación automática de canales)
- Webhook URL local: `http://localhost:5678/webhook/slack-logs`
- Webhook URL público: `https://TU-SUBDOMINIO.ngrok-free.app/webhook/slack-logs` (requiere configurar ngrok)

✅ **Credenciales BigQuery configuradas**
- Service Account: `n8n-bigquery-logs@mm-provision-osp-sta.iam.gserviceaccount.com`
- Project STA: `mm-provision-osp-sta`
- Project PROD: `mm-provision-osp-prod`

✅ **Gemini API integrada**
- Modelo: gemini-2.0-flash-exp
- API Key configurada en docker-compose.yml
- Endpoint: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent`

✅ **Workflow probado exitosamente**
- Funcionalidad principal: Análisis de logs con Gemini
- Respuesta webhook: **< 0.1 segundos** (sin timeout!)
- Creación automática de canales Slack dedicados
- Mensajes enviados secuencialmente con delays de 1s
- Formato JSON: `rich_text_preformatted` para mejor visualización
- Análisis dividido en secciones: Summary, Execution Flow, TMF Analysis, Kenan Analysis + JSONs individuales

## Problemas Resueltos

Durante el desarrollo se resolvieron los siguientes problemas:

### 1. Timeout de Slack (operation_timeout)
**Problema:** Slack tiene un timeout de 3 segundos, pero el workflow tarda 30+ segundos
**Solución:** Añadido nodo "Respond to Webhook" que responde inmediatamente con mensaje de procesamiento, mientras el análisis continúa en segundo plano

### 2. Mensajes en orden inverso
**Problema:** Los mensajes JSON llegaban antes que el análisis
**Solución:** Implementado sistema de delays progresivos (0s, 2s, 4s, 6s...) en el nodo "Send Slack Response"

### 3. JSON sin formato de código
**Problema:** Los bloques JSON no se mostraban con formato de código
**Solución:** Actualizado prompt de Gemini para usar exactamente ` ```json ` en todos los bloques JSON

### 4. Tablas sin formato correcto
**Problema:** Las tablas perdían el formato de alineación
**Solución:** Cambiado a bloques preformateados con ` ``` ` para preservar espaciado

### 5. Error invalid_blocks (límite 3000 caracteres)
**Problema:** Bloques de texto excedían el límite de 3000 caracteres de Slack
**Solución:** Implementado división automática de texto en chunks de 2900 caracteres máximo

### 6. Error invalid_payload (async en expresiones)
**Problema:** n8n no puede ejecutar funciones async dentro de expresiones `={{ }}`
**Solución:** Cambiado nodo "Send Slack Response" de HTTP Request a Code node con soporte nativo async/await

### 7. Error de validación de fecha
**Problema:** Tabla `stdout_2025111` no encontrada (7 dígitos en lugar de 8)
**Solución:** Añadida validación regex `/^\d{8}$/` en formato yyyyMMdd, con default a fecha actual si es inválida

### 8. Error $http is not defined (Code node)
**Problema:** Objeto `$http` no está disponible en nodos Code de n8n
**Solución:** Dividido en dos nodos: "Prepare Slack Message" (Code) y "Send to Slack" (HTTP Request)

### 9. Timeout persistente - Webhook no respondía rápido
**Problema:** n8n esperaba a que todo el workflow terminara antes de responder al webhook
**Solución:** Reorganizada la estructura del flujo: Webhook → Respond to Webhook → Parse Parameters → resto del flujo. Ahora responde en 0.039 segundos

### 10. Partición de mensajes JSON
**Problema:** Los bloques JSON se partían por tamaño, cortando el JSON a la mitad
**Solución:** Implementada lógica inteligente que respeta los bloques ` ```json ` y no los parte

### 11. Rediseño de partición de mensajes y formato de extractos
**Problema:** Error `invalid_blocks` en Slack al enviar múltiples secciones con JSONs embebidos en markdown
**Solución:**
- Cambiado separador de `###SECTION###` a `###JSON###`
- Primer mensaje: Todo el análisis (Summary, Execution Flow, Actions Table, TMF Analysis, Kenan Analysis)
- Mensajes siguientes: Un mensaje por cada JSON (TMF Order, Kenan Request, Kenan Response)
- JSONs se envían con bloques `rich_text` + `rich_text_preformatted` (formato de extracto de Slack)
- Eliminación automática de marcadores ` ```json ` y ` ``` ` de la respuesta de Gemini
- Actualizado prompt de Gemini para generar estructura correcta
- Actualizado "Extract Gemini Response" para marcar secciones como análisis o JSON
- Actualizado "Prepare Slack Message" para formatear correctamente cada tipo de sección

### 12. Orden de mensajes garantizado
**Problema:** Mensajes llegaban desordenados a Slack en algunas ocasiones
**Solución:**
- Convertido "Send to Slack" de HTTP Request a Code node
- Implementado ordenamiento por `section_number` antes de enviar
- Añadido delay de 2 segundos entre cada mensaje usando `await` y `setTimeout`
- Envío secuencial con `fetch` + `await` para garantizar orden correcto

### 13. Code nodes sin acceso a fetch/https/require
**Problema:** Code nodes en n8n no tienen acceso a `fetch`, `https.request` o `require` debido al sandbox
**Solución Final:**
- Cambiado a arquitectura con Split In Batches + Wait + HTTP Request
- Split In Batches procesa items uno por uno (batchSize: 1)
- Wait añade delay de 1 segundo entre mensajes
- HTTP Request envía a Slack vía nodo nativo
- Loop back de "Send to Slack" a "Split In Batches" para procesar siguiente mensaje
- Orden garantizado por el procesamiento secuencial del loop

### 14. Mejora: Canales dedicados por análisis
**Mejora implementada:** Creación automática de canales Slack para cada análisis
**Beneficios:**
- Canal dedicado con nombre descriptivo: `logs-{uuid}-{fecha}-{entorno}`
- Historial de análisis organizado por canal
- Usuario invitado automáticamente al canal
- Evita saturar un canal único con múltiples análisis
- Permite compartir análisis específicos fácilmente
**Implementación:**
- Nodo "Create Slack Channel" crea canal público
- Nodo "Check Channel Created" verifica creación o reutiliza si existe
- Nodo "Invite User to Channel" invita al usuario
- Nodo "Send Initial Message" envía mensaje de procesamiento al canal
- Resto de mensajes se envían al canal dedicado

## Configuración Completada

Todos los pasos han sido completados exitosamente:

1. ✅ Configurar credenciales de Google Service Account en n8n
2. ✅ Integrar Gemini API
3. ✅ Configurar GEMINI_API_KEY en docker-compose
4. ✅ Activar workflow en n8n
5. ✅ Probar workflow end-to-end
6. ✅ Crear Slack App y configurar Slash Command `/logs`
7. ✅ Exponer webhook con URL pública (ngrok)
8. ✅ Actualizar Request URL en Slack App con la URL pública
9. ✅ Implementar formato Slack Blocks con markdown
10. ✅ Corregir orden de mensajes con delays progresivos
11. ✅ Manejar límite de 3000 caracteres por bloque
12. ✅ Validar formato de fecha yyyyMMdd
13. ✅ Implementar respuesta inmediata para evitar timeout
14. ✅ Solucionar limitaciones de Code nodes con Split In Batches + Wait + HTTP Request
15. ✅ Formato de extracto JSON con `rich_text_preformatted`
16. ✅ Creación automática de canales Slack dedicados por análisis
17. ✅ Invitación automática del usuario al canal creado
18. ✅ Reutilización de canales existentes si el nombre coincide

## Uso del Comando

Para usar el comando `/logs` en Slack:

```
/logs <UUID> [fecha] [entorno]
```

**Ejemplos:**
```
/logs f3fed7f5-396f-43cc-9580-623f40ba48bc
/logs f3fed7f5-396f-43cc-9580-623f40ba48bc 20251113
/logs f3fed7f5-396f-43cc-9580-623f40ba48bc 20251113 sta
/logs db2fc3e1-56a0-42fe-853c-d3ba20875b5c 20251111 prod
```

**Resultado:**
- Respuesta inmediata al comando: "⏳ Analizando logs... Los resultados se publicarán en breve."
- Creación automática de canal dedicado: `logs-{uuid}-{fecha}-{entorno}`
- Usuario invitado automáticamente al canal
- Análisis completo enviado al canal en múltiples mensajes ordenados:
  1. **Análisis principal**: Resumen, flujo de ejecución, análisis TMF/Kenan
  2. **JSON del TMF Order**: Formato de extracto con sintaxis destacada
  3. **JSONs de Kenan**: Request y Response para cada llamada
