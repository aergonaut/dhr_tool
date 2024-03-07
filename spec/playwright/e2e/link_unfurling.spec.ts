import { test, expect } from "@playwright/test";
import { faker } from "@faker-js/faker";
import { app, appFactories, appVcrInsertCassette } from "../support/on-rails";

test.describe("Link Tool", () => {
  test.beforeEach(async ({ page }) => {
    await app("clean");
  });

  test("Unfurling a link", async ({ page }) => {
    const email = faker.internet.email();
    const password = "swordfish";
    await appFactories([["create", "user", "confirmed", { email, password }]]);

    await appVcrInsertCassette("teen_rated_work", { record: "once" });

    await page.goto("/");

    await page.getByLabel("Email").fill(email);
    await page.getByLabel("Password").fill(password);

    await page.getByRole("button", { name: "Sign in" }).click();

    await page.waitForURL("**/tools/links");

    const url =
      "https://archiveofourown.org/collections/Dramione_Month_2023/works/50219086";

    await page.getByLabel("URL").fill(url);

    await page.getByRole("button", { name: "Submit" }).click();

    // find title link
    await expect(
      page
        .getByTestId("results")
        .getByRole("link", { name: "Draco Malfoy and the Timeline-Turner" }),
    ).toHaveAttribute("href", url);

    // find rating
    await expect(page.getByTestId("results")).toHaveText(
      "Draco Malfoy and the Timeline-Turner by anxiousm3ss: Teen, 1,972 words, 1/1 Chapters",
    );
  });
});
