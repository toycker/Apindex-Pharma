import type { IconType } from "react-icons"
import {
  FaCapsules,
  FaEyeDropper,
  FaSyringe,
  FaTablets,
} from "react-icons/fa"
import { MdApps, MdSanitizer } from "react-icons/md"
import { TbMedicineSyrup } from "react-icons/tb"
import SectionBadge from "@modules/common/components/section-badge"

type CategoryCard = {
  icon: IconType
  title: string
  bgClass: string
}

const CATEGORY_CARDS: CategoryCard[] = [
  {
    icon: FaTablets,
    title: "Tablet",
    bgClass: "bg-amber-500",
  },
  {
    icon: FaCapsules,
    title: "Capsule",
    bgClass: "bg-blue-600",
  },
  {
    icon: FaEyeDropper,
    title: "Eye / EarDrops",
    bgClass: "bg-green-600",
  },
  {
    icon: FaSyringe,
    title: "Injection",
    bgClass: "bg-red-800",
  },
  {
    icon: MdSanitizer,
    title: "Creams",
    bgClass: "bg-purple-600",
  },
  {
    icon: TbMedicineSyrup,
    title: "Suspension / Syrup",
    bgClass: "bg-slate-700",
  },
  {
    icon: MdApps,
    title: "Other",
    bgClass: "bg-yellow-500",
  },
]

export default function CategoriesSection() {
  return (
    <section id="categories" className="bg-surface-low py-16 lg:py-24">
      <div className="content-container">
        <div className="mb-16 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
          <div className="max-w-2xl">
            <SectionBadge tone="secondary" className="mb-4">Dosage Forms</SectionBadge>
            <h2 className="section-heading">
              Product <span className="text-secondary">Categories</span>
            </h2>
          </div>
          <div className="mx-12 mb-4 hidden h-px flex-grow bg-outline-variant/30 md:block" />
          <p className="section-description max-w-xs font-serif italic">
            Engineered for every therapeutic need and patient requirement.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-4 sm:grid-cols-4 lg:grid-cols-7">
          {CATEGORY_CARDS.map((card) => {
            const Icon = card.icon
            return (
              <div
                key={card.title}
                className={`group flex flex-col items-center justify-center rounded-xl px-4 py-8 text-center text-white transition-transform duration-300 hover:-translate-y-2 ${card.bgClass}`}
              >
                <Icon
                  aria-hidden="true"
                  className="mb-4 text-5xl opacity-90 transition-opacity group-hover:opacity-100"
                />
                <h3 className="apx-font-headline text-sm font-bold leading-tight">
                  {card.title}
                </h3>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
