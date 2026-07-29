import { Page, expect } from '@playwright/test';

export async function loginAs(page: Page, role: 'admin' | 'agent' = 'agent') {
  await page.goto('/login');
  await page.waitForLoadState('networkidle');

  const email = role === 'admin' ? 'admin@example.com' : 'agent@example.com';
  await page.fill('input[id="email"]', email);
  await page.fill('input[id="password"]', 'password123');
  await page.click('button:has-text("Sign In")');
  await page.waitForURL('/', { timeout: 10000 });
}
