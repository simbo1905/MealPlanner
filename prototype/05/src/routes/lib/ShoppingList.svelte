<script lang="ts">
  import { Circle, ChevronLeft, MoreVertical, ShoppingCart, Eye, EyeOff, Edit3, Printer } from 'lucide-svelte'
  import ShoppingItem from './ShoppingItem.svelte'
  import { shoppingStore } from './shoppingStore.svelte'

  let newItemText = $state('')
  let isComposerFocused = $state(false)
  let isMenuOpen = $state(false)
  let inputElement: HTMLInputElement | undefined = $state()

  const handleAddItem = () => {
    shoppingStore.addItem(newItemText)
    newItemText = ''
  }

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      handleAddItem()
    }
  }

  const handleDoneClick = () => {
    inputElement?.blur()
    isComposerFocused = false
  }

  const handleEditClick = () => {
    isMenuOpen = false
    setTimeout(() => {
      inputElement?.focus()
    }, 100)
  }

  const handlePrintClick = () => {
    isMenuOpen = false
  }
</script>

<div class="min-h-screen bg-black">
  <div class="max-w-sm mx-auto bg-black text-white/90 pt-3 px-3 pb-2 min-h-screen">
    <div class="relative mb-4">
      <button class="flex items-center gap-1 text-teal-200/90 text-sm">
        <ChevronLeft class="w-4 h-4" />
        <span>Lists</span>
      </button>

      <h1 class="text-4xl font-extrabold text-teal-200 mt-2 mb-3">
        Shopping List
      </h1>

      <button
        onclick={() => (isComposerFocused ? handleDoneClick() : (isMenuOpen = true))}
        class="absolute right-0 top-0 text-teal-200 font-semibold h-11 px-3 flex items-center justify-center"
        aria-label={isComposerFocused ? 'Done editing' : 'More options'}
      >
        {#if isComposerFocused}
          Done
        {:else}
          <MoreVertical class="w-5 h-5" />
        {/if}
      </button>

      <div class="inline-flex items-center gap-2 bg-neutral-900 px-3 py-1 text-sm text-white/80 rounded-xl">
        <ShoppingCart class="w-4 h-4" />
        <span>This Week</span>
      </div>
    </div>

    <div class="space-y-3 mb-4">
      {#if shoppingStore.activeItems.length === 0 && !shoppingStore.showCompleted}
        <div class="text-center py-12 text-white/40 text-sm">
          No items yet. Add something below.
        </div>
      {/if}

      {#each shoppingStore.activeItems as item (item.id)}
        <ShoppingItem
          {item}
          onToggleComplete={shoppingStore.toggleComplete.bind(shoppingStore)}
          onToggleStar={shoppingStore.toggleStar.bind(shoppingStore)}
        />
      {/each}

      {#if shoppingStore.showCompleted && shoppingStore.completedItems.length > 0}
        <div class="text-xs uppercase text-white/40 font-semibold tracking-wider mt-6 mb-3 px-1">
          Completed
        </div>
        {#each shoppingStore.completedItems as item (item.id)}
          <ShoppingItem
            {item}
            onToggleComplete={shoppingStore.toggleComplete.bind(shoppingStore)}
            onToggleStar={shoppingStore.toggleStar.bind(shoppingStore)}
          />
        {/each}
      {/if}
    </div>

    <div class="mt-2 rounded-2xl bg-neutral-900/60 ring-1 ring-white/5 px-4 py-3 flex items-center gap-3">
      <div class="flex-shrink-0 w-6 h-6 flex items-center justify-center">
        <Circle class="w-6 h-6 text-white/40" />
      </div>
      <input
        bind:this={inputElement}
        type="text"
        placeholder="Add an Item"
        bind:value={newItemText}
        onkeydown={handleKeyDown}
        onfocus={() => (isComposerFocused = true)}
        onblur={() => (isComposerFocused = false)}
        class="flex-1 bg-transparent text-base text-white placeholder-white/40 focus:outline-none"
      />
    </div>

    {#if isMenuOpen}
      <div
        class="fixed inset-0 bg-black/60 z-40"
        onclick={() => (isMenuOpen = false)}
      />
      <div class="fixed inset-x-0 bottom-0 rounded-t-3xl bg-neutral-900 ring-1 ring-white/10 p-3 pb-6 z-50">
        <button
          onclick={() => (shoppingStore.showCompleted = !shoppingStore.showCompleted)}
          class="w-full flex items-center gap-3 px-3 py-3 rounded-xl active:bg-white/5 transition-colors"
        >
          {#if shoppingStore.showCompleted}
            <EyeOff class="w-5 h-5 text-white/70" />
          {:else}
            <Eye class="w-5 h-5 text-white/70" />
          {/if}
          <span class="text-base text-white/90">
            {shoppingStore.showCompleted ? 'Hide' : 'Show'} Completed Items
          </span>
        </button>
        <button
          onclick={handleEditClick}
          class="w-full flex items-center gap-3 px-3 py-3 rounded-xl active:bg-white/5 transition-colors"
        >
          <Edit3 class="w-5 h-5 text-white/70" />
          <span class="text-base text-white/90">Edit</span>
        </button>
        <button
          onclick={handlePrintClick}
          class="w-full flex items-center gap-3 px-3 py-3 rounded-xl active:bg-white/5 transition-colors"
        >
          <Printer class="w-5 h-5 text-white/70" />
          <span class="text-base text-white/90">Print</span>
        </button>
      </div>
    {/if}
  </div>
</div>
