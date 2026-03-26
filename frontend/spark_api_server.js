import cors from 'cors'
import express from 'express'
import fs from 'fs/promises'
import path from 'path'
import { fileURLToPath } from 'url'
import { spawn } from 'child_process'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = 8002

app.use(cors())
app.use(express.json())

const projectRoot = path.resolve(__dirname, '..')
const rScriptPath = path.join(projectRoot, 'spark', 'run_stats_sparklyr.R')
const outputPath = path.join(projectRoot, 'spark', 'output.json')

function runRScript(queryName, param1, param2) {
  return new Promise((resolve, reject) => {
    const args = [rScriptPath, queryName]
    if (param1) args.push(param1)
    if (param2) args.push(param2)

    const child = spawn('Rscript', args, { cwd: projectRoot })

    let stderr = ''
    child.stderr.on('data', (chunk) => {
      stderr += chunk.toString()
    })

    child.on('error', (err) => reject(err))
    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr || `Rscript failed with exit code ${code}`))
        return
      }
      resolve()
    })
  })
}

app.get('/health', (_, res) => {
  res.json({ status: 'ok' })
})

app.post('/api/spark/query', async (req, res) => {
  const { queryName, param1 = '', param2 = '' } = req.body || {}

  if (!queryName || typeof queryName !== 'string') {
    res.status(400).json({ error: 'queryName is required.' })
    return
  }

  try {
    await runRScript(queryName, String(param1), String(param2))
    const jsonText = await fs.readFile(outputPath, 'utf-8')
    const payload = JSON.parse(jsonText)
    res.json(payload)
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to run spark query.'
    })
  }
})

app.listen(PORT, () => {
  console.log(`Spark API bridge listening on http://localhost:${PORT}`)
})

