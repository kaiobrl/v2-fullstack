-- =====================================================
-- OFERTA RELAMPAGO - COMPLETE SUPABASE SETUP
-- Execute no SQL Editor do Supabase Dashboard
-- =====================================================

-- ------------------------------------------------------
-- EXTENSIONS
-- ------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ------------------------------------------------------
-- TABELA: leads (com soft delete, full-text search, lead scoring)
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    whatsapp TEXT NOT NULL,
    product TEXT DEFAULT 'Paginas HTML & CSS',
    source TEXT DEFAULT 'landing-page',
    status TEXT DEFAULT 'novo' CHECK (status IN ('novo', 'contatado', 'conversao', 'perdido')),
    notes TEXT DEFAULT '',
    phone_verified BOOLEAN DEFAULT false,
    last_contacted_at TIMESTAMP WITH TIME ZONE,
    lead_score INTEGER DEFAULT 0 CHECK (lead_score >= 0 AND lead_score <= 100),
    search_vector TSVECTOR,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_name CHECK (name ~ '^\s*\S.{1,}'),
    CONSTRAINT valid_whatsapp CHECK (whatsapp ~ '^\d{10,11}$')
);

-- ------------------------------------------------------
-- TABELA: lead_notes
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE NOT NULL,
    author TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------
-- TABELA: lead_audit_log
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_audit_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_lead_id ON lead_audit_log(lead_id);
CREATE INDEX IF NOT EXISTS idx_audit_changed_at ON lead_audit_log(changed_at DESC);

-- ------------------------------------------------------
-- TABELA: rate_limits (controle de taxa)
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS rate_limits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ip_address TEXT NOT NULL DEFAULT 'unknown',
    endpoint TEXT NOT NULL DEFAULT 'insert_lead',
    request_count INTEGER DEFAULT 1,
    window_start TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rate_limits_ip ON rate_limits(ip_address, endpoint, window_start);

-- ------------------------------------------------------
-- TABELA: products (catalogo de produtos)
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    old_price NUMERIC(10,2),
    image_url TEXT,
    badge TEXT,
    active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Produtos iniciais
INSERT INTO products (name, description, price, old_price, image_url, badge, sort_order) VALUES
('Paginas HTML & CSS', 'Paginas estaticas profissionais, codigo limpo e responsivo. Ideais para portfolios, sites institucionais e paginas de apresentacao.', 80, 200, 'https://images.unsplash.com/photo-1621839673705-6617adf9e890?w=800&h=800&fit=crop&q=80', '60% OFF', 1),
('Landing Pages', 'Paginas de conversao otimizadas para vender mais. Design profissional, copy persuasivo e call-to-action estrategico.', 150, 350, 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=800&fit=crop&q=80', '57% OFF', 2),
('Sistemas Web', 'Sistemas completos com login, CRUD, dashboard e painel administrativo. Solucoes sob medida para seu negocio.', 300, 800, 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=800&fit=crop&q=80', '62% OFF', 3)
ON CONFLICT (name) DO NOTHING;

-- RLS para products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Produtos leitura publica" ON products;
CREATE POLICY "Produtos leitura publica" ON products
    FOR SELECT TO anon
    USING (active = true);

DROP POLICY IF EXISTS "Produtos leitura autenticada" ON products;
CREATE POLICY "Produtos leitura autenticada" ON products
    FOR SELECT TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Produtos gerenciamento autenticado" ON products;
CREATE POLICY "Produtos gerenciamento autenticado" ON products
    FOR ALL TO authenticated
    USING (true);

-- ------------------------------------------------------
-- GARANTIR COLUNAS EXISTENTES (para tabelas ja criadas)
-- ------------------------------------------------------
ALTER TABLE leads ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT false;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS last_contacted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS lead_score INTEGER DEFAULT 0 CHECK (lead_score >= 0 AND lead_score <= 100);
ALTER TABLE leads ADD COLUMN IF NOT EXISTS search_vector TSVECTOR;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS product TEXT DEFAULT 'Paginas HTML & CSS';
ALTER TABLE leads ADD COLUMN IF NOT EXISTS source TEXT DEFAULT 'landing-page';
ALTER TABLE leads ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT '';
ALTER TABLE leads ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT false;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS last_contacted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS lead_score INTEGER DEFAULT 0 CHECK (lead_score >= 0 AND lead_score <= 100);
ALTER TABLE leads ADD COLUMN IF NOT EXISTS search_vector TSVECTOR;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;

-- Garantir DEFAULT em colunas existentes (para tabelas ja criadas sem DEFAULT)
ALTER TABLE rate_limits ALTER COLUMN ip_address SET DEFAULT 'unknown';

-- ------------------------------------------------------
-- VIEW: leads_active (filtra soft-deleted)
-- ------------------------------------------------------
CREATE OR REPLACE VIEW leads_active AS
SELECT * FROM leads WHERE deleted_at IS NULL;

-- ------------------------------------------------------
-- ROW LEVEL SECURITY
-- ------------------------------------------------------
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_audit_log ENABLE ROW LEVEL SECURITY;

-- leads
DROP POLICY IF EXISTS "Permitir insercao publica" ON leads;
CREATE POLICY "Permitir insercao publica" ON leads
    FOR INSERT TO anon
    WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir leitura autenticada" ON leads;
CREATE POLICY "Permitir leitura autenticada" ON leads
    FOR SELECT TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Permitir leitura publica" ON leads;
CREATE POLICY "Permitir leitura publica" ON leads
    FOR SELECT TO anon
    USING (true);

DROP POLICY IF EXISTS "Permitir atualizacao autenticada" ON leads;
CREATE POLICY "Permitir atualizacao autenticada" ON leads
    FOR UPDATE TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Permitir exclusao autenticada" ON leads;
CREATE POLICY "Permitir exclusao autenticada" ON leads
    FOR DELETE TO authenticated
    USING (true);

-- lead_notes
DROP POLICY IF EXISTS "Permitir insercao autenticada notes" ON lead_notes;
CREATE POLICY "Permitir insercao autenticada notes" ON lead_notes
    FOR INSERT TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir leitura autenticada notes" ON lead_notes;
CREATE POLICY "Permitir leitura autenticada notes" ON lead_notes
    FOR SELECT TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Permitir exclusao autenticada notes" ON lead_notes;
CREATE POLICY "Permitir exclusao autenticada notes" ON lead_notes
    FOR DELETE TO authenticated
    USING (true);

-- lead_audit_log
DROP POLICY IF EXISTS "Permitir insercao audit" ON lead_audit_log;
CREATE POLICY "Permitir insercao audit" ON lead_audit_log
    FOR INSERT TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir leitura audit" ON lead_audit_log;
CREATE POLICY "Permitir leitura audit" ON lead_audit_log
    FOR SELECT TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Permitir leitura audit public" ON lead_audit_log;
CREATE POLICY "Permitir leitura audit public" ON lead_audit_log
    FOR SELECT TO anon
    USING (true);

-- ------------------------------------------------------
-- INDICES
-- ------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_whatsapp ON leads(whatsapp);
CREATE INDEX IF NOT EXISTS idx_leads_name ON leads USING gin(name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_leads_search_vector ON leads USING gin(search_vector);
CREATE INDEX IF NOT EXISTS idx_lead_notes_lead_id ON lead_notes(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_notes_created_at ON lead_notes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leads_deleted_at ON leads(deleted_at);
CREATE INDEX IF NOT EXISTS idx_leads_lead_score ON leads(lead_score DESC);
CREATE INDEX IF NOT EXISTS idx_leads_source ON leads(source);

-- ------------------------------------------------------
-- TRIGGER: updated_at
-- ------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_leads_updated_at ON leads;
CREATE TRIGGER update_leads_updated_at
    BEFORE UPDATE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ------------------------------------------------------
-- TRIGGER: audit log
-- ------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_lead_changes()
RETURNS TRIGGER AS $$
DECLARE
    _changed_by TEXT;
BEGIN
    _changed_by := COALESCE(current_user, 'system');
    IF TG_OP = 'INSERT' THEN
        INSERT INTO lead_audit_log(lead_id, action, new_data, changed_by)
        VALUES (NEW.id, 'INSERT', row_to_json(NEW)::jsonb, _changed_by);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO lead_audit_log(lead_id, action, old_data, new_data, changed_by)
        VALUES (NEW.id, 'UPDATE', row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, _changed_by);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO lead_audit_log(lead_id, action, old_data, changed_by)
        VALUES (OLD.id, 'DELETE', row_to_json(OLD)::jsonb, _changed_by);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS audit_leads ON leads;
CREATE TRIGGER audit_leads
    AFTER INSERT OR UPDATE OR DELETE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION audit_lead_changes();

-- ------------------------------------------------------
-- TRIGGER: full-text search vector
-- ------------------------------------------------------
CREATE OR REPLACE FUNCTION update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('portuguese', COALESCE(NEW.name, '') || ' ' || COALESCE(NEW.whatsapp, '') || ' ' || COALESCE(NEW.notes, ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_leads_search_vector ON leads;
CREATE TRIGGER update_leads_search_vector
    BEFORE INSERT OR UPDATE OF name, whatsapp, notes ON leads
    FOR EACH ROW
    EXECUTE FUNCTION update_search_vector();

-- ------------------------------------------------------
-- TRIGGER: auto-calculate lead_score
-- ------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_lead_score()
RETURNS TRIGGER AS $$
DECLARE
    hours_since_creation INTEGER;
    note_count INTEGER;
    score INTEGER := 0;
BEGIN
    hours_since_creation := EXTRACT(EPOCH FROM (NOW() - NEW.created_at)) / 3600;
    SELECT COUNT(*) INTO note_count FROM lead_notes WHERE lead_id = NEW.id;
    score := GREATEST(0, 50 - hours_since_creation / 24);
    IF NEW.status = 'conversao' THEN score := score + 30;
    ELSIF NEW.status = 'contatado' THEN score := score + 15;
    ELSIF NEW.status = 'perdido' THEN score := score - 20;
    END IF;
    IF NEW.phone_verified THEN score := score + 10; END IF;
    score := score + LEAST(note_count * 5, 15);
    NEW.lead_score := GREATEST(0, LEAST(100, score));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_lead_score ON leads;
CREATE TRIGGER update_lead_score
    BEFORE INSERT OR UPDATE OF status, phone_verified ON leads
    FOR EACH ROW
    EXECUTE FUNCTION calculate_lead_score();

-- ------------------------------------------------------
-- TRIGGER: rate limiting check
-- ------------------------------------------------------
CREATE OR REPLACE FUNCTION check_rate_limit()
RETURNS TRIGGER AS $$
DECLARE
    recent_count INTEGER;
BEGIN
    DELETE FROM rate_limits WHERE window_start < NOW() - INTERVAL '1 minute';
    SELECT COUNT(*) INTO recent_count FROM rate_limits
        WHERE endpoint = 'insert_lead' AND window_start > NOW() - INTERVAL '1 minute';
    IF recent_count >= 10 THEN
        RAISE EXCEPTION 'rate_limit_exceeded: Muitas requisicoes. Aguarde 1 minuto.';
    END IF;
    INSERT INTO rate_limits(endpoint) VALUES ('insert_lead');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS rate_limit_before_insert ON leads;
CREATE TRIGGER rate_limit_before_insert
    BEFORE INSERT ON leads
    FOR EACH ROW
    EXECUTE FUNCTION check_rate_limit();

-- ------------------------------------------------------
-- FUNCOES
-- ------------------------------------------------------

CREATE OR REPLACE FUNCTION get_lead_stats()
RETURNS TABLE (
    total_leads BIGINT,
    today_leads BIGINT,
    week_leads BIGINT,
    month_leads BIGINT,
    converting_leads BIGINT,
    converted_leads BIGINT,
    conversion_rate NUMERIC,
    avg_response_time_hours NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL)::BIGINT,
        (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND created_at::date = CURRENT_DATE)::BIGINT,
        (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND created_at >= DATE_TRUNC('week', CURRENT_DATE))::BIGINT,
        (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND created_at >= DATE_TRUNC('month', CURRENT_DATE))::BIGINT,
        (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND status IN ('contatado', 'conversao'))::BIGINT,
        (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND status = 'conversao')::BIGINT,
        CASE
            WHEN (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL) > 0
            THEN ROUND(((SELECT COUNT(*)::NUMERIC FROM leads WHERE deleted_at IS NULL AND status = 'conversao')
                / (SELECT COUNT(*)::NUMERIC FROM leads WHERE deleted_at IS NULL)) * 100, 1)
            ELSE 0::NUMERIC
        END,
        COALESCE(
            (SELECT ROUND(AVG(EXTRACT(EPOCH FROM (updated_at - created_at)) / 3600)::NUMERIC, 1)
             FROM leads WHERE deleted_at IS NULL AND status = 'conversao' AND updated_at > created_at),
            0::NUMERIC
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_leads_per_day()
RETURNS TABLE (lead_date DATE, lead_count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT d::date AS lead_date,
        COALESCE((SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND created_at::date = d::date), 0)::BIGINT
    FROM generate_series(CURRENT_DATE - INTERVAL '29 days', CURRENT_DATE, '1 day') d;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_lead_insights()
RETURNS TABLE (best_hour INTEGER, best_day TEXT, top_source TEXT, conversion_by_source JSONB, funnel_totals JSONB) AS $$
DECLARE
    _best_hour INTEGER;
    _best_day TEXT;
    _top_source TEXT;
    _conversion_by_source JSONB;
    _funnel_totals JSONB;
BEGIN
    SELECT EXTRACT(HOUR FROM created_at)::INTEGER INTO _best_hour
    FROM leads WHERE deleted_at IS NULL
    GROUP BY 1 ORDER BY COUNT(*) DESC LIMIT 1;
    SELECT TO_CHAR(created_at, 'Day') INTO _best_day
    FROM leads WHERE deleted_at IS NULL
    GROUP BY 1 ORDER BY COUNT(*) DESC LIMIT 1;
    SELECT source INTO _top_source
    FROM leads WHERE deleted_at IS NULL
    GROUP BY source ORDER BY COUNT(*) DESC LIMIT 1;
    SELECT jsonb_object_agg(source, cnt) INTO _conversion_by_source
    FROM (SELECT source, COUNT(*)::TEXT AS cnt FROM leads WHERE deleted_at IS NULL AND status = 'conversao' GROUP BY source) s;
    SELECT jsonb_build_object(
        'novo', (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND status = 'novo'),
        'contatado', (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND status = 'contatado'),
        'conversao', (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND status = 'conversao'),
        'perdido', (SELECT COUNT(*) FROM leads WHERE deleted_at IS NULL AND status = 'perdido')
    ) INTO _funnel_totals;
    RETURN QUERY SELECT _best_hour, _best_day, _top_source, _conversion_by_source, _funnel_totals;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION search_leads(search_text TEXT)
RETURNS TABLE (id UUID, name TEXT, whatsapp TEXT, status TEXT, lead_score INTEGER, created_at TIMESTAMP WITH TIME ZONE, relevancy NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id, l.name, l.whatsapp, l.status, l.lead_score, l.created_at,
        ts_rank(l.search_vector, plainto_tsquery('portuguese', search_text)) AS relevancy
    FROM leads l
    WHERE l.deleted_at IS NULL AND l.search_vector @@ plainto_tsquery('portuguese', search_text)
    ORDER BY relevancy DESC LIMIT 50;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION bulk_update_status(lead_ids UUID[], new_status TEXT)
RETURNS TABLE (updated_count INTEGER) AS $$
DECLARE _count INTEGER;
BEGIN
    IF new_status NOT IN ('novo', 'contatado', 'conversao', 'perdido') THEN
        RAISE EXCEPTION 'invalid_status';
    END IF;
    UPDATE leads SET status = new_status WHERE id = ANY(lead_ids) AND deleted_at IS NULL;
    GET DIAGNOSTICS _count = ROW_COUNT;
    RETURN QUERY SELECT _count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION soft_delete_leads(lead_ids UUID[])
RETURNS TABLE (deleted_count INTEGER) AS $$
DECLARE _count INTEGER;
BEGIN
    UPDATE leads SET deleted_at = NOW() WHERE id = ANY(lead_ids) AND deleted_at IS NULL;
    GET DIAGNOSTICS _count = ROW_COUNT;
    RETURN QUERY SELECT _count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION hard_delete_leads(lead_ids UUID[])
RETURNS TABLE (deleted_count INTEGER) AS $$
DECLARE _count INTEGER;
BEGIN
    DELETE FROM leads WHERE id = ANY(lead_ids);
    GET DIAGNOSTICS _count = ROW_COUNT;
    RETURN QUERY SELECT _count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS JSONB AS $$
DECLARE result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'stats', row_to_json(s),
        'per_day', (SELECT jsonb_agg(jsonb_build_object('date', lead_date, 'count', lead_count)) FROM get_leads_per_day()),
        'insights', row_to_json(i)
    ) INTO result
    FROM get_lead_stats() s, get_lead_insights() i;
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------
-- HABILITAR REALTIME (ignorar se ja pertencem a publicacao)
-- ------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'leads'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE leads;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'lead_notes'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE lead_notes;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'products'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE products;
    END IF;
END $$;
