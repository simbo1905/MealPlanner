# Quick Start Guide

## 1. Setup Environment

```bash
# Install mise tools (bun, node)
mise install

# Add API keys to .env in project root
# Edit .env and add:
MISTRAL_API_KEY=your_actual_key_here
GROQ_API_KEY=your_actual_key_here
```

## 2. Install Dependencies

```bash
# From project root
just promptfoo --version

# This will auto-install promptfoo via bun on first run
```

## 3. Run Evaluation

```bash
# From project root
just promptfoo eval
```

## 4. View Results

```bash
# Interactive web UI
just promptfoo view

# Or export to HTML
just promptfoo eval --output results.html
```

## Troubleshooting

**Missing API keys:**
- Check `.env` in project root (NOT in promptfoo/)
- Keys are loaded via `${MISTRAL_API_KEY}` and `${GROQ_API_KEY}`

**Bun/Node not found:**
- Run `mise install` from project root
- Verify with `mise which bun` and `mise which node`

**Dependencies not installed:**
- First run of `just promptfoo` auto-installs via `bun install`
- Or manually: `cd promptfoo && bun install`

## Expected Results

Each test will show:
- ✅ **Pass** - Valid JSON, correct schema, good extraction quality
- ❌ **Fail** - Schema violations, missing titles, poor quality

Models ranked by:
1. Schema compliance (hard-fail)
2. LLM-graded semantic quality (0-1 score, target ≥0.85)

Winner = smallest model with ≥85% average quality score.
