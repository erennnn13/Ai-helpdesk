import { test, expect } from '@playwright/test';
import { loginAs } from './helpers';

test.describe('Dashboard Page — Sanity Check', () => {
  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'agent');
  });

  test('loads successfully and displays basic content', async ({ page }) => {
    await expect(page.locator('h1', { hasText: 'Dashboard' })).toBeVisible();
    await page.waitForLoadState('networkidle');
    await expect(page.locator('text=Total').first()).toBeVisible();
    await expect(page.locator('text=Recent Tickets').first()).toBeVisible();
  });
});
