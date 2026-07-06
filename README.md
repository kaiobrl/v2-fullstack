# V2 Fullstack - Sistema de Captura de Leads

Sistema completo de captura e gestao de leads com catalogo de produtos, landing pages dinamicas e painel administrativo.

## Stack

- **Frontend:** HTML/CSS/JS vanilla (sem framework, sem build tools)
- **Backend:** Supabase (PostgreSQL + Auth + Realtime + Edge Functions)
- **Banco:** 5 tabelas, triggers, funcoes stored, RLS, full-text search

## Estrutura

```
├── index.html           # Landing page dinamica (aceita ?product=ID)
├── catalogo.html        # Catalogo de produtos
├── admin.html           # Dashboard administrativo
├── supabase-setup.sql   # Schema completo do banco de dados
└── supabase/
    └── functions/
        ├── whatsapp-webhook/index.ts    # Edge Function (stub)
        └── email-notification/index.ts  # Edge Function (stub)
```

## Funcionalidades

### Catalogo (`catalogo.html`)
- Grid de produtos buscados do Supabase
- Cards com imagem, preco, badge de desconto
- Botao "Quero esse!" redireciona para a landing page do produto

### Landing Page (`index.html`)
- Exibe produto especifico via `?product={uuid}`
- Formulario multi-step (nome → WhatsApp → revisao)
- Validacao de telefone brasileiro
- Timer de contagem regressiva e indicadores de urgencia
- Confetti no sucesso
- Dark mode e particulas animadas

### Admin (`admin.html`)
- Login com Supabase Auth
- Dashboard com stats e grafico (Chart.js)
- Tabela com filtros por status, produto, busca e data
- Visualizacao Kanban
- Edicao de leads com sistema de notas
- Importacao/Exportacao CSV
- Sistema de undo para exclusoes
- Realtime com fallback para polling
- Atalhos de teclado

## Produtos

| Produto | Preco | Descricao |
|---------|-------|-----------|
| Paginas HTML & CSS | R$80 | Paginas estaticas profissionais |
| Landing Pages | R$150 | Paginas de conversao otimizadas |
| Sistemas Web | R$300 | Sistemas completos com CRUD e dashboard |

## Setup

1. Acesse o Supabase Dashboard
2. Execute o conteudo de `supabase-setup.sql` no SQL Editor
3. Faca deploy dos arquivos HTML em qualquer hosting estatico (Vercel, Netlify, GitHub Pages)
4. Acesse `catalogo.html` para ver o catalogo
5. Acesse `admin.html` para o painel administrativo

## Variaveis

As credenciais do Supabase estao hardcoded nos arquivos HTML (padrao para Supabase client-side com RLS).

Para configurar webhooks (opcional), edite as variaveis no `index.html`:
```javascript
var WEBHOOK_WHATSAPP_URL = '';
var WEBHOOK_EMAIL_URL = '';
```
