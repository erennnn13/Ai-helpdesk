import { test, expect } from '@playwright/test';
import { loginAs } from './helpers';

test.describe('User Management', () => {

  test('agent is redirected away from /users', async ({ page }) => {
    await loginAs(page, 'agent');
    await page.goto('/users');
    await page.waitForURL('/', { timeout: 5000 });
  });

  test('admin can access User Management page', async ({ page }) => {
    await loginAs(page, 'admin');
    await page.goto('/users');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('h1', { hasText: 'User Management' })).toBeVisible();
    await expect(page.locator('button:has-text("Add User")')).toBeVisible();
  });

  test('admin sees seeded users in the table', async ({ page }) => {
    await loginAs(page, 'admin');
    await page.goto('/users');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('td', { hasText: 'admin@example.com' })).toBeVisible();
    await expect(page.locator('td', { hasText: 'agent@example.com' })).toBeVisible();
  });

  test('admin can create, update, and delete a user (full CRUD)', async ({ page }) => {
    await loginAs(page, 'admin');
    await page.goto('/users');
    await page.waitForLoadState('networkidle');

    const testEmail = `playwright_${Date.now()}@example.com`;

    // ── CREATE ──────────────────────────────────────────────
    await page.click('button:has-text("Add User")');
    await page.fill('input[id="name"]', 'Playwright User');
    await page.fill('input[id="email"]', testEmail);
    await page.fill('input[id="password"]', 'password123');
    await page.click('button:has-text("Create User")');

    const newRow = page.locator('tr', { hasText: testEmail });
    await expect(newRow.locator('td', { hasText: 'Playwright User' })).toBeVisible({ timeout: 8000 });

    // ── UPDATE ──────────────────────────────────────────────
    await newRow.locator('button[title="Edit User"]').click();
    await page.fill('input[id="name"]', 'Updated Playwright User');
    await page.click('button:has-text("Save Changes")');
    await expect(newRow.locator('td', { hasText: 'Updated Playwright User' })).toBeVisible({ timeout: 8000 });

    // ── DELETE ──────────────────────────────────────────────
    await newRow.locator('button:has-text("Delete")').click();
    await page.click('button:has-text("Delete User")');
    await expect(page.locator('td', { hasText: testEmail })).not.toBeVisible({ timeout: 8000 });
  });

});
