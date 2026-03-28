"use client"

import { useState, useEffect } from "react"
import Image from "next/image"
import { FaChevronLeft, FaChevronRight, FaTimes } from "react-icons/fa"
import { MdOutlineScience } from "react-icons/md"

import type { PublicCatalogResult } from "@/lib/data/public-catalog"
import SectionBadge from "@/modules/common/components/section-badge"
import { getProductIcon } from "@/modules/products/lib/catalog-ui"

const CATALOG_DOSAGE_OPTIONS = [
  "Tablets",
  "Capsules",
  "Injections",
  "Drops",
  "Creams",
  "Syrups",
]

type GalleryPageTemplateProps = {
  catalog: PublicCatalogResult
}

export default function GalleryPageTemplate({
  catalog,
}: GalleryPageTemplateProps) {
  const [filter, setFilter] = useState("Select All")
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)

  // Frontend filtering
  let displayProducts = catalog.products
  if (filter !== "Select All" && filter !== "All Dosage Forms") {
    displayProducts = displayProducts.filter((p) => {
      const badge = (
        p.collections[0]?.title ||
        p.categories[0]?.name ||
        ""
      ).toLowerCase()
      return badge.includes(filter.toLowerCase().replace(/s$/, ""))
    })
  }

  const handlePrev = (e: React.MouseEvent) => {
    e.stopPropagation()
    setSelectedIndex((prev) =>
      prev !== null
        ? (prev - 1 + displayProducts.length) % displayProducts.length
        : null
    )
  }

  const handleNext = (e: React.MouseEvent) => {
    e.stopPropagation()
    setSelectedIndex((prev) =>
      prev !== null ? (prev + 1) % displayProducts.length : null
    )
  }

  const handleClose = () => setSelectedIndex(null)

  // Keyboard navigation for lightbox
  useEffect(() => {
    if (selectedIndex === null) {
      document.body.classList.remove("modal-open")
      return
    }

    document.body.classList.add("modal-open")

    const count = displayProducts.length
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setSelectedIndex(null)
      } else if (e.key === "ArrowLeft") {
        setSelectedIndex((prev) =>
          prev !== null ? (prev - 1 + count) % count : null
        )
      } else if (e.key === "ArrowRight") {
        setSelectedIndex((prev) =>
          prev !== null ? (prev + 1) % count : null
        )
      }
    }

    window.addEventListener("keydown", handleKeyDown)

    return () => {
      document.body.classList.remove("modal-open")
      window.removeEventListener("keydown", handleKeyDown)
    }
  }, [selectedIndex, displayProducts.length])

  return (
    <div className="apx-landing apx-font-body min-h-screen bg-surface text-on-surface">
      <main className="!pb-0 pt-[104px] mix-blend-normal">
        <div className="content-container py-8">
          {/* Header Section */}
          <div className="mb-12 flex flex-col items-start justify-between gap-6 md:flex-row md:items-end">
            <div>
              <SectionBadge tone="primary" className="mb-3">
                Product Showcase
              </SectionBadge>
              <h1 className="apx-font-headline text-3xl font-bold tracking-tight text-on-surface md:text-4xl">
                Product <span className="text-secondary">Gallery</span>
              </h1>
            </div>

            <div className="flex items-center gap-2">
              <label
                htmlFor="gallery-filter"
                className="text-sm font-semibold text-on-surface"
              >
                Filter
              </label>
              <select
                id="gallery-filter"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                className="rounded-xl border border-outline-variant bg-surface-lowest px-3 py-1.5 text-sm font-medium text-on-surface outline-none hover:border-outline-variant focus:border-secondary focus:ring-1 focus:ring-secondary"
              >
                <option value="Select All">Select All</option>
                {CATALOG_DOSAGE_OPTIONS.map((option) => (
                  <option key={option} value={option}>
                    {option}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Grid Section */}
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {displayProducts.map((product, index) => {
              const FallbackIconComponent = getProductIcon(product)

              return (
                <div
                  key={product.id}
                  onClick={() => setSelectedIndex(index)}
                  className="group flex cursor-pointer flex-col justify-between overflow-hidden rounded-2xl bg-surface-lowest ambient-shadow transition-all hover:-translate-y-1 hover:shadow-lg"
                >
                  <div className="relative flex aspect-[4/3] w-full items-center justify-center bg-surface-lowest p-6">
                    {product.image_url ? (
                      <Image
                        src={product.image_url}
                        alt={product.name}
                        fill
                        className="object-contain p-6 mix-blend-multiply transition-transform duration-300 group-hover:scale-105"
                        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 25vw"
                      />
                    ) : (
                      <FallbackIconComponent className="h-28 w-28 text-on-surface-variant/20 transition-colors group-hover:text-secondary/40" />
                    )}
                  </div>

                  <div className="flex flex-1 flex-col justify-end bg-surface-lowest p-5 text-center">
                    <h3 className="apx-font-headline text-base font-bold leading-[1.3] text-on-surface line-clamp-2">
                      {product.name}
                    </h3>
                  </div>
                </div>
              )
            })}
          </div>

          {displayProducts.length === 0 && (
            <div className="rounded-2xl border border-dashed border-outline-variant/50 bg-surface-low py-24 text-center">
              <h3 className="text-xl font-bold text-on-surface">
                No images found
              </h3>
              <p className="mt-2 font-medium text-on-surface-variant">
                Try selecting a different filter.
              </p>
            </div>
          )}
        </div>
      </main>

      {/* Lightbox / Slider Modal */}
      {selectedIndex !== null && displayProducts[selectedIndex] && (
        <div
          role="dialog"
          aria-modal="true"
          aria-label="Product image viewer"
          className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm transition-opacity"
          onClick={handleClose}
        >
          {/* Top Bar with Counter and Close Button */}
          <div className="absolute left-0 right-0 top-0 flex items-center justify-between p-4 px-6 text-white md:p-6 md:px-8">
            <span className="text-lg font-bold">
              {selectedIndex + 1}/{displayProducts.length}
            </span>
            <button
              onClick={handleClose}
              className="rounded-full p-2 transition-colors hover:bg-white/20"
              aria-label="Close lightbox"
            >
              <FaTimes className="text-3xl" />
            </button>
          </div>

          {/* Prev Button */}
          <button
            onClick={handlePrev}
            className="absolute left-2 top-1/2 z-10 -translate-y-1/2 rounded-full bg-black/40 p-2 text-white backdrop-blur-md transition-colors hover:bg-black/70 sm:left-6 md:p-3"
            aria-label="Previous product"
          >
            <FaChevronLeft className="text-lg md:text-xl" />
          </button>

          {/* Main Image Container */}
          <div
            className="relative mx-14 flex aspect-square w-full max-w-4xl flex-col items-center justify-center rounded-2xl bg-surface-lowest p-6 shadow-2xl sm:mx-20 md:aspect-auto md:h-[80vh] md:p-12"
            onClick={(e) => e.stopPropagation()}
          >
            {displayProducts[selectedIndex].image_url ? (
              <div className="relative h-full w-full flex-1">
                <Image
                  src={displayProducts[selectedIndex].image_url!}
                  alt={displayProducts[selectedIndex].name}
                  fill
                  className="object-contain"
                  sizes="100vw"
                />
              </div>
            ) : (
              <div className="flex h-full w-full flex-1 items-center justify-center">
                <MdOutlineScience className="h-40 w-40 text-on-surface-variant/20" />
              </div>
            )}
          </div>

          {/* Next Button */}
          <button
            onClick={handleNext}
            className="absolute right-2 top-1/2 z-10 -translate-y-1/2 rounded-full bg-black/40 p-2 text-white backdrop-blur-md transition-colors hover:bg-black/70 sm:right-6 md:p-3"
            aria-label="Next product"
          >
            <FaChevronRight className="text-lg md:text-xl" />
          </button>
        </div>
      )}
    </div>
  )
}
