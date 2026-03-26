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
    <section id="global-presence" className="bg-white py-16 sm:py-20">
      <div className="mx-auto max-w-[1240px] px-4 sm:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="apx-font-headline text-[30px] font-extrabold tracking-[-0.03em] text-[var(--apx-on-surface)] sm:text-[42px]">
            Global Footprint
          </h2>
          <p className="mt-3 text-[12px] leading-6 text-[var(--apx-on-surface-variant)] sm:text-[13px]">
            Proudly serving regulated and emerging healthcare markets with quality-led
            pharmaceutical supply.
          </p>
        </div>

        <div className="mt-10 grid gap-5 lg:grid-cols-[minmax(0,1.38fr)_360px]">
          <div className="relative overflow-hidden rounded-[6px] bg-[#d9d8d4] p-4 shadow-[0_14px_28px_rgba(86,67,54,0.06)] sm:p-5">
            <div className="relative h-[220px] overflow-hidden rounded-[4px] bg-[linear-gradient(180deg,#c9c6c1_0%,#dbd8d3_100%)] sm:h-[280px]">
              <Image
                fill
                sizes="(min-width: 1024px) 60vw, 100vw"
                src={MAP_IMAGE_URL}
                alt="World map showing Apindex international reach"
                className="object-cover object-center opacity-32 grayscale contrast-75"
              />
              <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(255,255,255,0.15)_0%,rgba(255,255,255,0)_100%)]" />
              <div className="absolute left-[18%] top-[38%] h-2.5 w-2.5 rounded-full bg-[var(--apx-primary)] ring-4 ring-[color:rgb(245_130_32/0.18)]" />
              <div className="absolute left-[47%] top-[32%] h-2.5 w-2.5 rounded-full bg-[var(--apx-secondary)] ring-4 ring-[color:rgb(175_246_121/0.25)]" />
              <div className="absolute left-[62%] top-[40%] h-2.5 w-2.5 rounded-full bg-[var(--apx-primary)] ring-4 ring-[color:rgb(245_130_32/0.18)]" />
              <div className="absolute left-[72%] top-[48%] h-2.5 w-2.5 rounded-full bg-[var(--apx-secondary)] ring-4 ring-[color:rgb(175_246_121/0.25)]" />
            </div>
            <div className="mt-4 flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="text-[10px] font-bold uppercase tracking-[0.24em] text-zinc-500">
                  Active Region
                </p>
                <p className="apx-font-headline mt-1 text-xl font-bold text-[var(--apx-on-surface)]">
                  {openRegion.label}
                </p>
              </div>
              <div className="rounded-full bg-white px-3 py-1.5 text-[10px] font-bold uppercase tracking-[0.2em] text-[var(--apx-primary)]">
                86+ Countries
              </div>
            </div>
          </div>

          <div className="space-y-2">
            {REGION_ITEMS.map((item) => {
              const isOpen = item.id === openRegionId

              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => setOpenRegionId(item.id)}
                  className="w-full rounded-[4px] border border-[color:rgb(221_193_176/0.55)] bg-white px-4 py-3 text-left transition-colors hover:border-[var(--apx-primary-container)]"
                >
                  <div className="flex items-center justify-between gap-4">
                    <span className="apx-font-headline text-base font-bold text-[var(--apx-on-surface)]">
                      {item.label}
                    </span>
                    <span
                      className={`flex h-6 w-6 items-center justify-center rounded-full ${
                        isOpen
                          ? "bg-[color:rgb(150_73_0/0.1)] text-[var(--apx-primary)]"
                          : "bg-[var(--apx-surface-container-low)] text-zinc-500"
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
                    <p className="mt-2 max-w-sm text-[12px] leading-5 text-[var(--apx-on-surface-variant)]">
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
