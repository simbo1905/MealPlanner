import type { ShoppingItem } from './shoppingTypes'

const INITIAL_ITEMS: ShoppingItem[] = [
  {
    id: 's1',
    text: 'Chicken breasts',
    completed: false,
    starred: false,
    createdAt: new Date().toISOString()
  },
  {
    id: 's2',
    text: 'Vegetables for stir-fry',
    completed: false,
    starred: true,
    createdAt: new Date().toISOString()
  },
  {
    id: 's3',
    text: 'Pasta',
    completed: false,
    starred: false,
    createdAt: new Date().toISOString()
  }
]

class ShoppingStore {
  items = $state<ShoppingItem[]>(INITIAL_ITEMS)
  showCompleted = $state(false)

  get activeItems() {
    return this.items.filter(item => !item.completed)
  }

  get completedItems() {
    return this.items.filter(item => item.completed)
  }

  toggleComplete(id: string) {
    const item = this.items.find(i => i.id === id)
    if (item) {
      item.completed = !item.completed
    }
  }

  toggleStar(id: string) {
    const item = this.items.find(i => i.id === id)
    if (item) {
      item.starred = !item.starred
    }
  }

  addItem(text: string) {
    if (!text.trim()) return
    
    const newItem: ShoppingItem = {
      id: `s${Date.now()}`,
      text: text.trim(),
      completed: false,
      starred: false,
      createdAt: new Date().toISOString()
    }
    
    this.items.push(newItem)
  }

  reorder(oldIndex: number, newIndex: number) {
    const [item] = this.items.splice(oldIndex, 1)
    this.items.splice(newIndex, 0, item)
  }
}

export const shoppingStore = new ShoppingStore()
