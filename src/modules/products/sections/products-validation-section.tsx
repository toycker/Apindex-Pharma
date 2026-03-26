import Image from "next/image"

import { HiOutlineShieldCheck } from "react-icons/hi2"
import { LuFlaskConical } from "react-icons/lu"
import { VALIDATED_EXCELLENCE_IMAGE_URL } from "@/modules/products/lib/catalog-ui"

export default function ProductsValidationSection() {
  return (
    <section className="mt-8 bg-[var(--apx-surface-container-high)] px-6 py-20 md:px-8 md:py-24">
      <div className="mx-auto grid max-w-screen-2xl gap-12 md:grid-cols-[minmax(0,1fr)_minmax(280px,520px)] md:items-center md:gap-16">
        <div>
          <h2 className="apx-font-headline text-4xl font-extrabold tracking-tight text-[var(--apx-on-surface)]">
            Validated Excellence
          </h2>
          <p className="mt-5 max-w-2xl text-base leading-7 text-[var(--apx-on-surface-variant)] md:text-lg">
            Our manufacturing facilities are accredited by leading global health
            authorities. Every molecule is subjected to a strict validation process
            designed to maintain purity, consistency, and clinical confidence.
          </p>
          <div className="mt-8 grid gap-6 sm:grid-cols-2">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--apx-secondary-container)]">
                <HiOutlineShieldCheck className="text-xl text-[var(--apx-on-secondary-container)]" />
              </div>
              <div>
                <p className="text-sm font-bold text-[var(--apx-on-surface)]">GMP Certified</p>
                <p className="text-xs uppercase tracking-[0.16em] text-[var(--apx-on-surface-variant)]">
                  Global Standard Compliance
                </p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--apx-secondary-container)]">
                <LuFlaskConical className="text-xl text-[var(--apx-on-secondary-container)]" />
              </div>
              <div>
                <p className="text-sm font-bold text-[var(--apx-on-surface)]">ISO 17025</p>
                <p className="text-xs uppercase tracking-[0.16em] text-[var(--apx-on-surface-variant)]">
                  Laboratory Excellence
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="relative h-[320px] overflow-hidden rounded-[2rem] shadow-[0_24px_60px_rgba(86,67,54,0.12)] md:h-[420px]">
          <Image
            src={VALIDATED_EXCELLENCE_IMAGE_URL}
            alt="Modern pharmaceutical manufacturing facility with stainless steel equipment and bright clinical lighting"
            fill
            sizes="(max-width: 768px) 100vw, 520px"
            className="object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[color:rgb(150_73_0/0.18)] to-transparent" />
        </div>
      </div>
    </section>
  )
}
