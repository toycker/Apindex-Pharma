import type { IconType } from "react-icons"
import {
  HiOutlineExclamationTriangle,
  HiOutlineHeart,
  HiOutlineInformationCircle,
  HiOutlineShieldCheck,
  HiOutlineUserGroup,
} from "react-icons/hi2"
import { GiMedicines } from "react-icons/gi"
import { LuFlaskConical, LuStethoscope } from "react-icons/lu"

import type { PublicProductDetail } from "@/lib/data/public-product-detail"
import { getProductDescriptionParagraphs } from "@/modules/products/lib/product-detail-ui"

type ProductDetailContentSectionProps = {
  product: PublicProductDetail
}

const USE_ICONS: IconType[] = [
  LuStethoscope,
  HiOutlineUserGroup,
  HiOutlineShieldCheck,
  LuFlaskConical,
  HiOutlineHeart,
  GiMedicines,
]

function getUsesHeading(product: PublicProductDetail): string {
  return `${product.name} Uses`
}

export default function ProductDetailContentSection({
  product,
}: ProductDetailContentSectionProps) {
  const descriptionParagraphs = getProductDescriptionParagraphs(product)
  const details = product.pharmaDetails
  const uses = details?.uses ?? []
  const sideEffects = details?.sideEffects ?? []
  const composition = details?.composition ?? []
  const hasMechanismSection = Boolean(
    details?.pharmacodynamics || details?.therapeuticClass
  )
  const hasUsesSection = uses.length > 0
  const hasSideEffects = sideEffects.length > 0
  const hasComposition = composition.length > 0
  const hasSidebar = hasSideEffects || hasComposition

  return (
    <section className="mx-auto mt-8 w-full max-w-screen-2xl px-6 pb-24 md:px-8">
      <div className="grid grid-cols-1 gap-16 lg:grid-cols-12">
        <div className={hasSidebar ? "lg:col-span-8" : "lg:col-span-12"}>
          <div className="space-y-16">
            <div className="space-y-6">
              <div>
                <h2 className="apx-font-headline text-3xl font-extrabold tracking-tight text-[var(--apx-on-surface)] md:text-[2.15rem]">
                  What is {product.name}?
                </h2>
                <div className="mt-4 h-1.5 w-20 rounded-full bg-[var(--apx-secondary)]" />
              </div>

              <div className="space-y-4 text-lg leading-8 text-[var(--apx-on-surface-variant)]">
                {descriptionParagraphs.map((paragraph, index) => (
                  <p key={`${product.id}-paragraph-${index + 1}`}>{paragraph}</p>
                ))}
              </div>
            </div>

            {hasMechanismSection ? (
              <div className="space-y-6">
                <h2 className="apx-font-headline text-3xl font-extrabold tracking-tight text-[var(--apx-on-surface)] md:text-[2.15rem]">
                  Mechanism of Action &amp; Pharmacology
                </h2>

                <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                  {details?.pharmacodynamics ? (
                    <article className="rounded-[1.6rem] border-l-4 border-[var(--apx-primary)] bg-[var(--apx-surface-container-low)] p-7 shadow-sm">
                      <h3 className="apx-font-headline text-xl font-bold text-[var(--apx-on-surface)]">
                        Pharmacodynamics
                      </h3>
                      <p className="mt-3 text-sm leading-7 text-[var(--apx-on-surface-variant)]">
                        {details.pharmacodynamics}
                      </p>
                    </article>
                  ) : null}

                  {details?.therapeuticClass ? (
                    <article className="rounded-[1.6rem] border-l-4 border-[var(--apx-secondary)] bg-[var(--apx-surface-container-low)] p-7 shadow-sm">
                      <h3 className="apx-font-headline text-xl font-bold text-[var(--apx-on-surface)]">
                        Therapeutic Class
                      </h3>
                      <p className="mt-3 text-sm leading-7 text-[var(--apx-on-surface-variant)]">
                        {details.therapeuticClass}
                      </p>
                    </article>
                  ) : null}
                </div>
              </div>
            ) : null}

            {hasUsesSection ? (
              <div className="space-y-6">
                <h2 className="apx-font-headline text-3xl font-extrabold tracking-tight text-[var(--apx-on-surface)] md:text-[2.15rem]">
                  {getUsesHeading(product)}
                </h2>

                <ul className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  {uses.map((useItem, index) => {
                    const UseIcon = USE_ICONS[index % USE_ICONS.length]

                    return (
                      <li
                        key={`${useItem}-${index + 1}`}
                        className="flex items-center gap-4 rounded-2xl bg-white p-5 shadow-[0_14px_32px_rgba(86,67,54,0.06)]"
                      >
                        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-[color:rgb(175_246_121/0.18)] text-[var(--apx-secondary)]">
                          <UseIcon className="text-lg" />
                        </div>
                        <span className="text-sm font-semibold text-[var(--apx-on-surface)]">
                          {useItem}
                        </span>
                      </li>
                    )
                  })}
                </ul>
              </div>
            ) : null}
          </div>
        </div>

        {hasSidebar ? (
          <aside className="space-y-8 lg:col-span-4">
            {hasSideEffects ? (
              <div className="relative overflow-hidden rounded-[2rem] bg-[linear-gradient(180deg,var(--apx-primary)_0%,#b8610b_100%)] p-8 text-white shadow-[0_24px_50px_rgba(150,73,0,0.24)]">
                <div className="absolute right-0 top-0 p-7 text-white/10">
                  <HiOutlineExclamationTriangle className="text-8xl" />
                </div>

                <div className="relative z-10">
                  <h2 className="apx-font-headline text-2xl font-bold">
                    Common Side Effects
                  </h2>
                  <div className="mt-6 space-y-4">
                    {sideEffects.map((sideEffect, index) => (
                      <div
                        key={`${sideEffect}-${index + 1}`}
                        className="flex items-start gap-3"
                      >
                        <HiOutlineInformationCircle className="mt-0.5 text-[var(--apx-primary-fixed)]" />
                        <p className="text-sm leading-6 text-white/90">{sideEffect}</p>
                      </div>
                    ))}
                  </div>

                  <p className="mt-8 rounded-xl bg-white/12 p-4 text-xs font-medium leading-6 text-white/90">
                    Note: Consult your physician immediately if symptoms persist or
                    any severe reaction is observed.
                  </p>
                </div>
              </div>
            ) : null}

            {hasComposition ? (
              <div className="rounded-[1.7rem] bg-[var(--apx-surface-container-high)] p-8 shadow-sm">
                <h3 className="apx-font-headline text-xl font-bold text-[var(--apx-on-surface)]">
                  Composition
                </h3>
                <div className="mt-5 space-y-3">
                  {composition.map((item, index) => (
                    <div
                      key={`${item.ingredient}-${index + 1}`}
                      className={`flex items-center justify-between gap-4 py-2 ${
                        index < composition.length - 1
                          ? "border-b border-[color:rgb(138_114_100/0.14)]"
                          : ""
                      }`}
                    >
                      <span className="text-sm text-[var(--apx-on-surface-variant)]">
                        {item.ingredient}
                      </span>
                      <span className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--apx-on-surface)]">
                        {item.role || "Listed"}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            ) : null}
          </aside>
        ) : null}
      </div>
    </section>
  )
}
