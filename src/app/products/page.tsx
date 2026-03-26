import type { Metadata } from "next"

import { listPublicCatalogProducts } from "@/lib/data/public-catalog"
import ProductsPageTemplate from "@/modules/products/templates/products-page"

export const metadata: Metadata = {
  title: "Products",
  description:
    "Browse Apindex pharmaceutical products for institutional and export enquiries.",
}

export default async function ProductsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; category?: string; page?: string }>
}) {
  const resolvedSearchParams = await searchParams
  const page = Number.parseInt(resolvedSearchParams.page ?? "1", 10)

  const catalog = await listPublicCatalogProducts({
    page: Number.isNaN(page) ? 1 : page,
    query: resolvedSearchParams.q,
    categoryHandle: resolvedSearchParams.category,
  })

  return <ProductsPageTemplate catalog={catalog} />
}
