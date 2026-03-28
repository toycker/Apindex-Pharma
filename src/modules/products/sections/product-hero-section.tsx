import Image from "next/image"
import { FaCircleCheck } from "react-icons/fa6"
import { GiMedicines } from "react-icons/gi"
import { HiOutlineArrowRight } from "react-icons/hi2"

import type { PublicProductDetail } from "@/lib/data/public-product-detail"
import SectionBadge from "@/modules/common/components/section-badge"
import {
  buildProductHeadline,
  getProductHeroBadge,
} from "@/modules/products/lib/product-detail-ui"

type ProductHeroSectionProps = {
  product: PublicProductDetail
}

type SpecItem = {
  label: string
  value: string
  highlighted?: boolean
}

function buildSpecItems(product: PublicProductDetail): SpecItem[] {
  const details = product.pharmaDetails
  const items: SpecItem[] = []

  if (details?.tradeName) {
    items.push({ label: "Trade Name", value: details.tradeName })
  }

  if (details?.availableStrength) {
    items.push({ label: "Available Strength", value: details.availableStrength })
  }

  if (details?.packing) {
    items.push({ label: "Packing", value: details.packing })
  }

  if (details?.packInsertLeaflet !== null && details?.packInsertLeaflet !== undefined) {
    items.push({
      label: "Pack Insert / Leaflet",
      value: details.packInsertLeaflet ? "Yes" : "No",
      highlighted: details.packInsertLeaflet === true,
    })
  }

  const therapeuticUse =
    details?.therapeuticUse ||
    (product.categories.length > 0
      ? product.categories.map((c) => c.name).join(", ")
      : null)

  if (therapeuticUse) {
    items.push({ label: "Therapeutic Use", value: therapeuticUse })
  }

  if (details?.productionCapacity) {
    items.push({ label: "Production Capacity", value: details.productionCapacity })
  }

  return items
}

export default function ProductHeroSection({ product }: ProductHeroSectionProps) {
  const headline = buildProductHeadline(product.name)
  const specItems = buildSpecItems(product)

  return (
    <section className="content-container grid grid-cols-1 gap-12 pb-10 pt-8 lg:grid-cols-12 lg:items-start lg:gap-14 lg:pb-16">
      <div className="relative lg:col-span-5">
        <div className="relative overflow-hidden rounded-2xl bg-surface-low p-6 ambient-shadow md:p-10">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(175,246,121,0.22),transparent_45%),radial-gradient(circle_at_bottom_right,rgba(245,130,32,0.14),transparent_45%)]" />

          <div className="relative aspect-square overflow-hidden rounded-xl p-6 md:p-10">
            {product.image_url ? (
              <Image
                src={product.image_url}
                alt={`${product.name} packaging`}
                fill
                unoptimized
                sizes="(min-width: 1024px) 38vw, 100vw"
                className="object-contain p-8 mix-blend-multiply transition-transform duration-500 group-hover:scale-105"
              />
            ) : (
              <div className="flex h-full items-center justify-center rounded-xl border border-white/10 bg-white/10 text-white/80">
                <GiMedicines className="text-7xl" />
              </div>
            )}
          </div>
        </div>

        <div className="absolute -bottom-6 -right-4 h-28 w-28 rounded-full bg-[color:rgb(175_246_121/0.34)] blur-3xl" />
      </div>

      <div className="lg:col-span-7">
        <div className="mb-4">
          <SectionBadge tone="secondary">{getProductHeroBadge(product)}</SectionBadge>
        </div>

        <h1 className="apx-font-headline text-4xl font-extrabold leading-[1.06] tracking-[-0.05em] text-on-surface md:text-5xl lg:text-[3.65rem]">
          {headline.primary}
          {headline.accent ? (
            <>
              <br />
              <span className="text-primary-container">{headline.accent}</span>
            </>
          ) : null}
        </h1>

        {specItems.length > 0 && (
          <div className="mt-8 rounded-xl bg-surface-low p-6 md:p-8">
            <div className="grid grid-cols-1 gap-x-10 gap-y-6 md:grid-cols-2">
              {specItems.map((item) => (
                <div key={item.label} className="space-y-1">
                  <p className="text-[10px] font-bold uppercase tracking-[0.22em] text-on-surface-variant">
                    {item.label}
                  </p>
                  {item.highlighted ? (
                    <div className="flex items-center gap-2 text-sm font-bold text-secondary">
                      <FaCircleCheck className="text-base" />
                      <span>{item.value}</span>
                    </div>
                  ) : (
                    <p className="text-sm font-semibold text-on-surface md:text-base">
                      {item.value}
                    </p>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="mt-8 flex flex-wrap gap-4">
          <a
            href="/contact"
            className="ambient-shadow inline-flex items-center gap-3 rounded-xl bg-gradient-to-r from-primary to-primary-container px-7 py-4 text-sm font-bold uppercase tracking-[0.04em] text-white transition-transform hover:scale-[0.98]"
          >
            <span>Inquire About This Product</span>
            <HiOutlineArrowRight className="text-lg" />
          </a>
        </div>
      </div>
    </section>
  )
}
