<script lang="ts">
  import { recipeStore } from '$lib/stores/recipeStore'
  
  interface Props {
    visible: boolean
    onClose: () => void
  }
  
  let { visible = false, onClose }: Props = $props()

  let title = $state('')
  let description = $state('')
  let totalTime = $state(30)
  let ingredients = $state([''])
  let steps = $state([''])
  let notes = $state('')

  function addIngredient() {
    ingredients = [...ingredients, '']
  }

  function removeIngredient(index: number) {
    ingredients = ingredients.filter((_, i) => i !== index)
    if (ingredients.length === 0) ingredients = ['']
  }

  function addStep() {
    steps = [...steps, '']
  }

  function removeStep(index: number) {
    steps = steps.filter((_, i) => i !== index)
    if (steps.length === 0) steps = ['']
  }

  function handleSubmit() {
    const validIngredients = ingredients.filter(i => i.trim())
    const validSteps = steps.filter(s => s.trim())

    if (!title.trim()) {
      alert('Please enter a recipe title')
      return
    }

    recipeStore.addRecipe({
      title: title.trim(),
      description: description.trim(),
      total_time: totalTime,
      ingredients: validIngredients,
      steps: validSteps,
      notes: notes.trim()
    })

    resetForm()
    onClose()
  }

  function resetForm() {
    title = ''
    description = ''
    totalTime = 30
    ingredients = ['']
    steps = ['']
    notes = ''
  }

  function handleCancel() {
    resetForm()
    onClose()
  }
</script>

<div class="form-container" class:visible>
  <div class="form-content">
    <h2 class="form-title">Add New Recipe</h2>
    
    <div class="form-group">
      <label for="title">Recipe Title *</label>
      <input id="title" type="text" bind:value={title} placeholder="e.g., Spaghetti Carbonara" />
    </div>

    <div class="form-group">
      <label for="totalTime">Prep Time (minutes)</label>
      <input id="totalTime" type="number" bind:value={totalTime} min="1" />
    </div>

    <div class="form-group">
      <label for="description">Description</label>
      <textarea id="description" bind:value={description} rows="3" placeholder="Brief description..."></textarea>
    </div>

    <div class="form-group">
      <p class="form-label">Ingredients</p>
      {#each ingredients as _, i}
        <div class="list-item">
          <input
            id={`ingredient-${i}`}
            type="text"
            bind:value={ingredients[i]}
            placeholder={`Ingredient ${i + 1}`}
            aria-label={`Ingredient ${i + 1}`}
          />
          <button type="button" class="btn-remove" onclick={() => removeIngredient(i)}>×</button>
        </div>
      {/each}
      <button type="button" class="btn-add" onclick={addIngredient}>+ Add Ingredient</button>
    </div>

    <div class="form-group">
      <p class="form-label">Steps</p>
      {#each steps as _, i}
        <div class="list-item">
          <input
            id={`step-${i}`}
            type="text"
            bind:value={steps[i]}
            placeholder={`Step ${i + 1}`}
            aria-label={`Step ${i + 1}`}
          />
          <button type="button" class="btn-remove" onclick={() => removeStep(i)}>×</button>
        </div>
      {/each}
      <button type="button" class="btn-add" onclick={addStep}>+ Add Step</button>
    </div>

    <div class="form-group">
      <label for="notes">Notes</label>
      <textarea id="notes" bind:value={notes} rows="3" placeholder="Any additional notes..."></textarea>
    </div>

    <div class="form-actions">
      <button type="button" class="btn-cancel" onclick={handleCancel}>Cancel</button>
      <button type="button" class="btn-submit" onclick={handleSubmit}>Add Recipe</button>
    </div>
  </div>
</div>

<style>
  .form-container {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-in-out;
    background: white;
    border-radius: 8px;
    margin-bottom: 20px;
  }

  .form-container.visible {
    max-height: 2000px;
    border: 1px solid #e5e7eb;
  }

  .form-content {
    padding: 20px;
  }

  .form-title {
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 20px;
    color: #1f2937;
  }

  .form-group {
    margin-bottom: 16px;
  }

  label,
  .form-label {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #374151;
    margin-bottom: 6px;
 }

  input[type="text"],
  input[type="number"],
  textarea {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 14px;
    box-sizing: border-box;
  }

  input[type="text"]:focus,
  input[type="number"]:focus,
  textarea:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .list-item {
    display: flex;
    gap: 8px;
    margin-bottom: 8px;
  }

  .list-item input {
    flex: 1;
  }

  .btn-remove {
    width: 32px;
    height: 32px;
    padding: 0;
    background: #ef4444;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 20px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .btn-remove:hover {
    background: #dc2626;
  }

  .btn-add {
    background: #f3f4f6;
    color: #374151;
    border: 1px solid #d1d5db;
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 14px;
    cursor: pointer;
  }

  .btn-add:hover {
    background: #e5e7eb;
  }

  .form-actions {
    display: flex;
    gap: 12px;
    margin-top: 24px;
  }

  .btn-cancel,
  .btn-submit {
    flex: 1;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 500;
    cursor: pointer;
    border: none;
  }

  .btn-cancel {
    background: #f3f4f6;
    color: #374151;
  }

  .btn-cancel:hover {
    background: #e5e7eb;
  }

  .btn-submit {
    background: #3b82f6;
    color: white;
  }

  .btn-submit:hover {
    background: #2563eb;
  }
</style>
