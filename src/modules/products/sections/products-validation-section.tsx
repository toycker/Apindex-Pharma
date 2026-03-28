import Image from "next/image"

import { HiOutlineShieldCheck } from "react-icons/hi2"
import { LuFlaskConical } from "react-icons/lu"
import SectionBadge from "@/modules/common/components/section-badge"
import { VALIDATED_EXCELLENCE_IMAGE_URL } from "@/modules/products/lib/catalog-ui"

export default function ProductsValidationSection() {
  return (
    <section className="bg-surface-high py-16 lg:py-24">
      <div className="content-container grid gap-12 md:grid-cols-[minmax(0,1fr)_minmax(280px,520px)] md:items-center md:gap-16">
        <div>
          <div className="mb-4">
            <SectionBadge tone="secondary">Quality Assurance</SectionBadge>
          </div>
          <h2 className="section-heading">
            Validated Excellence
          </h2>
          <p className="mt-5 max-w-2xl section-description">
            Our manufacturing facilities are accredited by leading global health
            authorities. Every molecule is subjected to a strict validation
            process designed to maintain purity, consistency, and clinical
            confidence.
          </p>
          <div className="mt-8 grid gap-6 sm:grid-cols-2">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-secondary-container">
                <HiOutlineShieldCheck className="text-xl text-on-secondary-container" />
              </div>
              <div>
                <p className="text-sm font-bold text-on-surface">
                  GMP Certified
                </p>
                <p className="text-xs uppercase tracking-[0.16em] text-on-surface-variant">
                  Global Standard Compliance
                </p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-secondary-container">
                <LuFlaskConical className="text-xl text-on-secondary-container" />
              </div>
              <div>
                <p className="text-sm font-bold text-on-surface">
                  ISO 17025
                </p>
                <p className="text-xs uppercase tracking-[0.16em] text-on-surface-variant">
                  Laboratory Excellence
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="relative h-[320px] overflow-hidden rounded-2xl ambient-shadow md:h-[420px]">
          <Image
            src={VALIDATED_EXCELLENCE_IMAGE_URL}
            alt="Modern pharmaceutical manufacturing facility with stainless steel equipment and bright clinical lighting"
            fill
            sizes="(max-width: 768px) 100vw, 520px"
            className="object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-primary/20 to-transparent" />
        </div>
      </div>
    </section>
  )
}
