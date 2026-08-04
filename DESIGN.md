# UNIQ Consultoria — Design System (DESIGN.md)

> Formato Stitch — para agentes de IA gerarem UI consistente na Base UNIQ.
> Última atualização: 01/08/2026

---

## 1. Visual Theme & Atmosphere

### Mood
**Tecnologia capaz, conversa humana.** A Base UNIQ deve parecer um cockpit profissional que qualquer empreendedor de Suzano consegue usar sem medo. O visual é sóbrio e corporativo, mas a presença da Melissa traz calor humano.

### Sensação
- **Profissional, não frio.** A sidebar escura e os cards limpos transmitem seriedade de ERP. O verde menta e o avatar da Melissa impedem que pareça um banco ou sistema burocrático.
- **Confiante, não arrogante.** As superfícies são organizadas, os espaçamentos generosos, as sombras suaves. Não há ruído visual, brilhos desnecessários ou elementos "tech for tech's sake".
- **Local, não genérico.** A paleta de verde petróleo + menta foge do azul corporativo padrão. A experiência parece feita para o dono da loja de Suzano, não para um escritório de São Paulo.

### Densidade
- **Média-baixa.** O conteúdo é organizado em cards respiráveis. A sidebar é densa (navegação completa), mas a área de conteúdo é arejada.
- Telas de métricas e dashboard priorizam clareza sobre quantidade de informação.
- Telas de chat com a Melissa são espaçadas, simulando uma conversa real.

### Filosofia de design
> "A Base UNIQ não parece um SaaS genérico. Ela parece uma central de operações que cabe no bolso do empreendedor."

Cada elemento visual existe para reduzir atrito e aumentar confiança. Nada é decorativo sem função.

---

## 2. Color Palette & Roles

### Cores oficiais (extraídas dos ativos em `docs/design/`)

| Token | Hex | Nome | Função |
|-------|-----|------|--------|
| `--color-grafite` | `#1F2937` | Grafite escuro | Sidebar, textos principais, headers de tabela, títulos |
| `--color-petroleo` | `#3E5653` | Verde petróleo | Cor corporativa, elementos de marca, bordas de destaque, links |
| `--color-cinza-verde` | `#627271` | Cinza esverdeado | Textos secundários, labels, placeholders, bordas de cards |
| `--color-menta` | `#86CB92` | Verde menta | CTAs primários, botões, indicadores de sucesso, gráficos positivos, badges ativos, destaque da Melissa |
| `--color-cinza-claro` | `#EFEFEF` | Cinza claro | Fundo de página, superfícies de cards, áreas de conteúdo |

### Cores estendidas (derivadas)

| Token | Hex | Função |
|-------|-----|--------|
| `--color-grafite-light` | `#2D3A48` | Sidebar hover, sub-menus |
| `--color-grafite-dark` | `#111827` | Sidebar ativo, overlays |
| `--color-petroleo-light` | `#4A6B67` | Hover de links, bordas de input focus |
| `--color-menta-light` | `#A3DBAE` | Hover de botões primários |
| `--color-menta-dark` | `#6BB87A` | Active/pressed de botões primários |
| `--color-white` | `#FFFFFF` | Cards, superfícies elevadas, texto sobre fundo escuro |
| `--color-danger` | `#E57373` | Erros, alertas críticos, indicadores negativos |
| `--color-warning` | `#F0C75E` | Alertas moderados, atenção |
| `--color-surface` | `#F5F5F5` | Fundo de inputs, áreas secundárias |

### Regras de uso
- **Nunca** use verde menta em fundos grandes — ele é cor de ação e destaque, não de superfície.
- **Nunca** use verde petróleo em textos longos — reserve para headlines curtas e elementos de marca.
- O cinza claro (`#EFEFEF`) é o fundo padrão. Cards e superfícies elevadas usam `#FFFFFF`.
- Texto sobre sidebar escura: sempre `#FFFFFF` com opacidade 80% para secundário, 100% para primário.

---

## 3. Typography Rules

### Fontes (Google Fonts)

| Uso | Fonte | Weight | Detalhes |
|-----|-------|--------|----------|
| **Headings / Títulos** | Plus Jakarta Sans | 600 (Semibold), 700 (Bold) | Geométrica, moderna, combina com a geometria do logo. Passa seriedade sem rigidez. |
| **Body / Textos corridos** | Inter | 400 (Regular), 500 (Medium) | Limpa, altamente legível em dashboards. Funciona bem em cards, tabelas e labels. |
| **Display / Números grandes** | Plus Jakarta Sans | 700 (Bold) | Métricas, KPIs, valores em destaque |
| **Monospace / Dados técnicos** | JetBrains Mono | 400 (Regular) | Código, timestamps, IDs, dados estruturados |

### Hierarquia tipográfica

| Elemento | Tamanho | Weight | Line Height | Tracking | Cor |
|----------|---------|--------|-------------|----------|-----|
| H1 — Título de página | 2rem (32px) | 700 | 1.2 | -0.02em | `#1F2937` |
| H2 — Título de seção | 1.5rem (24px) | 600 | 1.3 | -0.01em | `#1F2937` |
| H3 — Título de card | 1.125rem (18px) | 600 | 1.4 | 0 | `#1F2937` |
| Body — Texto padrão | 0.875rem (14px) | 400 | 1.5 | 0 | `#1F2937` |
| Body small — Labels | 0.75rem (12px) | 400 | 1.4 | 0 | `#627271` |
| Caption — Auxiliar | 0.625rem (10px) | 400 | 1.3 | 0.02em | `#627271` |
| KPI / Métrica | 2.25rem (36px) | 700 | 1.1 | -0.03em | `#1F2937` |
| KPI label | 0.75rem (12px) | 500 | 1.3 | 0.04em | `#627271` |

### Regras tipográficas
- **Body nunca abaixo de 14px** em telas desktop (acessibilidade).
- Tracking (letter-spacing) negativo apenas em títulos grandes para compactar.
- Textos secundários sempre em cinza esverdeado (`#627271`).
- Links em verde petróleo (`#3E5653`), hover com underline.

---

## 4. Component Stylings

### 4.1 Botões

#### Botão Primário (CTA principal)
```
Fundo: #86CB92 (verde menta)
Texto: #FFFFFF, Plus Jakarta Sans 600, 14px
Padding: 10px 20px
Border-radius: 8px
Shadow: 0 2px 4px rgba(134, 203, 146, 0.3)
Hover: fundo #A3DBAE, shadow intensifica
Active: fundo #6BB87A
Disabled: opacidade 50%, sem shadow
Ícone: opcional à esquerda, 16px
```
**Uso:** "Conversar com Melissa", "Ativar módulo", "Salvar", "Avançar", "Confirmar"

#### Botão Secundário (ação alternativa)
```
Borda: 1px solid #3E5653
Texto: #3E5653, Plus Jakarta Sans 500, 14px
Fundo: transparente
Padding: 10px 20px
Border-radius: 8px
Hover: fundo rgba(62, 86, 83, 0.06)
Active: fundo rgba(62, 86, 83, 0.12)
```
**Uso:** "Cancelar", "Voltar", "Ver detalhes"

#### Botão Ghost (ação leve)
```
Texto: #627271, Inter 400, 14px
Fundo: transparente
Padding: 8px 16px
Border-radius: 8px
Hover: fundo rgba(0,0,0,0.04)
```
**Uso:** "Fechar", "Remover", ações de linha em tabelas

### 4.2 Cards

#### Card de Métrica (dashboard)
```
Fundo: #FFFFFF
Border-radius: 12px
Padding: 20px 24px
Shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)
Ícone: 24px, cor semântica (menta para positivo, danger para negativo)
Valor: Plus Jakarta Sans 700, 2.25rem, #1F2937
Label: Inter 400, 0.75rem, #627271
Variação: texto pequeno com seta (↑ #86CB92 / ↓ #E57373)
```
**Exemplo visual:**
```
┌──────────────────────┐
│  📊                  │
│  47                   │  ← KPI grande
│  Leads esta semana    │  ← label
│  ↑ 12% desde ontem   │  ← variação em verde menta
└──────────────────────┘
```

#### Card de Conteúdo (módulos, configurações)
```
Fundo: #FFFFFF
Border-radius: 12px
Padding: 24px
Shadow: 0 1px 3px rgba(0,0,0,0.06)
Título: H3 (18px, 600, #1F2937)
Corpo: Body (14px, 400, #1F2937)
Footer opcional: separador 1px solid #EFEFEF, padding-top 16px
```

#### Card de Módulo (com status)
```
Card base + badge de status no topo direito
Badge ativo: fundo #86CB92, texto #FFFFFF, 11px, border-radius 4px, padding 2px 8px
Badge inativo: fundo #EFEFEF, texto #627271, 11px, border-radius 4px, padding 2px 8px
Ícone do módulo: 32px, cor #3E5653
```

### 4.3 Inputs & Formulários

```
Label: Inter 500, 14px, #627271, margin-bottom 6px
Campo: Inter 400, 14px, #1F2937
Fundo: #F5F5F5 (ou #FFFFFF com borda)
Borda: 1px solid #EFEFEF
Border-radius: 8px
Padding: 10px 14px
Focus: borda 1px solid #3E5653, ring 2px rgba(62, 86, 83, 0.15)
Placeholder: #627271, opacidade 60%
Erro: borda #E57373, mensagem em 12px #E57373
Ícone prefixo: 16px, #627271, padding-left 12px
```

### 4.4 Navegação (Sidebar)

```
Fundo: #1F2937 (grafite escuro)
Largura: 240px (desktop), 64px (collapsed)
Padding: 24px 16px
Logo no topo: 32px de altura, centralizado ou alinhado à esquerda

Itens de navegação:
  - Padding: 10px 12px
  - Border-radius: 8px
  - Ícone: 20px, #FFFFFF opacidade 60%
  - Texto: Inter 500, 14px, #FFFFFF opacidade 80%
  - Hover: fundo rgba(255,255,255,0.06)
  - Ativo: fundo #86CB92 com opacidade 15%, ícone e texto #86CB92
  - Espaçamento entre grupos: 16px

Avatar do parceiro no rodapé:
  - Foto 32px, border-radius 50%
  - Nome: Inter 500, 14px, #FFFFFF
  - Email: Inter 400, 12px, #FFFFFF opacidade 60%
```

### 4.5 Badges & Tags

| Tipo | Fundo | Texto | Uso |
|------|-------|-------|-----|
| Sucesso / Ativo | `#86CB92` | `#FFFFFF` | Módulo ativo, lead qualificado, tarefa concluída |
| Inativo / Pendente | `#EFEFEF` | `#627271` | Módulo desativado, lead frio |
| Alerta | `#F0C75E` | `#1F2937` | Atenção, revisão necessária |
| Erro | `#E57373` | `#FFFFFF` | Falha, bloqueio, urgente |
| Informativo | `#3E5653` | `#FFFFFF` | Tag de versão, categoria |

```
Padding: 2px 10px
Border-radius: 999px (pill)
Font: Inter 500, 11px
Line height: 20px
```

### 4.6 Chat — Mensagens da Melissa

#### Bolha da Melissa (lado esquerdo)
```
Fundo: #FFFFFF
Borda esquerda: 3px solid #86CB92
Border-radius: 4px 16px 16px 16px
Padding: 12px 16px
Max-width: 75%
Shadow: 0 1px 2px rgba(0,0,0,0.04)
Font: Inter 400, 14px, #1F2937
Avatar: 32px, border-radius 50%, imagem da Melissa (docs/design/MELISSA (2).png)
Timestamp: Inter 400, 11px, #627271, abaixo da bolha
```

#### Bolha do Parceiro (lado direito)
```
Fundo: #3E5653
Border-radius: 16px 4px 16px 16px
Padding: 12px 16px
Max-width: 75%
Font: Inter 400, 14px, #FFFFFF
```

#### Indicador "Melissa está digitando"
```
Ícone animado (3 bolinhas pulsando em #86CB92)
Texto: Inter 400, 12px, #627271
```

#### Input de chat
```
Fundo: #FFFFFF
Borda: 1px solid #EFEFEF
Border-radius: 24px
Padding: 10px 16px
Ícone de envio: #86CB92, 20px, hover escala 1.05
Placeholder: "Digite sua mensagem..."
```

### 4.7 Avatar da Melissa

**Onde usar:**
1. **Header do chat** — avatar grande (48px) + nome "Melissa" + status "Online" em verde menta
2. **Bolha de mensagem** — avatar pequeno (32px) ao lado de cada mensagem da Melissa
3. **Perfil do assistente** — avatar médio (64px) com badge "Parceiro Digital"
4. **Onboarding / boas-vindas** — avatar ilustrativo (80px) centralizado
5. **Ícone de notificação** — versão miniatura (24px) com bolinha de status

**Arquivos:**
- `docs/design/MELISSA.png` — corpo completo (uso: splash, onboarding, tela de boas-vindas)
- `docs/design/MELISSA (2).png` — rosto/avatar (uso: chat, perfil, notificações)

**Tratamento visual:**
- Sempre com border-radius 50% para o rosto
- Leve sombra sutil (0 2px 4px rgba(0,0,0,0.1)) quando usado em destaque
- Acompanhado do nome "Melissa" e indicador de status (Online/Offline)

### 4.8 Tabelas (CRM, dados)

```
Header: Inter 600, 12px, #627271, uppercase, tracking 0.04em
Células: Inter 400, 14px, #1F2937
Borda horizontal: 1px solid #EFEFEF
Padding: 12px 16px
Hover row: fundo rgba(62, 86, 83, 0.03)
Striped: opcional, linhas pares com fundo #F9F9F9
Ações: ícones ghost (20px, #627271, hover #1F2937)
```

---

## 5. Layout Principles

### Grid
- **12 colunas** para layout de página
- **Gutter:** 24px
- **Margin lateral:** 24px (desktop), 16px (mobile)
- Cards de métrica ocupam 3 colunas (4 por linha) ou 4 colunas (3 por linha)

### Espacamento (escala)

| Token | Valor | Uso |
|-------|-------|-----|
| `--space-xs` | 4px | Micro-ajustes, ícones |
| `--space-sm` | 8px | Entre elementos próximos |
| `--space-md` | 16px | Entre componentes relacionados |
| `--space-lg` | 24px | Entre seções, padding de cards |
| `--space-xl` | 32px | Entre seções grandes |
| `--space-2xl` | 48px | Margens de página, separação de áreas |

### Whitespace
- Conteúdo principal com padding mínimo de 24px das bordas.
- Entre seções de uma mesma página: 32px.
- Entre página e sidebar: 0 (sidebar é colada na borda esquerda).
- Chat com a Melissa: padding generoso (32px) para simular espaço de conversa.

### Estrutura de página padrão
```
┌─────────────┬────────────────────────────────────┐
│  Sidebar    │  Header (opcional)                  │
│  #1F2937    │  breadcrumb + notificações + avatar │
│  240px      ├────────────────────────────────────┤
│             │  Conteúdo principal                 │
│             │  #EFEFEF                            │
│             │  Cards / Chat / Tabelas             │
│             │                                     │
│             │                                     │
└─────────────┴────────────────────────────────────┘
```

---

## 6. Depth & Elevation

### Sistema de sombras

| Nível | Uso | Shadow |
|-------|-----|--------|
| 0 | Superfície plana (fundo) | Nenhuma |
| 1 | Cards padrão, inputs | `0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)` |
| 2 | Cards hover, dropdowns | `0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.04)` |
| 3 | Modais, popovers | `0 10px 25px rgba(0,0,0,0.12), 0 4px 10px rgba(0,0,0,0.06)` |
| 4 | Toast, notificações flutuantes | `0 20px 40px rgba(0,0,0,0.15)` |

### Hierarquia de superfícies
1. **Fundo da página** — `#EFEFEF`, sem elevação
2. **Cards e containers** — `#FFFFFF`, elevação 1
3. **Sidebar** — `#1F2937`, sem sombra (plana na borda)
4. **Modais e overlays** — `#FFFFFF`, elevação 3, backdrop com `rgba(31, 41, 55, 0.5)`
5. **Notificações** — elevação 4, destaque máximo

---

## 7. Do's and Don'ts

### ✅ Do's
- **Use verde menta com moderação.** Ele é o destaque — uma cor de CTA por tela no máximo.
- **Mantenha a sidebar escura.** Ela ancora a identidade visual e contrasta com o conteúdo claro.
- **Sempre mostre a Melissa no chat.** O avatar dela é o elemento humano que diferencia a Base UNIQ de um SaaS genérico.
- **Use espaço negativo generoso.** O empreendedor de Suzano não é power user — informação respira.
- **Prefira cards a listas.** Cards são mais escaneáveis e menos intimidantes.
- **Ícones consistentes.** Use um conjunto único (Lucide ou Phosphor), todos outline, 20px padrão.
- **Feedback visual em toda ação.** Hover, active, loading, success — cada interação deve ser percebida.

### ❌ Don'ts
- **Não use verde menta como fundo.** Ele queima a retina em grandes áreas.
- **Não use branco puro como fundo de página.** O contraste com a sidebar fica agressivo. Use `#EFEFEF`.
- **Não coloque mais de 4 cards de métrica por linha.** O empreendedor precisa absorver um número de cada vez.
- **Não use jargão técnico na UI.** "Webhook", "API", "token" nunca aparecem para o parceiro.
- **Não remova o avatar da Melissa do chat.** Ela é a cara da plataforma.
- **Não use animações decorativas.** Só animação com função: loading, transição de estado, feedback.
- **Não use fontes muito leves (weight < 400).** Legibilidade em telas de escritório é prioridade.
- **Não crie modais dentro de modais.** A profundidade máxima é 2 níveis.

---

## 8. Responsive Behavior

### Breakpoints

| Nome | Largura | Comportamento |
|------|---------|---------------|
| Mobile | < 640px | Sidebar colapsa em bottom nav ou drawer. Cards em 1 coluna. Chat ocupa tela cheia. |
| Tablet | 640px - 1024px | Sidebar colapsável (64px, só ícones). Cards em 2 colunas. |
| Desktop | > 1024px | Sidebar expandida (240px). Cards em 3-4 colunas. Layout completo. |

### Sidebar em mobile
- Transforma-se em **bottom navigation** com 5 ícones principais.
- Menu completo acessível por ícone "hamburger" no topo.
- Avatar da Melissa vira FAB (Floating Action Button) no canto inferior direito para acesso rápido ao chat.

### Touch targets
- **Mínimo 44x44px** para todos os elementos clicáveis em mobile.
- Botões em mobile: padding aumentado para 14px 24px.
- Inputs em mobile: altura mínima de 48px.

### Chat responsivo
- Desktop: bolhas com max-width 75%, sidebar visível.
- Mobile: bolhas com max-width 85%, sidebar oculta, header fixo com nome da Melissa.

---

## 9. Agent Prompt Guide

> Copie e cole este bloco no início de qualquer prompt para gerar UI da Base UNIQ.

```
Você está gerando UI para a Base UNIQ, plataforma de Transformação Digital para microempresas.
Siga o Design System abaixo:

CORES:
- Sidebar/Textos: #1F2937 (Grafite escuro)
- Marca/Destaque: #3E5653 (Verde petróleo)
- Secundário/Bordas: #627271 (Cinza esverdeado)
- CTAs/Ação: #86CB92 (Verde menta) — USAR COM MODERAÇÃO
- Fundo página: #EFEFEF (Cinza claro)
- Cards: #FFFFFF
- Erro: #E57373 | Alerta: #F0C75E

FONTES:
- Títulos: Plus Jakarta Sans 600/700
- Corpo: Inter 400/500
- Números/métricas: Plus Jakarta Sans 700
- Código/dados: JetBrains Mono 400

COMPONENTES PRINCIPAIS:
- Botão primário: fundo #86CB92, texto branco, radius 8px
- Botão secundário: borda #3E5653, texto #3E5653, fundo transparente, radius 8px
- Cards: fundo branco, radius 12px, shadow sutil (0 1px 3px rgba(0,0,0,0.06))
- Sidebar: fundo #1F2937, 240px, itens com hover rgba(255,255,255,0.06), ativo com #86CB92
- Chat Melissa: bolha esquerda branca com borda #86CB92, bolha parceiro #3E5653
- Inputs: fundo #F5F5F5, radius 8px, focus borda #3E5653
- Badges: pill shape, sucesso #86CB92, inativo #EFEFEF

LAYOUT:
- Sidebar esquerda + conteúdo à direita
- Grid 12 colunas, gutter 24px
- Espaçamento generoso (padding mínimo 24px)
- Cards de métrica: 3-4 por linha no desktop

MELISSA:
- Avatar rosto: docs/design/MELISSA (2).png (border-radius 50%)
- Avatar corpo: docs/design/MELISSA.png (tela cheia/onboarding)
- Presente em todo chat, perfil do assistente, onboarding
- Tom de voz: próxima, direta, capaz, motivadora

REGRAS:
- NUNCA use verde menta como fundo
- NUNCA use jargão técnico na UI
- NUNCA coloque mais de 4 cards de métrica por linha
- SEMPRE mostre o avatar da Melissa no chat
- Prefira cards a listas
- Feedback visual em toda interação
```

---

## Apêndice: Ativos visuais

| Arquivo | Caminho | Uso |
|---------|---------|-----|
| Logo UNIQ | `docs/design/Logo.png` | Header da sidebar, loading screen, login |
| Paleta de cores | `docs/design/UNIQ.png` | Referência visual das cores oficiais |
| Melissa (corpo) | `docs/design/MELISSA.png` | Splash, onboarding, tela de boas-vindas |
| Melissa (rosto) | `docs/design/MELISSA (2).png` | Chat, perfil, notificações, avatar |
| Tela modelo | `docs/design/Tela_modelo.png` | Referência de layout/dashboard |

---

*Este documento é a fonte da verdade para toda UI gerada por agentes de IA na Base UNIQ. Qualquer desvio deve ser aprovado pelo fundador.*
