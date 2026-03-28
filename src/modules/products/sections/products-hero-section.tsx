import Image from "next/image"

import type { PublicCatalogResult } from "@/lib/data/public-catalog"
import { HiOutlineMagnifyingGlass } from "react-icons/hi2"
import { PRODUCTS_HERO_IMAGE_URL } from "@/modules/products/lib/catalog-ui"

type ProductsHeroSectionProps = {
  catalog: PublicCatalogResult
}

export default function ProductsHeroSection({
  catalog,
}: ProductsHeroSectionProps) {
  return (
    <section className="relative overflow-hidden border-b border-[color:rgb(221_193_176/0.18)] bg-[var(--apx-surface-container-low)] py-20 md:py-24">
      <div className="relative content-container grid gap-12 lg:grid-cols-[minmax(0,1fr)_360px] lg:items-center">
        <div className="max-w-3xl">
          <span className="mb-4 block text-xs font-bold uppercase tracking-[0.3em] text-[var(--apx-primary)]">
            Pioneering Science
          </span>
          <h1 className="apx-font-headline text-5xl font-extrabold leading-none tracking-[-0.06em] text-[var(--apx-on-surface)] md:text-7xl">
            Pharmaceutical <br />
            <span className="text-[var(--apx-primary-container)]">Excellence</span>
          </h1>
          <p className="mt-7 max-w-2xl text-base leading-7 text-[var(--apx-on-surface-variant)] md:text-lg">
            Deploying precision-engineered molecular compounds to redefine global
            healthcare outcomes through rigorous clinical curation.
          </p>

          <form action="/products" method="get" className="mt-10 max-w-3xl">
            {catalog.selectedCategory ? (
              <input type="hidden" name="category" value={catalog.selectedCategory.handle} />
            ) : null}
            <div className="flex flex-col gap-3 rounded-3xl border border-[color:rgb(221_193_176/0.2)] bg-white p-2 shadow-sm sm:flex-row sm:items-center">
              <div className="flex flex-1 items-center gap-3 px-3 sm:px-4">
                <HiOutlineMagnifyingGlass className="text-lg text-[var(--apx-outline)]" />
                <input
                  type="search"
                  name="q"
                  defaultValue={catalog.query}
                  placeholder="Search by product name, molecule, or therapeutic category..."
                  className="h-12 w-full border-none bg-transparent text-sm text-[var(--apx-on-surface)] outline-none placeholder:text-[color:rgb(86_67_54/0.55)]"
                />
              </div>
              <button
                type="submit"
                className="rounded-2xl bg-[var(--apx-secondary)] px-7 py-3 text-sm font-bold text-white transition-colors hover:bg-[var(--apx-on-secondary-container)]"
              >
                Search
              </button>
            </div>
          </form>
        </div>

        <div className="mx-auto hidden w-full max-w-[360px] lg:block">
          <div className="relative aspect-square overflow-hidden rounded-[2rem] border border-[color:rgb(221_193_176/0.22)] bg-white/50 p-6 shadow-[0_24px_60px_rgba(86,67,54,0.08)]">
            <Image
              src={PRODUCTS_HERO_IMAGE_URL}
              alt="Complex molecular structure rendered with warm orange and cool green clinical lighting"
              fill
              sizes="360px"
              className="object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-br from-white/20 via-transparent to-[color:rgb(150_73_0/0.12)]" />
          </div>
        </div>
      </div>
    </section>
  )
}
