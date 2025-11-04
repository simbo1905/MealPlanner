# Mistral OCR Evaluation - Promptfoo Test Suite

Evaluates 4 Mistral models on OCR recipe title extraction tasks using GROQ for grading.

## Setup

1. Install tools via mise:
```bash
mise install
```

2. Copy `.env.example` to `.env` and add your API keys:
```bash
# In project root
MISTRAL_API_KEY=your_mistral_api_key_here
GROQ_API_KEY=your_groq_api_key_here
```

## Models Under Test

- `mistral-tiny-latest` - Smallest, fastest
- `mistral-small-latest` - Balanced
- `mistral-medium-latest` - Most capable
- `devstral-latest` - Development-optimized

## Test Suite (12 cases)

**Tier 1 - Clean Text (3 tests)**
- Recipe headers, handwritten notes, formatted recipes

**Tier 2 - Moderate Noise (4 tests)**
- Website navigation, multiple meals, subjective descriptors, orientation artifacts

**Tier 3 - Heavy Noise (3 tests)**
- Dense metadata, corrupted spacing, fragmented text

**Tier 4 - Edge Cases (2 tests)**
- No recognizable titles, empty input

## Expected Output Format

All models must return valid JSON:
```json
[
  {"title": "Spaghetti Bolognese", "score": 0.95},
  {"title": "Chicken Tikka Masala", "score": 0.72}
]
```

Empty results: `[]` (not sentinel objects)

## Validation

**Hard-fail checks:**
- Valid JSON array schema
- No empty title strings
- Scores in 0-1 range

**LLM grading (GROQ llama-3.3-70b-versatile):**
- Actual recipe names extracted (not metadata)
- Subjective adjectives stripped (Quick, Easy, Delicious, Best)
- Confidence scores match text quality
- Empty array for no valid titles

## Usage

Run evaluation:
```bash
just promptfoo eval
```

View results:
```bash
just promptfoo view
```

Export report:
```bash
just promptfoo eval --output results.html
```

## Success Metrics

- Pass threshold: ≥85% on LLM-graded rubric
- Winner: Smallest model achieving pass threshold
- Expected ranking: medium ≥ devstral > small > tiny

## File Structure

```
promptfoo/
├── promptfooconfig.yaml      # Main configuration
├── system_prompt.txt          # Mistral model instructions  
├── package.json               # Dependencies
└── .gitignore                 # Ignore node_modules, results
```
