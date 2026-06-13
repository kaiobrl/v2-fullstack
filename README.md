# ? Oferta Rel�mpago � Full-Stack Lead Capture

> **Venda:** P�ginas HTML & CSS profissionais � **R$ 80,00** (60% OFF)
> **Stack:** HTML/CSS/JS Vanilla + Supabase (PostgreSQL, Auth, Realtime, Edge Functions)

![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/ES6+-F7DF1E?logo=javascript&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase&logoColor=white)
![Chart.js](https://img.shields.io/badge/Chart.js-FF6384?logo=chartdotjs&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ?? Sum�rio

- [Descri��o](#descri��o)
- [Stack Tecnol�gica](#stack-tecnol�gica)
- [Estrutura](#estrutura-do-projeto)
- [Funcionalidades](#funcionalidades)
  - [Landing Page](#landing-page-indexhtml)
  - [Dashboard Admin](#dashboard-admin-adminhtml)
  - [Banco de Dados](#banco-de-dados-supabase-setupsql)
- [Configura��o](#configura��o)
- [API & Edge Functions](#api--edge-functions)
- [Changelog](#changelog)
- [Troubleshooting](#troubleshooting)
- [Contribui��o](#contribui��o)
- [Licen�a](#licen�a)

---

## Descri��o

Landing page de alta convers�o para captura de leads com dashboard administrativo completo. Vende **P�ginas HTML & CSS** com contagem regressiva, prova social, m�ltiplas etapas de formul�rio e captura dados (nome + WhatsApp) em PostgreSQL via Supabase.

---

## Stack Tecnol�gica

| Camada | Tecnologia |
|---|---|
| Frontend | HTML/CSS/JavaScript vanilla (sem build step) |
| Backend/BaaS | Supabase (PostgreSQL, Auth, Realtime, Edge Functions) |
| Database | PostgreSQL 15 + pg_trgm + pgcrypto |
| Autentica��o | Supabase Auth (email/senha) |
| Realtime | Supabase Realtime (postgres_changes) com fallback polling |
| Gr�ficos | Chart.js (via CDN) |
| �cones | Inline SVG |
| Deploy | Netlify, Vercel, GitHub Pages, Cloudflare Pages |

---

## Estrutura do Projeto

```
oferta-relampago-fullstack/
+-- index.html                 # Landing page (~650 linhas)
+-- admin.html                 # Dashboard administrativo (~2860 linhas)
+-- supabase-setup.sql         # Schema + RLS + triggers + fun��es (~210 linhas)
+-- README.md                  # Documenta��o
+-- supabase/
    +-- functions/
        +-- email-notification/
        �   +-- index.ts        # Edge Function � notifica��o por email (stub)
        +-- whatsapp-webhook/
            +-- index.ts        # Edge Function � webhook WhatsApp (stub)
```

---

## Funcionalidades

### Landing Page (`index.html`)

#### ?? Experi�ncia Visual
- **Part�culas interativas** � canvas com 120 part�culas que reagem ao mouse (conex�es, cores adaptativas dark/light)
- **3D Tilt Card** � efeito parallax 3D no card principal ao mover o mouse (perspective + rotateX/Y)
- **Cursor customizado** � cursor neon laranja que segue o mouse
- **Tela de splash** � anima��o de loading com �cone do raio e barra de progresso
- **Micro-anima��es** � fade-in com stagger via CSS animations
- **Tema claro/escuro** � toggle com persist�ncia em localStorage

#### ?? Formul�rio Multi-etapas
- **Step 1:** Nome com valida��o
- **Step 2:** WhatsApp com formata��o autom�tica (DDD + m�scara)
- **Step 3:** Revis�o dos dados antes de confirmar
- **Barra de progresso** visual entre etapas
- **Indicador de etapas** (bolinhas) com estado active/done

#### ? Urg�ncia & Prova Social
- **Countdown fixo** � 15:45 regressivo, estilo "oferta rel�mpago"
- **Timer de pre�o** � "Oferta vai subir para R$ 200 em 15:00"
- **Indicador ao vivo** � "17 pessoas est�o vendo esta oferta" (simulado)
- **Carrossel de depoimentos** � 3 avalia��es rotativas com dots (5s)
- **Badges** � 60% OFF + Entrega Instant�nea

#### ?? Convers�o
- **Confetti** � chuva de 200 part�culas coloridas ao enviar formul�rio
- **Toast notifications** � feedback visual de sucesso/erro
- **Webhooks** � integra��o com n8n, Zapier, Make (opcional)

#### ? Acessibilidade Extrema
- `skip-link` para navega��o por teclado
- `aria-live` regions para leitores de tela
- `prefers-reduced-motion` � desativa TODAS as anima��es
- **Modo alto contraste** � toggle no header
- **A+/A-** � controle de tamanho da fonte com persist�ncia
- `focus-visible` outlines
- Roles ARIA (banner, progressbar, tablist, alert)

### Dashboard Admin (`admin.html`)

#### ?? Seguran�a
- **Autentica��o** � Supabase Auth com sess�o persistente
- **Rate limiting** � max 5 tentativas, lockout 30s
- **Session timeout** � logout autom�tico ap�s 30 min de inatividade (aviso 5 min antes)

#### ?? Analytics
- **Stats cards** � total, hoje, semana, m�s, em convers�o, taxa de convers�o, tempo m�dio
- **Compara��o temporal** � "? +5 vs ontem" com setas coloridas
- **Gr�fico de barras** � distribui��o por status (Chart.js responsivo)
- **Interactive chart** � clique nas barras para filtrar a tabela

#### ?? Gerenciamento de Leads
- **Tabela completa** � busca por nome/WhatsApp/notas, filtros por status (pills) e data
- **Ordena��o** � clicar no header para ordenar por data, nome ou status
- **Pagina��o** � 20 leads/p�gina com navega��o num�rica (ellipsis para muitos pages)
- **Sele��o em massa** � checkboxes, alterar status, exportar, excluir
- **Edi��o com notas** � modal com hist�rico de notas por lead
- **Skeleton loading** � shimmer effect enquanto carrega
- **Highlight de busca** � marca��o amarela nos resultados

#### ?? Kanban Board
- **Toggle Tabela/Kanban** � bot�o de altern�ncia no header da tabela
- **4 colunas** � Novo, Contatado, Convers�o, Perdido
- **Cards com score** � exibe lead_score quando dispon�vel
- **Clique para editar** � abre o modal de edi��o diretamente

#### ?? Productivity
- **Atalhos de teclado:**
  - `K` � alternar Kanban/Tabela
  - `/` � focar busca
  - `R` � recarregar dados
  - `E` � exportar CSV
  - `F` � tela cheia
  - `C` � limpar filtros
  - `?` � ajuda de atalhos
  - `Esc` � fechar modais
- **Filtros salvos** � salve combina��es de filtro com nome (localStorage)
- **Audit log** � visualizador de hist�rico de altera��es (INSERT, UPDATE, DELETE)

#### ?? Undo
- **Undo de exclus�o** � lead exclu�do pode ser restaurado em 8s via toast
- **Undo em lote** � exclus�o em massa tamb�m recuper�vel

#### ?? Notifica��es
- **Push notifications** � notifica��o do navegador para novos leads (permiss�o solicitada)
- **Realtime com fallback** � Supabase Realtime + polling 10s
- **Toasts melhorados** � �cone por tipo, barra de progresso, empilhamento

#### ?? UX
- **Tema escuro** � background com orbs animados, glassmorphism
- **Modo tela cheia** � via atalho F
- **Print stylesheet** � `@media print` para impress�o limpa
- **Responsivo** � adapta��o para mobile

### Banco de Dados (`supabase-setup.sql`)

#### ?? Schema
| Tabela | Descri��o |
|---|---|
| `leads` | Leads com soft delete, full-text search, lead scoring |
| `lead_notes` | Hist�rico de notas por lead |
| `lead_audit_log` | Auditoria completa (INSERT/UPDATE/DELETE) |
| `rate_limits` | Controle de taxa de inser��o |

#### ?? Seguran�a
- **Row Level Security (RLS)** � pol�ticas por role (anon/authenticated)
- **Check constraints** � `valid_name` (m�nimo 2 chars), `valid_whatsapp` (10-11 d�gitos)
- **Rate limiting trigger** � max 10 inserts/min por IP
- **Soft delete** � coluna `deleted_at`, view `leads_active`

#### ? Triggers
| Trigger | Fun��o |
|---|---|
| `update_leads_updated_at` | Atualiza `updated_at` automaticamente |
| `audit_leads` | Registra toda altera��o no `lead_audit_log` |
| `update_leads_search_vector` | Mant�m `search_vector` (full-text search) atualizado |
| `update_lead_score` | Calcula score automaticamente (0-100) |
| `rate_limit_before_insert` | Bloqueia inser��es acima do limite |

#### ?? Fun��es SQL
| Fun��o | Retorno |
|---|---|
| `get_lead_stats()` | total, hoje, semana, m�s, convers�o, taxa, tempo m�dio |
| `get_leads_per_day()` | leads por dia (�ltimos 30 dias) |
| `get_lead_insights()` | melhor hor�rio, melhor dia, top source, funil |
| `search_leads(text)` | full-text search com ranking |
| `bulk_update_status(ids[], status)` | update at�mico em transa��o |
| `soft_delete_leads(ids[])` | soft delete em lote |
| `hard_delete_leads(ids[])` | purge f�sico (admin) |
| `get_dashboard_stats()` | todas as stats em JSON |

#### ?? �ndices
- `gin_trgm_ops` para busca parcial por nome
- `GIN` para full-text search vector
- �ndices em `created_at`, `status`, `whatsapp`, `deleted_at`, `lead_score`, `source`

---

## Configura��o

### 1. Banco de Dados

1. Acesse o [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecione seu projeto
3. V� em **SQL Editor**
4. Execute o conte�do de `supabase-setup.sql`

### 2. Credenciais

```
SUPABASE_URL:      https://qazpfaafpbrzhsnviuht.supabase.co
SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Edite as constantes em `index.html` e `admin.html` (se��o `CONFIGURATION`).

### 3. Admin

Use o Supabase Auth para gerenciar administradores:
1. Acesse **Authentication > Users**
2. Adicione usu�rio: **admin@oferta.com** / **admin123**

### 4. Webhooks (Opcional)

```javascript
const WEBHOOK_WHATSAPP_URL = 'https://hook.us1.make.com/xxx';
const WEBHOOK_EMAIL_URL    = 'https://formspree.io/f/xxx';
```

### 5. Edge Functions

```bash
supabase functions deploy email-notification
supabase functions deploy whatsapp-webhook
```

---

## API & Edge Functions

### Edge Functions (Stubs)

| Function | Trigger | Payload |
|---|---|---|
| `email-notification` | INSERT on leads | `{ name, whatsapp, product, source }` |
| `whatsapp-webhook` | INSERT on leads | `{ name, whatsapp, product, source }` |

### Fun��es SQL (chamadas via Supabase JS)

```javascript
const { data } = await supabaseClient.rpc('get_dashboard_stats');
const { data } = await supabaseClient.rpc('search_leads', { search_text: 'jo�o' });
const { data } = await supabaseClient.rpc('bulk_update_status', { lead_ids: [...], new_status: 'conversao' });
const { data } = await supabaseClient.rpc('soft_delete_leads', { lead_ids: [...] });
```

---

## Changelog

### v1.1 � "Absurd Mode" (2026-06-12)
- ? Part�culas interativas com mouse tracking
- ? 3D Tilt Card com perspectiva
- ? Formul�rio multi-etapas com barra de progresso
- ? Confetti ao converter lead
- ? Carrossel de depoimentos (prova social)
- ? Indicador "ao vivo" de visitantes
- ? Splash screen com anima��o
- ? Cursor neon customizado
- ? Modo alto contraste + controle de fonte
- ? Kanban Board (toggle tabela/kanban)
- ? Atalhos de teclado (K, /, R, E, F, C, ?)
- ? Filtros salvos (localStorage)
- ? Undo de exclus�o (8s para restaurar)
- ? Audit log viewer
- ? Push notifications para novos leads
- ? Compara��o temporal nos stats
- ? Tela cheia via atalho
- ? Print stylesheet
- ? Soft delete + view leads_active
- ? Full-text search vector + fun��o search_leads()
- ? Lead scoring autom�tico (0-100)
- ? Auditoria completa (lead_audit_log)
- ? Rate limiting no banco (10 inserts/min)
- ? Fun��o bulk_update_status transacional
- ? Fun��o get_lead_insights() com m�tricas avan�adas
- ? Fun��o get_dashboard_stats() � tudo em uma chamada

### v1.0 � Release Inicial
- Landing page com captura de leads
- Dashboard admin com autentica��o
- CRUD de leads + notas
- Import/export CSV
- Gr�ficos Chart.js
- Realtime com Supabase

---

## Troubleshooting

| Problema | Solu��o |
|---|---|
| `pg_trgm` n�o encontrado | Execute `CREATE EXTENSION IF NOT EXISTS pg_trgm;` |
| Erro 401 no login | Verifique as credenciais Supabase em `CONFIGURATION` |
| Realtime n�o conecta | Verificar se `ALTER PUBLICATION supabase_realtime ADD TABLE leads;` foi executado |
| Leads n�o aparecem | Verificar RLS policies � anon pode INSERT, authenticated pode SELECT |
| Audit log vazio | A trigger `audit_leads` s� captura a��es ap�s sua cria��o |

---

## Contribui��o

1. Fork o projeto
2. Crie sua branch: `git checkout -b feat/minha-feature`
3. Commit: `git commit -m 'feat: descri��o'`
4. Push: `git push origin feat/minha-feature`
5. Abra um Pull Request

---

## Licen�a

MIT � Oferta Rel�mpago
