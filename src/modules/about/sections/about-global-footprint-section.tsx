"use client"

import { useMemo, useState } from "react"
import Image from "next/image"
import { MdAdd, MdRemove } from "react-icons/md"

type RegionItem = {
  id: string
  label: string
  description: string
}

const MAP_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuBMNz_jUhspacjupHGXN9NyESzVjiNYyW1181AkmHNdM_zJQZfvbjDM0jyXE0FSiEgHRoRJFYtNH33bKIhf0f0zrMXmSjJ64IOQDY__U5hocGlByFF78fj5a3PKxjvNGTCiV6wz72Nlw-SbAT-6yUzOM5n7ItGoEvTlRJG1op3Wfgj88bBBSEaDop0zrUt2YT5BXkpB4nCYYI7oPFVI01dsQi7UAaNUiX309pFAkOw28YjH3UbwhixwDnzTlHlOwBfDKJE8jYMYeyI"

const REGION_ITEMS: RegionItem[] = [
  {
    id: "africa",
    label: "Africa",
    description:
      "Established export relationships across high-growth African markets with stable supply planning and documentation support.",
  },
  {
    id: "asia",
    label: "Asia",
    description:
      "Regional market experience across South and Southeast Asia with responsive production alignment for evolving demand profiles.",
  },
  {
    id: "latam",
    label: "Latin America",
    description:
      "Partner-ready manufacturing for distribution programs that require consistent batch execution and traceable quality records.",
  },
  {
    id: "europe",
    label: "Europe",
    description:
      "Structured export workflows and dependable compliance discipline for customers operating in tightly controlled procurement environments.",
  },
]

export default function AboutGlobalFootprintSection() {
  const [openRegionId, setOpenRegionId] = useState("africa")

  const openRegion = useMemo(
    () => REGION_ITEMS.find((item) => item.id === openRegionId) ?? REGION_ITEMS[0],
    [openRegionId]
  )

  return (
    <section id="global-presence" className="bg-surface py-16 lg:py-24">
      <div className="content-container">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="section-heading">Global Footprint</h2>
          <p className="mt-3 section-description">
            Proudly serving regulated and emerging healthcare markets with quality-led
            pharmaceutical supply.
          </p>
        </div>

        <div className="mt-12 grid grid-cols-1 gap-12 lg:grid-cols-2">
          {/* Map panel */}
          <div className="relative overflow-hidden rounded-2xl bg-surface-high p-5">
            <div className="relative h-[220px] overflow-hidden rounded-xl bg-surface-low sm:h-[280px]">
              <Image
                fill
                sizes="(min-width: 1024px) 50vw, 100vw"
                src={MAP_IMAGE_URL}
                alt="World map showing Apindex international reach"
                className="object-cover object-center opacity-32 grayscale contrast-75"
              />
              <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(255,255,255,0.15)_0%,rgba(255,255,255,0)_100%)]" />
              {/* Map dots */}
              <div className="absolute left-[18%] top-[38%] h-2.5 w-2.5 rounded-full bg-primary ring-4 ring-primary/20" />
              <div className="absolute left-[47%] top-[32%] h-2.5 w-2.5 rounded-full bg-secondary ring-4 ring-secondary/25" />
              <div className="absolute left-[62%] top-[40%] h-2.5 w-2.5 rounded-full bg-primary ring-4 ring-primary/20" />
              <div className="absolute left-[72%] top-[48%] h-2.5 w-2.5 rounded-full bg-secondary ring-4 ring-secondary/25" />
            </div>
            <div className="mt-4 flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="text-[10px] font-bold uppercase tracking-[0.24em] text-on-surface-variant">
                  Active Region
                </p>
                <p className="apx-font-headline mt-1 text-xl font-bold text-on-surface">
                  {openRegion.label}
                </p>
              </div>
              <div className="rounded-full bg-surface-lowest px-3 py-1.5 text-[10px] font-bold uppercase tracking-[0.2em] text-primary">
                86+ Countries
              </div>
            </div>
          </div>

          {/* Accordion */}
          <div className="space-y-2">
            {REGION_ITEMS.map((item) => {
              const isOpen = item.id === openRegionId

              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => setOpenRegionId(item.id)}
                  className="w-full rounded-xl border border-outline-variant/50 bg-surface-lowest px-4 py-3 text-left transition-colors hover:border-primary-container"
                >
                  <div className="flex items-center justify-between gap-4">
                    <span className="apx-font-headline text-base font-bold text-on-surface">
                      {item.label}
                    </span>
                    <span
                      className={`flex h-6 w-6 items-center justify-center rounded-full ${
                        isOpen
                          ? "bg-primary/10 text-primary"
                          : "bg-surface-low text-on-surface-variant"
                      }`}
                    >
                      {isOpen ? (
                        <MdRemove aria-hidden="true" className="text-sm" />
                      ) : (
                        <MdAdd aria-hidden="true" className="text-sm" />
                      )}
                    </span>
                  </div>
                  {isOpen ? (
                    <p className="mt-2 max-w-sm text-sm leading-relaxed text-on-surface-variant">
                      {item.description}
                    </p>
                  ) : null}
                </button>
              )
            })}
          </div>
        </div>
      </div>
    </section>
  )
}
