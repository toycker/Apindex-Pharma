import Link from "next/link"
import { HiOutlineChevronRight } from "react-icons/hi2"

import type { PublicProductDetail } from "@/lib/data/public-product-detail"

type ProductBreadcrumbsSectionProps = {
  product: PublicProductDetail
}

export default function ProductBreadcrumbsSection({
  product,
}: ProductBreadcrumbsSectionProps) {
  return (
    <section className="content-container pt-10 md:pt-12">
      <nav className="flex flex-wrap items-center gap-2 text-[11px] font-bold uppercase tracking-[0.22em] text-[color:rgb(86_67_54/0.55)]">
        <Link href="/" className="transition-colors hover:text-[var(--apx-primary)]">
          Home
        </Link>
        <HiOutlineChevronRight className="text-sm" />
        <Link
          href="/products"
          className="transition-colors hover:text-[var(--apx-primary)]"
        >
          Products
        </Link>
        <HiOutlineChevronRight className="text-sm" />
        <span className="text-[var(--apx-on-surface)]">{product.name}</span>
      </nav>
    </section>
  )
}
