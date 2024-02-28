import { test, expect } from "@playwright/test";
import { faker } from "@faker-js/faker";
import { app, appFactories } from "../support/on-rails";

test.describe("Sign in flow", () => {
  test.beforeEach(async ({ page }) => {
    await app("clean");
  });

  test("Logging in as a confirmed user", async ({ page }) => {
    const email = faker.internet.email();
    const password = "swordfish";
    await appFactories([["create", "user", "confirmed", { email, password }]]);
    await page.goto("/");

    await page.getByLabel("Email").fill(email);
    await page.getByLabel("Password").fill(password);

    await page.getByRole("button", { name: "Sign in" }).click();

    await page.waitForURL("**/tools/links");

    await expect(page.getByRole("alert")).toContainText(
      "Signed in successfully.",
    );

    await page.getByRole("link", { name: "Your Profile" }).click();

    await page.waitForURL("**/users/edit");

    await page.getByRole("button", { name: "Sign out" }).click();

    await page.waitForURL("**/users/sign_in");

    await expect(page.getByRole("alert")).toContainText(
      "You need to sign in or sign up before continuing.",
    );
  });
});
