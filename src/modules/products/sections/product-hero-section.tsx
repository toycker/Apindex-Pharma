import Image from "next/image"

import type { PublicProductDetail } from "@/lib/data/public-product-detail"
import { MaterialSymbolIcon } from "@/modules/landing/components/material-symbol-icon"
import {
  buildProductBrochureHref,
  buildProductDetailEnquiryHref,
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
  const therapeuticFallback =
    details?.therapeuticUse ||
    product.categories.map((category) => category.name).join(", ") ||
    "Available on request"

  return [
    {
      label: "Trade Name",
      value: details?.tradeName || "Available on request",
    },
    {
      label: "Available Strength",
      value: details?.availableStrength || "Available on request",
    },
    {
      label: "Packing",
      value: details?.packing || "Available on request",
    },
    {
      label: "Pack Insert / Leaflet",
      value:
        details?.packInsertLeaflet === true
          ? "Yes"
          : details?.packInsertLeaflet === false
            ? "No"
            : "Available on request",
      highlighted: details?.packInsertLeaflet === true,
    },
    {
      label: "Therapeutic Use",
      value: therapeuticFallback,
    },
    {
      label: "Production Capacity",
      value: details?.productionCapacity || "Available on request",
    },
  ]
}

export default function ProductHeroSection({ product }: ProductHeroSectionProps) {
  const headline = buildProductHeadline(product.name)
  const enquiryHref = buildProductDetailEnquiryHref(product)
  const brochureHref = buildProductBrochureHref(product)
  const hasExternalBrochure = brochureHref.startsWith("http")
  const specItems = buildSpecItems(product)

  return (
    <section className="mx-auto grid w-full max-w-screen-2xl grid-cols-1 gap-12 px-6 pb-10 pt-8 md:px-8 lg:grid-cols-12 lg:items-start lg:gap-14 lg:pb-16">
      <div className="relative lg:col-span-5">
        <div className="relative overflow-hidden rounded-[2rem] bg-[var(--apx-surface-container-low)] p-6 shadow-[0_18px_40px_rgba(86,67,54,0.08)] md:p-10">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(175,246,121,0.22),transparent_45%),radial-gradient(circle_at_bottom_right,rgba(245,130,32,0.14),transparent_45%)]" />

          <div className="relative aspect-square overflow-hidden rounded-[1.5rem] bg-[#0f4d63] p-6 md:p-10">
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
              <div className="flex h-full items-center justify-center rounded-[1.25rem] border border-white/10 bg-white/10 text-white/80">
                <MaterialSymbolIcon name="local_pharmacy" className="text-7xl" />
              </div>
            )}
          </div>
        </div>

        <div className="absolute -bottom-6 -right-4 h-28 w-28 rounded-full bg-[color:rgb(175_246_121/0.34)] blur-3xl" />
      </div>

      <div className="lg:col-span-7">
        <span className="mb-4 inline-flex items-center rounded-full bg-[var(--apx-secondary-container)] px-3 py-1 text-[10px] font-bold uppercase tracking-[0.18em] text-[var(--apx-on-secondary-container)]">
          {getProductHeroBadge(product)}
        </span>

        <h1 className="apx-font-headline text-4xl font-extrabold leading-[1.06] tracking-[-0.05em] text-[var(--apx-on-surface)] md:text-5xl lg:text-[3.65rem]">
          {headline.primary}
          {headline.accent ? (
            <>
              <br />
              <span className="text-[var(--apx-primary-container)]">{headline.accent}</span>
            </>
          ) : null}
        </h1>

        <div className="mt-8 rounded-[1.6rem] bg-[color:rgb(245_243_243/0.96)] p-6 md:p-8">
          <div className="grid grid-cols-1 gap-x-10 gap-y-6 md:grid-cols-2">
            {specItems.map((item) => (
              <div key={item.label} className="space-y-1">
                <p className="text-[10px] font-bold uppercase tracking-[0.22em] text-[color:rgb(86_67_54/0.68)]">
                  {item.label}
                </p>
                {item.highlighted ? (
                  <div className="flex items-center gap-2 text-sm font-bold text-[var(--apx-secondary)]">
                    <MaterialSymbolIcon name="check_circle" className="text-base" />
                    <span>{item.value}</span>
                  </div>
                ) : (
                  <p className="text-sm font-semibold text-[var(--apx-on-surface)] md:text-base">
                    {item.value}
                  </p>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="mt-8 flex flex-wrap gap-4">
          <a
            href={enquiryHref}
            className="ambient-shadow inline-flex items-center gap-3 rounded-xl bg-gradient-to-r from-[var(--apx-primary)] to-[var(--apx-primary-container)] px-7 py-4 text-sm font-bold uppercase tracking-[0.04em] text-white transition-transform hover:scale-[0.98]"
          >
            <span>Inquire About This Product</span>
            <MaterialSymbolIcon name="arrow_forward" className="text-lg" />
          </a>

          <a
            href={brochureHref}
            target={hasExternalBrochure ? "_blank" : undefined}
            rel={hasExternalBrochure ? "noreferrer" : undefined}
            className="inline-flex items-center gap-3 rounded-xl bg-[var(--apx-surface-container-high)] px-7 py-4 text-sm font-bold text-[var(--apx-on-surface)] transition-colors hover:bg-[color:rgb(228_226_226/0.92)]"
          >
            <MaterialSymbolIcon name="download" className="text-lg" />
            <span>Product Brochure</span>
          </a>
        </div>
      </div>
    </section>
  )
}
