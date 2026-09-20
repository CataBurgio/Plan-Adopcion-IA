-- Ejecutar en Supabase → SQL Editor
-- Tabla para guardar el contenido editable de cada sección

CREATE TABLE IF NOT EXISTS sections (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by TEXT DEFAULT 'anónimo'
);

-- Habilitar acceso público (lectura y escritura sin login)
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública" ON sections
  FOR SELECT USING (true);

CREATE POLICY "Escritura pública" ON sections
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Actualización pública" ON sections
  FOR UPDATE USING (true);

-- Función para actualizar el timestamp automáticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON sections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
