import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {

  test('admin can log in, see dashboard, and log out', async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[id="email"]', 'admin@example.com');
    await page.fill('input[id="password"]', 'password123');
    await page.click('button:has-text("Sign In")');
    await page.waitForURL('/', { timeout: 10000 });

    await expect(page.locator('h1', { hasText: 'Dashboard' })).toBeVisible();
    await expect(page.locator('a', { hasText: 'Users' })).toBeVisible();

    await page.click('button:has-text("Sign Out")');
    await page.waitForURL('/login', { timeout: 5000 });
    await expect(page.locator('text="Helpdesk"')).toBeVisible();
  });

  test('agent can log in and does NOT see Users nav link', async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[id="email"]', 'agent@example.com');
    await page.fill('input[id="password"]', 'password123');
    await page.click('button:has-text("Sign In")');
    await page.waitForURL('/', { timeout: 10000 });

    await expect(page.locator('h1', { hasText: 'Dashboard' })).toBeVisible();
    await expect(page.locator('a', { hasText: 'Users' })).not.toBeVisible();
  });


  test('unauthenticated user is redirected to /login', async ({ page }) => {
    await page.goto('/');
    await page.waitForURL('/login', { timeout: 5000 });

    await page.goto('/tickets');
    await page.waitForURL('/login', { timeout: 5000 });
  });
});
