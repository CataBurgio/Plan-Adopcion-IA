-- Ejecutar en Supabase → SQL Editor
-- Tabla de candidatos para las olas de capacitación PAI

CREATE TABLE IF NOT EXISTS candidates (
  id           SERIAL PRIMARY KEY,
  numero       INTEGER NOT NULL UNIQUE,
  participante TEXT    DEFAULT '',
  area         TEXT    DEFAULT '',
  vertical     TEXT    NOT NULL DEFAULT 'Movilidad', -- 'Corporativo' | 'Movilidad'
  tiene_copilot  BOOLEAN DEFAULT FALSE,
  nativo_digital BOOLEAN DEFAULT FALSE,
  ola_asignada   INTEGER DEFAULT NULL,  -- 1 a 6
  referente      BOOLEAN DEFAULT FALSE,
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cand_public_select" ON candidates FOR SELECT USING (true);
CREATE POLICY "cand_public_insert" ON candidates FOR INSERT WITH CHECK (true);
CREATE POLICY "cand_public_update" ON candidates FOR UPDATE USING (true);

-- Trigger para updated_at automático
CREATE OR REPLACE FUNCTION update_cand_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_cand_updated_at
  BEFORE UPDATE ON candidates
  FOR EACH ROW EXECUTE FUNCTION update_cand_updated_at();

-- Pre-insertar 100 filas vacías
-- 1–25: Corporativo | 26–100: Movilidad
INSERT INTO candidates (numero, vertical)
SELECT n, 'Corporativo' FROM generate_series(1, 25) AS n
ON CONFLICT (numero) DO NOTHING;

INSERT INTO candidates (numero, vertical)
SELECT n, 'Movilidad' FROM generate_series(26, 100) AS n
ON CONFLICT (numero) DO NOTHING;
