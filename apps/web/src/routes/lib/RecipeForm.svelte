<script lang="ts">
  import { recipeDB } from './recipeStore.svelte';
  import type { UcumUnit, MetricUnit, AllergenCode } from '@mealplanner/recipe-types';

  let { onSuccess } = $props<{
    onSuccess?: () => void;
  }>();

  let title = $state('');
  let imageUrl = $state('');
  let description = $state('');
  let notes = $state('');
  let totalTime = $state(30);
  let preReqs = $state<string[]>(['']);
  let ingredients = $state<Array<{
    name: string;
    'ucum-unit': UcumUnit;
    'ucum-amount': number;
    'metric-unit': MetricUnit;
    'metric-amount': number;
    notes: string;
    'allergen-code'?: AllergenCode;
  }>>([{
    name: '',
    'ucum-unit': 'cup_us',
    'ucum-amount': 1.0,
    'metric-unit': 'g',
    'metric-amount': 100,
    notes: ''
  }]);
  let steps = $state<string[]>(['']);
  let errors = $state<string[]>([]);

  const ucumUnits: UcumUnit[] = [
    'cup_us', 'cup_m', 'cup_imp',
    'tbsp_us', 'tbsp_m', 'tbsp_imp',
    'tsp_us', 'tsp_m', 'tsp_imp'
  ];

  const metricUnits: MetricUnit[] = ['ml', 'g'];

  const allergenCodes: AllergenCode[] = [
    'GLUTEN', 'CRUSTACEAN', 'EGG', 'FISH', 'PEANUT', 'SOY', 'MILK', 'NUT',
    'CELERY', 'MUSTARD', 'SESAME', 'SULPHITE', 'LUPIN', 'MOLLUSC',
    'SHELLFISH', 'TREENUT', 'WHEAT'
  ];

  const addPreReq = () => {
    preReqs.push('');
    preReqs = [...preReqs];
  };

  const removePreReq = (index: number) => {
    preReqs.splice(index, 1);
    preReqs = [...preReqs];
  };

  const addIngredient = () => {
    ingredients.push({
      name: '',
      'ucum-unit': 'cup_us',
      'ucum-amount': 1.0,
      'metric-unit': 'g',
      'metric-amount': 100,
      notes: ''
    });
    ingredients = [...ingredients];
  };

  const removeIngredient = (index: number) => {
    ingredients.splice(index, 1);
    ingredients = [...ingredients];
  };

  const addStep = () => {
    steps.push('');
    steps = [...steps];
  };

  const removeStep = (index: number) => {
    steps.splice(index, 1);
    steps = [...steps];
  };

  const handleSubmit = () => {
    errors = [];

    const recipeData = {
      title,
      image_url: imageUrl,
      description,
      notes,
      pre_reqs: preReqs.filter(p => p.trim().length > 0),
      total_time: totalTime,
      ingredients: ingredients.filter(i => i.name.trim().length > 0),
      steps: steps.filter(s => s.trim().length > 0)
    };

    const result = recipeDB.addRecipe(recipeData);

    if (!result.success) {
      errors = result.errors;
      return;
    }

    title = '';
    imageUrl = '';
    description = '';
    notes = '';
    totalTime = 30;
    preReqs = [''];
    ingredients = [{
      name: '',
      'ucum-unit': 'cup_us',
      'ucum-amount': 1.0,
      'metric-unit': 'g',
      'metric-amount': 100,
      notes: ''
    }];
    steps = [''];
    errors = [];

    if (onSuccess) {
      onSuccess();
    }
  };
</script>

<div class="max-w-4xl mx-auto p-6">
  <h1 class="text-2xl font-bold mb-6">Create New Recipe</h1>

  {#if errors.length > 0}
    <div class="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
      <h3 class="text-red-800 font-semibold mb-2">Validation Errors:</h3>
      <ul class="list-disc list-inside text-red-700 text-sm space-y-1">
        {#each errors as error}
          <li>{error}</li>
        {/each}
      </ul>
    </div>
  {/if}

  <form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }} class="space-y-6">
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">Title *</label>
      <input 
        type="text" 
        bind:value={title}
        class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        required
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">Image URL</label>
      <input 
        type="url" 
        bind:value={imageUrl}
        class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        placeholder="https://example.com/image.jpg"
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">Description (max 250 chars) *</label>
      <textarea 
        bind:value={description}
        maxlength="250"
        rows="3"
        class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        required
      ></textarea>
      <p class="text-xs text-gray-500 mt-1">{description.length} / 250</p>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">Notes</label>
      <textarea 
        bind:value={notes}
        rows="3"
        class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      ></textarea>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">Total Time (minutes) *</label>
      <input 
        type="number" 
        bind:value={totalTime}
        min="1"
        class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        required
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Prerequisites</label>
      {#each preReqs as preReq, i}
        <div class="flex gap-2 mb-2">
          <input 
            type="text" 
            bind:value={preReqs[i]}
            class="flex-1 rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="e.g., Large pot"
          />
          <button 
            type="button"
            onclick={() => removePreReq(i)}
            class="px-3 py-2 text-red-600 hover:bg-red-50 rounded-md"
          >
            Remove
          </button>
        </div>
      {/each}
      <button 
        type="button"
        onclick={addPreReq}
        class="text-sm text-blue-600 hover:text-blue-700"
      >
        + Add Prerequisite
      </button>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Ingredients *</label>
      {#each ingredients as ingredient, i}
        <div class="border border-gray-200 rounded-lg p-4 mb-4">
          <div class="grid grid-cols-2 gap-4 mb-3">
            <div class="col-span-2">
              <label class="block text-xs font-medium text-gray-600 mb-1">Name</label>
              <input 
                type="text" 
                bind:value={ingredients[i].name}
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            <div>
              <label class="block text-xs font-medium text-gray-600 mb-1">UCUM Unit</label>
              <select 
                bind:value={ingredients[i]['ucum-unit']}
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {#each ucumUnits as unit}
                  <option value={unit}>{unit}</option>
                {/each}
              </select>
            </div>
            <div>
              <label class="block text-xs font-medium text-gray-600 mb-1">UCUM Amount</label>
              <input 
                type="number" 
                bind:value={ingredients[i]['ucum-amount']}
                step="0.1"
                min="0.1"
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label class="block text-xs font-medium text-gray-600 mb-1">Metric Unit</label>
              <select 
                bind:value={ingredients[i]['metric-unit']}
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {#each metricUnits as unit}
                  <option value={unit}>{unit}</option>
                {/each}
              </select>
            </div>
            <div>
              <label class="block text-xs font-medium text-gray-600 mb-1">Metric Amount</label>
              <input 
                type="number" 
                bind:value={ingredients[i]['metric-amount']}
                step="1"
                min="1"
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div class="col-span-2">
              <label class="block text-xs font-medium text-gray-600 mb-1">Notes</label>
              <input 
                type="text" 
                bind:value={ingredients[i].notes}
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div class="col-span-2">
              <label class="block text-xs font-medium text-gray-600 mb-1">Allergen Code (optional)</label>
              <select 
                bind:value={ingredients[i]['allergen-code']}
                class="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value={undefined}>None</option>
                {#each allergenCodes as code}
                  <option value={code}>{code}</option>
                {/each}
              </select>
            </div>
          </div>
          <button 
            type="button"
            onclick={() => removeIngredient(i)}
            class="text-sm text-red-600 hover:text-red-700"
          >
            Remove Ingredient
          </button>
        </div>
      {/each}
      <button 
        type="button"
        onclick={addIngredient}
        class="text-sm text-blue-600 hover:text-blue-700"
      >
        + Add Ingredient
      </button>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Steps *</label>
      {#each steps as step, i}
        <div class="flex gap-2 mb-2">
          <div class="flex items-center justify-center w-8 h-10 text-gray-500 font-medium text-sm">
            {i + 1}.
          </div>
          <textarea 
            bind:value={steps[i]}
            rows="2"
            class="flex-1 rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Describe this step..."
            required
          ></textarea>
          <button 
            type="button"
            onclick={() => removeStep(i)}
            class="px-3 py-2 text-red-600 hover:bg-red-50 rounded-md self-start"
          >
            Remove
          </button>
        </div>
      {/each}
      <button 
        type="button"
        onclick={addStep}
        class="text-sm text-blue-600 hover:text-blue-700"
      >
        + Add Step
      </button>
    </div>

    <div class="flex gap-3 pt-4">
      <button 
        type="submit"
        class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
      >
        Save Recipe
      </button>
    </div>
  </form>
</div>
