import { expect, test } from "@playwright/test"

test("about page renders the complete layout", async ({ page }) => {
  await page.goto("/about")

  await expect(page.getByRole("heading", { name: "About Apindex Pharmaceuticals" })).toBeVisible()
  await expect(
    page.getByRole("heading", { name: "Precision in Chemistry, Vitality in Life" })
  ).toBeVisible()
  await expect(page.getByRole("heading", { name: "Global Footprint" })).toBeVisible()
  await expect(page.getByRole("heading", { name: "Validated Excellence" })).toBeVisible()
  await expect(page.getByRole("link", { name: "About" })).toBeVisible()
  await expect(page.getByText("© 2024 Apindex Pharmaceuticals. All rights reserved.")).toBeVisible()
})
