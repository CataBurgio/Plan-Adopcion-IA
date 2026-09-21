-- Ejecutar en Supabase Dashboard → SQL Editor
-- Crea la tabla pending_items para la cola de aprobación del PAI

CREATE TABLE IF NOT EXISTS pending_items (
  id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  source_file text        NOT NULL,
  status      text        NOT NULL DEFAULT 'pending'
                          CHECK (status IN ('pending', 'approved', 'discarded')),
  area        text,
  proceso     text        NOT NULL,
  descripcion text,
  capas       text[]      DEFAULT '{}',
  referente   text,
  sponsor     text,
  nota        text,
  fuente      text
);

-- Índice para filtrar rápido por status (la UI carga solo 'pending')
CREATE INDEX IF NOT EXISTS pending_items_status_idx ON pending_items(status);

-- Row Level Security: la anon key puede leer y actualizar status
-- (la escritura la hace el script con service_role)
ALTER TABLE pending_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon can read pending_items"
  ON pending_items FOR SELECT
  USING (true);

CREATE POLICY "anon can update status"
  ON pending_items FOR UPDATE
  USING (true)
  WITH CHECK (status IN ('approved', 'discarded'));
