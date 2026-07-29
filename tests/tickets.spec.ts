import { test, expect } from '@playwright/test';
import { loginAs } from './helpers';

test.describe('Tickets — Core Journeys', () => {
  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'agent');
    await page.goto('/tickets');
    await page.waitForLoadState('networkidle');
  });

  test('seeded ticket appears in the list and can be navigated to', async ({ page }) => {
    const firstRow = page.locator('table tbody tr').first();
    await expect(firstRow).toBeVisible({ timeout: 8000 });

    await Promise.all([
      page.waitForURL(/\/tickets\/\d+/, { timeout: 8000 }),
      firstRow.click(),
    ]);
  });

  test('agent can view ticket, send a reply, and close it', async ({ page }) => {
    // Navigate into the first ticket
    const firstRow = page.locator('table tbody tr').first();
    await expect(firstRow).toBeVisible({ timeout: 8000 });

    await Promise.all([
      page.waitForURL(/\/tickets\/\d+/, { timeout: 8000 }),
      firstRow.click(),
    ]);
    await page.waitForLoadState('networkidle');

    // Make sure ticket is OPEN so we can reply
    const statusSelect = page.getByRole('combobox', { name: 'Status' });
    await expect(statusSelect).toBeVisible({ timeout: 5000 });
    const selectText = await statusSelect.innerText();

    if (selectText.includes('Closed')) {
      await statusSelect.click();
      await page.getByRole('option', { name: /Open/i }).click();
      await page.waitForResponse(resp => resp.url().includes('/tickets/') && resp.request().method() === 'PATCH');
    }

    // Send a reply
    const uniqueReply = `E2E Reply ${Date.now()}`;
    const replyBox = page.locator('textarea[placeholder="Type your reply..."]');
    await expect(replyBox).toBeVisible({ timeout: 5000 });

    await replyBox.fill(uniqueReply);
    await page.click('button:has-text("Send Reply")');

    // Wait for network response (message created)
    await page.waitForResponse(resp => resp.url().includes('/messages') && resp.request().method() === 'POST', { timeout: 8000 });

    // Assert the reply is in the conversation feed
    await expect(page.locator(`text="${uniqueReply}"`).first()).toBeVisible({ timeout: 8000 });
    await expect(replyBox).toHaveValue('');

    // Transition to closed
    await statusSelect.click();
    await page.getByRole('option', { name: /Closed/i }).click();
    await page.waitForResponse(resp => resp.url().includes('/tickets/') && resp.request().method() === 'PATCH');

    await expect(statusSelect).toContainText(/Closed/i);
  });
});
