import Link from "next/link"

import type { PublicProductDetail } from "@/lib/data/public-product-detail"
import { MaterialSymbolIcon } from "@/modules/landing/components/material-symbol-icon"

type ProductBreadcrumbsSectionProps = {
  product: PublicProductDetail
}

export default function ProductBreadcrumbsSection({
  product,
}: ProductBreadcrumbsSectionProps) {
  return (
    <section className="mx-auto w-full max-w-screen-2xl px-6 pt-10 md:px-8 md:pt-12">
      <nav className="flex flex-wrap items-center gap-2 text-[11px] font-bold uppercase tracking-[0.22em] text-[color:rgb(86_67_54/0.55)]">
        <Link href="/" className="transition-colors hover:text-[var(--apx-primary)]">
          Home
        </Link>
        <MaterialSymbolIcon name="chevron_right" className="text-sm" />
        <Link
          href="/products"
          className="transition-colors hover:text-[var(--apx-primary)]"
        >
          Products
        </Link>
        <MaterialSymbolIcon name="chevron_right" className="text-sm" />
        <span className="text-[var(--apx-on-surface)]">{product.name}</span>
      </nav>
    </section>
  )
}
