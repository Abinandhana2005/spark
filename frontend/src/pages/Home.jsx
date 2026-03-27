import { Link } from 'react-router-dom'

export default function Home() {
  return (
    <div>
      <div className="hero">
        <h1 className="hero-title">Gaming Platform API</h1>
        <p className="hero-subtitle">MongoDB + Neo4j + Spark/R Backend</p>
        <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
          <Link to="/interactive" className="btn btn-primary">Console</Link>
          <Link to="/spark" className="btn btn-primary">Spark Analytics</Link>
          <Link to="/dashboard" className="btn" style={{ background: 'var(--gray-900)', border: '1px solid var(--gray-800)' }}>Docs</Link>
        </div>
      </div>

      <div className="card-grid" style={{ marginBottom: '2rem' }}>
        <Link to="/players" className="feature-card" style={{ textDecoration: 'none' }}>
          <h3 className="feature-title">Players</h3>
          <p className="feature-desc">Browse profiles</p>
        </Link>
        <Link to="/leaderboard" className="feature-card" style={{ textDecoration: 'none' }}>
          <h3 className="feature-title">Leaderboard</h3>
          <p className="feature-desc">Rankings</p>
        </Link>
        <Link to="/search" className="feature-card" style={{ textDecoration: 'none' }}>
          <h3 className="feature-title">Search</h3>
          <p className="feature-desc">Find content</p>
        </Link>
        <Link to="/spark" className="feature-card" style={{ textDecoration: 'none' }}>
          <h3 className="feature-title">Spark Analytics</h3>
          <p className="feature-desc">Run sparklyr queries via R backend</p>
        </Link>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1rem' }}>
        <div className="card">
          <h4 style={{ marginBottom: '0.5rem', fontWeight: 600, color: 'var(--white)' }}>MongoDB</h4>
          <ul style={{ color: 'var(--gray-400)', fontSize: '0.85rem', paddingLeft: '1.25rem', margin: 0 }}>
            <li>Players &amp; Games</li>
            <li>Stats &amp; Matches</li>
            <li>Leaderboards</li>
          </ul>
        </div>
        <div className="card">
          <h4 style={{ marginBottom: '0.5rem', fontWeight: 600, color: 'var(--white)' }}>Neo4j</h4>
          <ul style={{ color: 'var(--gray-400)', fontSize: '0.85rem', paddingLeft: '1.25rem', margin: 0 }}>
            <li>Friends &amp; Parties</li>
            <li>Clans &amp; Messages</li>
            <li>Follow &amp; Block</li>
          </ul>
        </div>
        <div className="card">
          <h4 style={{ marginBottom: '0.5rem', fontWeight: 600, color: 'var(--white)' }}>Spark / R</h4>
          <ul style={{ color: 'var(--gray-400)', fontSize: '0.85rem', paddingLeft: '1.25rem', margin: 0 }}>
            <li>Game Analytics</li>
            <li>Player Statistics</li>
            <li>sparklyr Queries</li>
          </ul>
        </div>
      </div>

      <div className="card" style={{ marginTop: '1.5rem' }}>
        <code style={{ color: 'var(--gray-300)' }}>http://localhost:8001/api/v1</code>
        <span style={{ color: 'var(--gray-600)', margin: '0 0.75rem' }}>|</span>
        <code style={{ color: 'var(--gray-300)' }}>http://localhost:8002/api/spark/query</code>
      </div>
    </div>
  )
}
