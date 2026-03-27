"use client"

import { useState, useEffect } from "react"
import Image from "next/image"
import Link from "next/link"
import {
  FaWhatsapp,
  FaChevronUp,
  FaChevronLeft,
  FaChevronRight,
  FaTimes,
} from "react-icons/fa"
import { MdOutlineScience } from "react-icons/md"

import type { PublicCatalogResult } from "@/lib/data/public-catalog"

const CATALOG_DOSAGE_OPTIONS = [
  "Tablets",
  "Capsules",
  "Injections",
  "Drops",
  "Creams",
  "Syrups",
]
import { getProductIcon } from "@/modules/products/lib/catalog-ui"

type GalleryPageTemplateProps = {
  catalog: PublicCatalogResult
}

export default function GalleryPageTemplate({
  catalog,
}: GalleryPageTemplateProps) {
  const [filter, setFilter] = useState("Select All")
  const [showScroll, setShowScroll] = useState(false)
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)

  useEffect(() => {
    const handleScroll = () => {
      setShowScroll(window.scrollY > 300)
    }
    window.addEventListener("scroll", handleScroll)
    return () => window.removeEventListener("scroll", handleScroll)
  }, [])

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  // Keyboard navigation for slider
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (selectedIndex === null) return
      if (e.key === "Escape") setSelectedIndex(null)
      if (e.key === "ArrowLeft") handlePrev(e as unknown as React.MouseEvent)
      if (e.key === "ArrowRight") handleNext(e as unknown as React.MouseEvent)
    }

    if (selectedIndex !== null) {
      document.body.classList.add("modal-open")
      window.addEventListener("keydown", handleKeyDown)
    } else {
      document.body.classList.remove("modal-open")
    }

    return () => {
      document.body.classList.remove("modal-open")
      window.removeEventListener("keydown", handleKeyDown)
    }
  }, [selectedIndex])

  // Frontend filtering logic if needed.
  // For now we just display all fetched products since the API is paginated.
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

  const handleNext = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (selectedIndex !== null) {
      setSelectedIndex((selectedIndex + 1) % displayProducts.length)
    }
  }

  const handlePrev = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (selectedIndex !== null) {
      setSelectedIndex(
        (selectedIndex - 1 + displayProducts.length) % displayProducts.length
      )
    }
  }

  const handleClose = () => setSelectedIndex(null)

  return (
    <div className="apx-landing apx-font-body min-h-screen bg-[#f9fdfa] text-[var(--apx-on-surface)]">
      <main className="!pb-0 pt-[104px] mix-blend-normal">
        <div className="mx-auto w-full max-w-screen-xl px-4 py-8">
          {/* Header Section */}
          <div className="mb-12 flex flex-col items-center justify-between gap-6 md:flex-row">
            <h1 className="apx-font-headline flex items-center gap-2 text-xl lg:text-2xl font-bold tracking-tight">
              <span className="text-[var(--apx-primary-container)]  uppercase">
                Gallery
              </span>
              <span className="text-gray-500 lowercase text-[22px] font-semibold">
                of
              </span>
              <span className="text-[var(--apx-secondary)] uppercase">
                Apindex Pharma
              </span>
            </h1>

            <div className="flex items-center gap-2">
              <label
                htmlFor="gallery-filter"
                className="text-[15px] font-semibold text-gray-800"
              >
                Filter
              </label>
              <select
                id="gallery-filter"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                className="rounded border border-gray-300 bg-white px-3 py-1.5 text-[15px] font-medium text-gray-700 outline-none hover:border-gray-400 focus:border-[var(--apx-secondary)] focus:ring-1 focus:ring-[var(--apx-secondary)]"
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
          <div className="grid grid-cols-1 gap-[26px] sm:grid-cols-2 lg:grid-cols-4">
            {displayProducts.map((product, index) => {
              const FallbackIconComponent = getProductIcon(product)

              return (
                <div
                  key={product.id}
                  onClick={() => setSelectedIndex(index)}
                  className="group flex cursor-pointer flex-col justify-between overflow-hidden rounded-md bg-white shadow-[0_2px_18px_rgba(0,0,0,0.06)] transition-all hover:-translate-y-1 hover:shadow-[0_8px_30px_rgba(0,0,0,0.12)]"
                >
                  <div className="relative flex aspect-[4/3] w-full items-center justify-center p-6 bg-white">
                    {product.image_url ? (
                      <Image
                        src={product.image_url}
                        alt={product.name}
                        fill
                        className="object-contain p-6 mix-blend-multiply transition-transform duration-300 group-hover:scale-105"
                        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 25vw"
                      />
                    ) : (
                      <FallbackIconComponent className="h-28 w-28 text-gray-200 transition-colors group-hover:text-[var(--apx-secondary)]/40" />
                    )}
                  </div>

                  <div className="flex flex-1 flex-col justify-end bg-white p-5 text-center">
                    <h3 className="apx-font-headline text-[16px] leading-[1.3] font-bold text-gray-900 line-clamp-2">
                      {product.name}
                    </h3>
                  </div>
                </div>
              )
            })}
          </div>

          {displayProducts.length === 0 && (
            <div className="rounded-2xl border border-dashed border-gray-300 bg-white py-24 text-center">
              <h3 className="text-xl font-bold text-gray-800">
                No images found
              </h3>
              <p className="mt-2 text-gray-500 font-medium">
                Try selecting a different filter.
              </p>
            </div>
          )}
        </div>
      </main>

      {/* Lightbox / Slider Modal */}
      {selectedIndex !== null && displayProducts[selectedIndex] && (
        <div
          className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm transition-opacity"
          onClick={handleClose}
        >
          {/* Top Bar with Counter and Close Button */}
          <div className="absolute top-0 left-0 right-0 flex items-center justify-between p-4 px-6 text-white md:p-6 md:px-8">
            <span className="text-lg font-bold">
              {selectedIndex + 1}/{displayProducts.length}
            </span>
            <button
              onClick={handleClose}
              className="rounded-full p-2 transition-colors hover:bg-white/20"
              aria-label="Close slider"
            >
              <FaTimes className="text-3xl" />
            </button>
          </div>

          {/* Prev Button */}
          <button
            onClick={handlePrev}
            className="absolute left-2 top-1/2 z-10 -translate-y-1/2 rounded-full bg-black/40 p-2 text-white backdrop-blur-md transition-colors hover:bg-black/70 sm:left-6 md:p-3"
            aria-label="Previous"
          >
            <FaChevronLeft className="text-lg md:text-xl" />
          </button>

          {/* Main Image Container */}
          <div
            className="relative mx-14 flex aspect-square w-full max-w-4xl flex-col items-center justify-center rounded-lg bg-white p-6 shadow-2xl sm:mx-20 md:aspect-auto md:h-[80vh] md:p-12"
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
                <MdOutlineScience className="h-40 w-40 text-gray-200" />
              </div>
            )}
          </div>

          {/* Next Button */}
          <button
            onClick={handleNext}
            className="absolute right-2 top-1/2 z-10 -translate-y-1/2 rounded-full bg-black/40 p-2 text-white backdrop-blur-md transition-colors hover:bg-black/70 sm:right-6 md:p-3"
            aria-label="Next"
          >
            <FaChevronRight className="text-lg md:text-xl" />
          </button>
        </div>
      )}
    </div>
  )
}
