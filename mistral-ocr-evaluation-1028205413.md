# Mistral OCR Evaluation - Task Summary

## Objective
Create a promptfoo test harness to evaluate 4 Mistral models (tiny/small/medium/devstral-latest) on OCR recipe title extraction, using GROQ API for grading.

## Implementation Status
- **Overall:** Complete with debugging phase ongoing
- **Configuration:** All files created and structure in place
- **Testing:** Partial success; identified critical bug in promptfoo

## Files Created

### Core Promptfoo Configuration
- `promptfoo/promptfooconfig.yaml` - Main evaluation config with 4 Mistral providers and 12 test cases
- `promptfoo/system_prompt.txt` - Extraction rules for Mistral models
- `promptfoo/package.json` - Bun package dependencies (promptfoo@^0.119.0)
- `promptfoo/.gitignore` - Excludes node_modules, results, logs

### Test Configurations (for debugging)
- `promptfoo/promptfooconfig.hello-hardcoded.yaml` - Works (no variables, hardcoded key)
- `promptfoo/promptfooconfig.hello-envvar.yaml` - Works (no variables, $MISTRAL_API_KEY)
- `promptfoo/promptfooconfig.hello-system.yaml` - Works (system role, no variables)
- `promptfoo/promptfooconfig.hello.yaml` - Works (simple test)

### Documentation
- `promptfoo/README.md` - Full usage guide
- `promptfoo/QUICKSTART.md` - Setup instructions
- `promptfoo/TEST_CASES.md` - Detailed test specifications (12 cases, 4 tiers)

### Integration Files
- `scripts/promptfoo.sh` - Launcher script with environment setup
- `mise.toml` - Updated with `bun@1.1.0` and `node@20`
- `justfile` - Added `promptfoo +args` recipe
- `.env.example` - API key template

## Test Suite Configuration

### Structure
- **4 Mistral Providers:** tiny, small, medium, devstral-latest
- **12 Test Cases:** 3 clean + 4 moderate + 3 heavy + 2 edge cases
- **Assertions:**
  - Hard-fail: JSON schema validation (array with title/score)
  - Hard-fail: No empty strings, scores 0-1 range
  - LLM-graded: GROQ llama-3.3-70b-versatile quality check

### Expected Outputs
- Each test returns JSON array: `[{"title": "string", "score": 0.0-1.0}]`
- Empty results: `[]` (not sentinel objects)
- Subjective adjectives stripped (Quick, Easy, Delicious, Best)

## Critical Issues Discovered

### Bug: Template Variables Break API Authentication
**Symptom:** Prompts with `{{variable}}` template substitution fail with "Unauthorized"

**Evidence:**
- ✅ Works: Static prompts without variables
- ❌ Fails: Prompts using `{{ocr_text}}` or similar template variables
- ✅ Confirmed: API key is valid (curl test successful)
- ✅ Confirmed: Environment variable loading works (export statements added)

**Root Cause:** Appears to be a bug in promptfoo 0.119.0 where template variable expansion breaks provider authentication context

**Tests Validating Bug:**
- `promptfooconfig.hello-system.yaml` → PASS (no variables)
- `promptfooconfig.hello-var.yaml` → FAIL (uses `{{message}}`)
- `promptfooconfig.hello-envvar.yaml` → PASS (no variables)

## Environment & Authentication

### API Keys Required
- `MISTRAL_API_KEY` - Mistral API key (verified working with curl)
- `GROQ_API_KEY` - GROQ API key for grading

### Environment Variable Handling
- `.env` file in project root loads both keys
- Script exports variables: `export MISTRAL_API_KEY GROQ_API_KEY`
- Syntax: `$MISTRAL_API_KEY` (not `${MISTRAL_API_KEY}`)
- Location matters: `.env` in promptfoo/ also works

### Verified Working
- Direct API calls with curl succeed
- Hello world tests without variables pass at 100%
- System role messages work correctly
- Environment variable substitution (without template variables)

## Scripts & Infrastructure

### scripts/promptfoo.sh
- Loads `.env` from project root
- Validates API keys before execution
- Sources `_ensure_env.sh` for bun/node setup
- Exports variables explicitly for bun context
- Auto-installs dependencies on first run

### Integration with justfile
```bash
just promptfoo eval              # Run evaluation
just promptfoo view              # View results web UI
just promptfoo eval --output ... # Export HTML report
```

## Next Steps

### To Fix Template Variable Bug
1. Downgrade promptfoo to earlier version (e.g., 0.100.0)
2. Report bug to promptfoo maintainers
3. Implement workaround (e.g., nested configs without vars)

### To Run Full Evaluation
1. Ensure `.env` has valid API keys
2. Resolve template variable authentication issue
3. Execute: `just promptfoo eval`
4. View: `just promptfoo view`

## Debugging Commands

### Test API Key
```bash
curl -s -X POST "https://api.mistral.ai/v1/chat/completions" \
  -H "Authorization: Bearer YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"mistral-tiny-latest","messages":[{"role":"user","content":"Hi"}],"max_tokens":10}'
```

### Test Simple Config
```bash
sh ./scripts/promptfoo.sh eval -c promptfooconfig.hello-hardcoded.yaml
```

### Check Environment Variables
```bash
cd promptfoo && env | grep -E "MISTRAL_API_KEY|GROQ_API_KEY"
```

## Current State Summary

**Working:**
- File structure complete
- Integration scripts functional
- Environment setup automated
- API keys validated independently
- Simple prompts (without variables) execute successfully

**Blocked:**
- Full 12-case evaluation blocked by template variable bug
- Cannot use `{{ocr_text}}` variables without breaking auth

**Action Items:**
1. Resolve promptfoo template variable authentication issue
2. Run full evaluation suite
3. Collect model comparison results
4. Identify best model (target: ≥85% LLM-graded score)
