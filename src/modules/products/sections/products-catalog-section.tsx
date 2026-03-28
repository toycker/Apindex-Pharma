import Link from "next/link"
import { HiOutlineArrowUpRight } from "react-icons/hi2"

import {
  CATALOG_DOSAGE_OPTIONS,
  type PublicCatalogResult,
} from "@/lib/data/public-catalog"
import {
  buildCatalogRequestHref,
  buildPageTokens,
  buildProductsPageHref,
  getAllCategoriesIcon,
  getCategoryIcon,
  getProductBadge,
  getProductIcon,
  getProductSummary,
} from "@/modules/products/lib/catalog-ui"
import { buildProductDetailHref } from "@/modules/products/lib/product-detail-ui"

type ProductsCatalogSectionProps = {
  catalog: PublicCatalogResult
}

export default function ProductsCatalogSection({
  catalog,
}: ProductsCatalogSectionProps) {
  const catalogRequestHref = buildCatalogRequestHref()
  const selectedCategoryName =
    catalog.selectedCategory?.name ?? "All therapeutic categories"
  const pageTokens = buildPageTokens(catalog.page, catalog.totalPages)
  const AllCategoriesIcon = getAllCategoriesIcon()

  return (
    <section className="content-container flex flex-col gap-12 py-16 lg:flex-row lg:gap-16 lg:py-24">
      <aside className="lg:w-72 lg:shrink-0">
        <div className="lg:sticky lg:top-28">
          <div className="mb-8">
            <h2 className="apx-font-headline text-2xl font-bold text-on-surface">
              Therapeutic Categories
            </h2>
            <p className="mt-1 text-xs font-semibold uppercase tracking-[0.2em] text-on-surface-variant">
              Browse by molecular group
            </p>
          </div>

          <nav className="space-y-2">
            <Link
              href={buildProductsPageHref({ query: catalog.query })}
              className={`flex items-center gap-4 rounded-2xl px-4 py-4 text-sm font-semibold transition-all ${
                !catalog.selectedCategory
                  ? "scale-[0.98] bg-secondary-container text-on-secondary-container"
                  : "text-zinc-600 hover:bg-surface-low hover:text-primary"
              }`}
            >
              <AllCategoriesIcon className="text-xl" />
              <span>All Categories</span>
            </Link>

            {catalog.categories.map((category) => {
              const isSelected = category.handle === catalog.selectedCategory?.handle
              const CategoryIcon = getCategoryIcon(category)

              return (
                <Link
                  key={category.id}
                  href={buildProductsPageHref({
                    query: catalog.query,
                    categoryHandle: category.handle,
                  })}
                  className={`flex items-center gap-4 rounded-2xl px-4 py-4 text-sm font-semibold transition-all ${
                    isSelected
                      ? "scale-[0.98] bg-secondary-container text-on-secondary-container"
                      : "text-zinc-600 hover:bg-surface-low hover:text-primary"
                  }`}
                >
                  <CategoryIcon className="text-xl" />
                  <span>{category.name}</span>
                </Link>
              )
            })}
          </nav>

          <div className="mt-10 rounded-2xl bg-primary-fixed p-6 shadow-sm">
            <h3 className="apx-font-headline text-lg font-bold text-on-surface">
              Request Catalog
            </h3>
            <p className="mt-2 text-sm leading-6 text-on-surface-variant">
              Get our full pharmaceutical directory delivered to your inbox for
              institutional and export enquiries.
            </p>
            <a
              href={catalogRequestHref}
              className="mt-5 inline-flex w-full items-center justify-center rounded-xl bg-on-surface px-4 py-3 text-sm font-bold text-white transition-colors hover:bg-primary"
            >
              Email Catalog Request
            </a>
          </div>
        </div>
      </aside>

      <div className="min-w-0 flex-1">
        <div className="mb-10 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
          <div>
            <h2 className="apx-font-headline text-3xl font-bold text-on-surface md:text-4xl">
              Product Registry
            </h2>
            <p className="mt-2 text-sm leading-6 text-on-surface-variant md:text-base">
              Showing {catalog.total} result{catalog.total === 1 ? "" : "s"} in {selectedCategoryName}
            </p>
          </div>

          <div className="flex gap-4">
            <select
              disabled
              defaultValue={CATALOG_DOSAGE_OPTIONS[0]}
              className="w-full cursor-not-allowed rounded-2xl border border-outline-variant/20 bg-surface-low px-4 py-3 text-sm font-medium text-on-surface-variant opacity-80 outline-none md:w-[220px]"
              aria-label="Dosage form filter coming later"
            >
              {CATALOG_DOSAGE_OPTIONS.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
          </div>
        </div>

        {catalog.products.length > 0 ? (
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
            {catalog.products.map((product) => {
              const ProductIcon = getProductIcon(product)

              return (
                <article
                  key={product.id}
                  className="group flex min-h-[250px] flex-col justify-between rounded-2xl border border-outline-variant/15 bg-surface-lowest p-6 ambient-shadow transition-all duration-300 hover:-translate-y-1 hover:shadow-lg"
                >
                  <div>
                    <div className="mb-6 flex items-start justify-between gap-4">
                      <span className="rounded-full bg-secondary-container px-3 py-1 text-[11px] font-bold uppercase tracking-[0.18em] text-on-secondary-container">
                        {getProductBadge(product)}
                      </span>
                      <ProductIcon className="text-2xl text-primary/30 transition-colors group-hover:text-primary" />
                    </div>
                    <h3 className="apx-font-headline text-2xl font-bold tracking-tight text-on-surface">
                      <Link
                        href={buildProductDetailHref(product.handle)}
                        className="transition-colors hover:text-primary"
                      >
                        {product.name}
                      </Link>
                    </h3>
                    <p className="mt-3 text-sm leading-6 text-on-surface-variant">
                      {getProductSummary(product)}
                    </p>
                  </div>

                  <div className="mt-8 border-t border-surface-high pt-6">
                    <Link
                      href={buildProductDetailHref(product.handle)}
                      className="flex items-center justify-between text-sm font-bold text-on-surface transition-colors hover:text-primary"
                    >
                      <span>View Product</span>
                      <HiOutlineArrowUpRight className="text-lg" />
                    </Link>
                  </div>
                </article>
              )
            })}
          </div>
        ) : (
          <div className="rounded-2xl border border-dashed border-outline-variant/50 bg-surface-low px-6 py-16 text-center">
            <h3 className="apx-font-headline text-2xl font-bold text-on-surface">
              No products found
            </h3>
            <p className="mx-auto mt-3 max-w-2xl text-sm leading-6 text-on-surface-variant">
              Adjust your search or therapeutic category filter to review the available
              pharmaceutical catalogue entries.
            </p>
            <div className="mt-6 flex flex-wrap justify-center gap-3">
              <Link
                href="/products"
                className="rounded-xl bg-primary px-5 py-3 text-sm font-bold text-white transition-colors hover:bg-primary-container"
              >
                Clear filters
              </Link>
              <a
                href={catalogRequestHref}
                className="rounded-xl border border-primary/20 bg-surface-lowest px-5 py-3 text-sm font-bold text-primary transition-colors hover:border-primary"
              >
                Request catalog
              </a>
            </div>
          </div>
        )}

        {catalog.totalPages > 1 ? (
          <div className="mt-12 flex items-center justify-center gap-2">
            {pageTokens.map((token, index) =>
              token === "ellipsis" ? (
                <span
                  key={`ellipsis-${index + 1}`}
                  className="px-2 text-sm font-semibold text-on-surface-variant"
                >
                  ...
                </span>
              ) : (
                <Link
                  key={token}
                  href={buildProductsPageHref({
                    query: catalog.query,
                    categoryHandle: catalog.selectedCategory?.handle ?? null,
                    page: token,
                  })}
                  className={`flex h-10 w-10 items-center justify-center rounded-full text-sm font-semibold transition-all ${
                    token === catalog.page
                      ? "bg-surface-high text-on-surface"
                      : "text-on-surface-variant hover:bg-surface-low"
                  }`}
                >
                  {token}
                </Link>
              )
            )}
          </div>
        ) : null}
      </div>
    </section>
  )
}
