import { test, expect } from '@playwright/test'

test.describe('MealPlanner web app', () => {
  test('switches between calendar and recipe explorer views', async ({ page }) => {
    await page.goto('/')

    await expect(page.getByRole('heading', { name: 'MealPlanner Calendar View' })).toBeVisible()

    await page.getByRole('button', { name: 'Recipe Explorer' }).click()

    await expect(page.getByRole('heading', { name: 'MealPlanner Recipe Explorer' })).toBeVisible()

    const recipeCards = page.getByTestId('recipe-card')
    await expect(recipeCards.first()).toBeVisible()
    const initialCount = await recipeCards.count()
    expect(initialCount).toBeGreaterThan(0)

    const sentinel = page.getByTestId('infinite-scroll-sentinel')
    await expect(sentinel).toHaveCount(1)
    await sentinel.scrollIntoViewIfNeeded()
    await page.mouse.wheel(0, 1200)

    await page.waitForFunction(
      (previousCount) =>
        document.querySelectorAll('[data-testid="recipe-card"]').length > previousCount,
      initialCount
    )

    const expandedCount = await recipeCards.count()
    expect(expandedCount).toBeGreaterThan(initialCount)

    const searchInput = page.getByLabel('Search Recipes')
    await searchInput.fill('Fish')
    await expect(recipeCards.first()).toBeVisible()

    await expect(
      page.getByRole('complementary', { name: 'Selected recipe details' })
    ).toBeVisible()
  })
})
