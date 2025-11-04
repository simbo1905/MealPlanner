# Test Case Details

## Overview
12 test cases across 4 difficulty tiers evaluating OCR recipe title extraction.

## Tier 1: Clean Text (3 tests)
Expected: High accuracy, confidence scores 0.9-1.0

### 1.1 Clean Recipe Header
**Input:** "Slow Cooked Lamb Shanks in Red Wine Sauce\nIngredients: lamb shanks, red wine, carrots, onions\nServes 4"
**Expected:** Extract "Slow Cooked Lamb Shanks in Red Wine Sauce" or "Lamb Shanks in Red Wine Sauce"
**Score:** ~0.95

### 1.2 Handwritten Meal
**Input:** "Spaghetti Bolognese\n(Mom's secret recipe)"
**Expected:** Extract "Spaghetti Bolognese"
**Score:** ~0.98

### 1.3 Formatted Recipe
**Input:** "CHICKEN TIKKA MASALA\nServes 4 | Prep time: 30min | Cook time: 45min"
**Expected:** Extract "Chicken Tikka Masala"
**Score:** ~0.97

## Tier 2: Moderate Noise (4 tests)
Expected: Good accuracy, some scores 0.6-0.9

### 2.1 Website OCR Noise
**Input:** "Home | About Us | Recipes | Quick & Easy Spaghetti Carbonara | Newsletter | Contact"
**Expected:** Extract "Spaghetti Carbonara" (strip "Quick & Easy")
**NOT Expected:** "Home", "About Us", "Newsletter"
**Score:** ~0.75

### 2.2 Multiple Meals
**Input:** "Weekly Meal Plan:\nMonday: Lasagna\nTuesday: Beef Stir Fry\nWednesday: Fish Tacos\nThursday: Chicken Curry"
**Expected:** Extract all 4 meals
**Score:** ~0.85 each

### 2.3 Subjective Descriptors
**Input:** "Absolutely Delicious Chocolate Lava Cake - The Best Dessert Ever! A Family Favorite!"
**Expected:** Extract "Chocolate Lava Cake" (strip all adjectives)
**NOT Expected:** "Absolutely Delicious", "Best", "Family Favorite"
**Score:** ~0.80

### 2.4 Mixed Orientation Artifacts
**Input:** "Beef Stew ||| S|i|d|e|b|a|r | T|e|x|t with Vegetables and Potatoes"
**Expected:** Extract "Beef Stew with Vegetables and Potatoes"
**Score:** ~0.70

## Tier 3: Heavy Noise (3 tests)
Expected: Moderate accuracy, scores 0.3-0.7

### 3.1 Dense Metadata
**Input:** "RecipeID:847 | Category:italian,pasta,dinner | Views:1203 | Rating:4.5/5 | Updated:2024-01-15\nCarbonara\nAuthor:Chef Mario | PrepTime:15min"
**Expected:** Extract "Carbonara"
**NOT Expected:** "RecipeID:847", "Chef Mario", metadata
**Score:** ~0.60

### 3.2 Corrupted Spacing
**Input:** "chi  cken   t  eriy  aki   w ith   br  occoli   and    r ice"
**Expected:** Extract "Chicken Teriyaki with Broccoli and Rice"
**Score:** ~0.50

### 3.3 Partial/Fragmented Text
**Input:** "...agn...olo...ese...sauc...with...meatb...and...toma..."
**Expected:** Extract "Bolognese Sauce with Meatballs and Tomato" OR lower confidence guess
**Score:** ~0.30

## Tier 4: Edge Cases (2 tests)
Expected: Empty arrays `[]`

### 4.1 No Recognizable Title
**Input:** "xJ#8q2$%^&*()_+z9kL m3@t10@f pRqS7!?"
**Expected:** `[]` (empty array)
**Validation:** Hard-fail if not empty array

### 4.2 Empty Input
**Input:** ""
**Expected:** `[]` (empty array)
**Validation:** Hard-fail if not empty array

## Grading Criteria

### Hard-Fail Checks (Schema)
- Valid JSON array
- Each item has `title` (non-empty string) and `score` (number 0-1)
- No empty title strings

### LLM Grading (GROQ llama-3.3-70b-versatile)
**Positive points:**
- Actual recipe names extracted
- Subjective adjectives stripped
- Confidence scores match text quality
- Empty array for garbage input

**Deductions:**
- Including fluff words ("Quick", "Easy", "Delicious", "Best")
- Extracting navigation/metadata
- Hallucinating titles
- Overconfident scores on corrupted text
- Missing obvious titles

**Target:** ≥0.85 average across all tests

## Expected Model Performance

| Model | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Overall |
|-------|--------|--------|--------|--------|---------|
| tiny | ✅ | ⚠️ | ❌ | ❌ | ~60% |
| small | ✅ | ✅ | ⚠️ | ❌ | ~75% |
| medium | ✅ | ✅ | ✅ | ✅ | ~90% |
| devstral | ✅ | ✅ | ✅ | ✅ | ~88% |

**Winner:** `mistral-medium-latest` or `devstral-latest` (whichever is smaller if both pass)
