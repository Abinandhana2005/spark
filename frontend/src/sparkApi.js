import axios from 'axios'

const sparkBridge = axios.create({
  baseURL: 'http://localhost:8002',
  headers: {
    'Content-Type': 'application/json'
  }
})

export async function runSparkQuery(queryName, param1 = '', param2 = '') {
  const { data } = await sparkBridge.post('/api/spark/query', {
    queryName,
    param1,
    param2
  })
  return data
}

