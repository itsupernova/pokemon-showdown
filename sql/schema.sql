-- Pokemon Showdown Replays Database Schema for PostgreSQL
-- Run this SQL script in your Supabase database to create the necessary tables

-- Main replays table
CREATE TABLE IF NOT EXISTS replays (
	id TEXT PRIMARY KEY,
	format TEXT NOT NULL,
	formatid TEXT NOT NULL,
	players TEXT NOT NULL,
	log TEXT NOT NULL,
	inputlog TEXT,
	uploadtime INTEGER NOT NULL,
	views INTEGER DEFAULT 0,
	rating INTEGER,
	private SMALLINT DEFAULT 0 CHECK (private IN (0, 1, 2, 3, 10)),
	password TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Replay players index table for faster player searches
CREATE TABLE IF NOT EXISTS replayplayers (
	id TEXT NOT NULL REFERENCES replays(id) ON DELETE CASCADE,
	playerid TEXT NOT NULL,
	formatid TEXT NOT NULL,
	format TEXT NOT NULL,
	players TEXT NOT NULL,
	rating INTEGER,
	uploadtime INTEGER NOT NULL,
	private SMALLINT CHECK (private IN (0, 1, 2, 3, 10)),
	password TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id, playerid)
);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_replays_uploadtime ON replays(uploadtime DESC);
CREATE INDEX IF NOT EXISTS idx_replays_formatid ON replays(formatid);
CREATE INDEX IF NOT EXISTS idx_replays_private ON replays(private);
CREATE INDEX IF NOT EXISTS idx_replays_rating ON replays(rating DESC);

CREATE INDEX IF NOT EXISTS idx_replayplayers_playerid ON replayplayers(playerid);
CREATE INDEX IF NOT EXISTS idx_replayplayers_formatid ON replayplayers(formatid);
CREATE INDEX IF NOT EXISTS idx_replayplayers_uploadtime ON replayplayers(uploadtime DESC);
CREATE INDEX IF NOT EXISTS idx_replayplayers_private ON replayplayers(private);
CREATE INDEX IF NOT EXISTS idx_replayplayers_player_format ON replayplayers(playerid, formatid);

-- Full text search index for replay logs (optional, for faster text search)
CREATE INDEX IF NOT EXISTS idx_replays_log_search ON replays USING GIN(to_tsvector('english', log));

-- Enable auto-update of updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
	NEW.updated_at = CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_replays_updated_at BEFORE UPDATE ON replays
	FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
