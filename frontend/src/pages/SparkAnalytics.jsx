import { useMemo, useState } from 'react'
import { runSparkQuery } from '../sparkApi'

const QUERY_GROUPS = [
  {
    title: 'Game Analytics',
    queries: [
      { key: 'avg_score', label: 'avg_score', p1Label: 'game_name', p1Placeholder: 'Chess' },
      { key: 'max_score', label: 'max_score', p1Label: 'game_name', p1Placeholder: 'Chess' },
      { key: 'min_score', label: 'min_score', p1Label: 'game_name', p1Placeholder: 'Chess' },
      { key: 'total_score', label: 'total_score', p1Label: 'game_name', p1Placeholder: 'Chess' }
    ]
  },
  {
    title: 'Player Analytics',
    queries: [
      { key: 'player_stats', label: 'player_stats', p1Label: 'player_name', p1Placeholder: 'Alice' },
      { key: 'win_count', label: 'win_count', p1Label: 'player_name', p1Placeholder: 'Alice' },
      { key: 'matches_played', label: 'matches_played', p1Label: 'player_name', p1Placeholder: 'Alice' }
    ]
  },
  {
    title: 'Filters',
    queries: [
      { key: 'filter_by_game', label: 'filter_by_game', p1Label: 'game_name', p1Placeholder: 'Chess' },
      { key: 'filter_by_score', label: 'filter_by_score', p1Label: 'min_score', p1Placeholder: '1000' }
    ]
  },
  {
    title: 'Group By',
    queries: [
      { key: 'group_by_game_avg', label: 'group_by_game_avg' },
      { key: 'group_by_game_count', label: 'group_by_game_count' },
      { key: 'wins_by_game', label: 'wins_by_game' }
    ]
  },
  {
    title: 'Sorting',
    queries: [
      { key: 'top_players', label: 'top_players' },
      { key: 'bottom_players', label: 'bottom_players' }
    ]
  },
  {
    title: 'Statistics',
    queries: [
      { key: 'sd_score', label: 'sd_score' },
      { key: 'mean_score', label: 'mean_score' },
      { key: 'median_score', label: 'median_score' },
      { key: 'sum_score', label: 'sum_score' },
      { key: 'distinct_players', label: 'distinct_players' },
      { key: 'score_band_distribution', label: 'score_band_distribution' }
    ]
  },
  {
    title: 'Position',
    queries: [
      { key: 'first_score', label: 'first_score' },
      { key: 'last_score', label: 'last_score' }
    ]
  },
  {
    title: 'Mutate',
    queries: [
      { key: 'mutate_bonus_score', label: 'mutate_bonus_score' },
      { key: 'mutate_flag_highscore', label: 'mutate_flag_highscore' }
    ]
  },
  {
    title: 'Select',
    queries: [
      { key: 'select_starts_with', label: 'select_starts_with' },
      { key: 'select_ends_with', label: 'select_ends_with' }
    ]
  },
  {
    title: 'Advanced',
    queries: [
      { key: 'complex_filter', label: 'complex_filter' },
      { key: 'multi_summary', label: 'multi_summary' },
      { key: 'first_last_summary', label: 'first_last_summary' },
      { key: 'count_sessions', label: 'count_sessions' },
      { key: 'group_multi_agg', label: 'group_multi_agg' }
    ]
  }
]

const DEFAULT_PARAMS = {
  avg_score: { p1: 'Chess', p2: '' },
  max_score: { p1: 'Chess', p2: '' },
  min_score: { p1: 'Chess', p2: '' },
  total_score: { p1: 'Chess', p2: '' },
  player_stats: { p1: 'Alice', p2: '' },
  win_count: { p1: 'Alice', p2: '' },
  matches_played: { p1: 'Alice', p2: '' },
  filter_by_game: { p1: 'Chess', p2: '' },
  filter_by_score: { p1: '1000', p2: '' }
}

function QueryCard({ config, values, onChange, onRun, loading }) {
  return (
    <div className="command-card">
      <div className="command-header">
        <span className="command-title">{config.label}</span>
        <span className="method-badge method-post">Rscript</span>
      </div>

      <div className="command-inputs">
        {config.p1Label && (
          <input
            className="input"
            placeholder={config.p1Placeholder || config.p1Label}
            value={values.p1}
            onChange={(e) => onChange(config.key, 'p1', e.target.value)}
          />
        )}
        {config.p2Label && (
          <input
            className="input"
            placeholder={config.p2Placeholder || config.p2Label}
            value={values.p2}
            onChange={(e) => onChange(config.key, 'p2', e.target.value)}
          />
        )}
      </div>

      <button className="btn btn-post" onClick={() => onRun(config.key)} disabled={loading}>
        {loading ? 'Running...' : 'Run'}
      </button>
    </div>
  )
}

export default function SparkAnalytics() {
  const [paramsByQuery, setParamsByQuery] = useState(DEFAULT_PARAMS)
  const [loadingQuery, setLoadingQuery] = useState('')
  const [response, setResponse] = useState(null)
  const [error, setError] = useState('')

  const queryCount = useMemo(
    () => QUERY_GROUPS.reduce((acc, group) => acc + group.queries.length, 0),
    []
  )

  const handleParamChange = (queryKey, paramKey, value) => {
    setParamsByQuery((prev) => ({
      ...prev,
      [queryKey]: {
        p1: prev?.[queryKey]?.p1 ?? '',
        p2: prev?.[queryKey]?.p2 ?? '',
        [paramKey]: value
      }
    }))
  }

  const handleRun = async (queryKey) => {
    setLoadingQuery(queryKey)
    setError('')
    try {
      const p1 = paramsByQuery?.[queryKey]?.p1 || ''
      const p2 = paramsByQuery?.[queryKey]?.p2 || ''
      const data = await runSparkQuery(queryKey, p1, p2)
      setResponse(data)
    } catch (err) {
      setError(err?.response?.data?.error || err.message || 'Failed to run query')
    } finally {
      setLoadingQuery('')
    }
  }

  return (
    <div>
      <div style={{ marginBottom: '1.5rem' }}>
        <h1 className="hero-title" style={{ fontSize: '2rem', textAlign: 'left' }}>Spark Analytics Console</h1>
        <p style={{ color: 'var(--gray-400)' }}>
          Run sparklyr queries via the R backend ({queryCount} queries wired)
        </p>
      </div>

      {QUERY_GROUPS.map((group) => (
        <section key={group.title} className="section">
          <h3 className="section-subtitle">{group.title}</h3>
          <div className="command-grid spark-grid">
            {group.queries.map((query) => (
              <QueryCard
                key={query.key}
                config={query}
                values={paramsByQuery?.[query.key] || { p1: '', p2: '' }}
                onChange={handleParamChange}
                onRun={handleRun}
                loading={loadingQuery === query.key}
              />
            ))}
          </div>
        </section>
      ))}

      {error && <div className="error">{error}</div>}

      {response && (
        <div className="card" style={{ marginTop: '1rem' }}>
          <h3 className="section-subtitle" style={{ marginBottom: '0.5rem' }}>Latest Response</h3>
          <pre>{JSON.stringify(response, null, 2)}</pre>
        </div>
      )}
    </div>
  )
}
