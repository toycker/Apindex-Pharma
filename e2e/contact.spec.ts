import { expect, test } from "@playwright/test"

test("contact page renders the complete layout", async ({ page }) => {
  await page.goto("/contact")

  await expect(page.getByRole("heading", { name: "Contact Us" })).toBeVisible()
  await expect(page.getByRole("heading", { name: "Corporate Headquarters" })).toBeVisible()
  await expect(page.getByRole("heading", { name: "Send an Inquiry" })).toBeVisible()
  await expect(page.getByLabel("Full Name")).toBeVisible()
  await expect(page.getByLabel("Work Email")).toBeVisible()
  await expect(page.getByLabel("Phone Number")).toBeVisible()
  await expect(page.getByLabel("Country")).toBeVisible()
  await expect(page.getByLabel("Message")).toBeVisible()
  await expect(page.getByRole("link", { name: "Contact" })).toBeVisible()
  await expect(page.getByText("2024 Apindex Pharmaceuticals. All rights reserved.")).toBeVisible()
})
