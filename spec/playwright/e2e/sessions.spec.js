import { test, expect } from "@playwright/test";
import { app, appFactories } from '../support/on-rails';

test.describe("Sign in flow", () => {
  test.beforeEach(async ({ page }) => {
    await app('clean');
  });

  test("Logging in as a confirmed user", async ({ page }) => {
    const email = "example@example.com"
    const password = "swordfish"
    await appFactories([["create", "user", "confirmed", {email, password}]]);
    await page.goto("/");

    await page.getByLabel("Email").fill(email);
    await page.getByLabel("Password").fill(password);
  
    await page.getByRole("button", { name: "Sign in"}).click();

    await page.waitForURL("**/tools/links");
  });
});
