"use client"

import { useEffect, useState } from "react"
import { Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline"
import Image from "next/image"
import Link from "next/link"
import { usePathname } from "next/navigation"

type NavItem = {
  label: string
  href: string
}

const NAV_ITEMS: NavItem[] = [
  { label: "Home", href: "/" },
  { label: "About", href: "/about" },
  { label: "Products", href: "/products" },
  { label: "Gallery", href: "/gallery" },
  { label: "Contact", href: "/contact" },
]

function normalizePathname(pathname: string) {
  if (pathname === "/") {
    return pathname
  }

  return pathname.endsWith("/") ? pathname.slice(0, -1) : pathname
}

function isNavItemActive(pathname: string, href: string) {
  if (href === "/") {
    return pathname === "/"
  }

  return pathname === href || pathname.startsWith(`${href}/`)
}

export default function TopNavBar() {
  const pathname = normalizePathname(usePathname() ?? "/")
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const quoteHref =
    pathname === "/contact" ? "#contact-form" : "/contact#contact-form"

  useEffect(() => {
    setIsMobileMenuOpen(false)
  }, [pathname])

  return (
    <nav className="glass-nav fixed top-0 z-50 w-full bg-white shadow-md">
      <div className="mx-auto flex w-full max-w-screen-2xl items-center justify-between gap-4 px-4 py-3 sm:px-6 sm:py-4 lg:px-8">
        <Link href="/" aria-label="Apindex home" className="shrink-0">
          <Image
            src="/apindex-logo.jpg"
            alt="Apindex"
            width={1920}
            height={1187}
            priority
            quality={100}
            className="h-14 w-auto object-contain"
          />
        </Link>

        <div className="hidden items-center gap-8 md:flex">
          {NAV_ITEMS.map((item) => {
            const isActive = isNavItemActive(pathname, item.href)

            return (
              <Link
                key={item.label}
                href={item.href}
                aria-current={isActive ? "page" : undefined}
                className={`apx-font-headline text-sm font-semibold uppercase tracking-wide transition-colors ${
                  isActive
                    ? "border-b-2 border-[var(--apx-primary)] pb-1 text-[var(--apx-primary)]"
                    : "text-zinc-600 hover:text-[var(--apx-primary)]"
                }`}
              >
                {item.label}
              </Link>
            )
          })}
        </div>

        <button
          type="button"
          aria-expanded={isMobileMenuOpen}
          aria-controls="apindex-mobile-navigation"
          aria-label={
            isMobileMenuOpen ? "Close navigation menu" : "Open navigation menu"
          }
          onClick={() => setIsMobileMenuOpen((currentValue) => !currentValue)}
          className="inline-flex h-11 w-11 items-center justify-center rounded-xl border border-[color:rgb(150_73_0/0.14)] bg-white text-[var(--apx-primary)] transition-colors hover:border-[var(--apx-primary)] hover:text-[var(--apx-primary)] md:hidden"
        >
          {isMobileMenuOpen ? (
            <XMarkIcon className="h-6 w-6" />
          ) : (
            <Bars3Icon className="h-6 w-6" />
          )}
        </button>

        <Link
          href={quoteHref}
          className="ambient-shadow hidden rounded-md bg-[var(--apx-primary-container)] px-5 py-2.5 text-sm font-semibold text-white md:inline-flex"
        >
          Request a Quote
        </Link>
      </div>

      {isMobileMenuOpen ? (
        <div
          id="apindex-mobile-navigation"
          className="border-t border-[color:rgb(150_73_0/0.1)] bg-white/95 px-4 py-4 shadow-lg backdrop-blur md:hidden"
        >
          <div className="mx-auto flex w-full max-w-screen-2xl flex-col gap-2">
            {NAV_ITEMS.map((item) => {
              const isActive = isNavItemActive(pathname, item.href)

              return (
                <Link
                  key={item.label}
                  href={item.href}
                  aria-current={isActive ? "page" : undefined}
                  className={`rounded-xl px-4 py-3 text-sm font-semibold uppercase tracking-[0.16em] transition-colors ${
                    isActive
                      ? "bg-[color:rgb(150_73_0/0.08)] text-[var(--apx-primary)]"
                      : "text-zinc-700 hover:bg-zinc-100 hover:text-[var(--apx-primary)]"
                  }`}
                >
                  {item.label}
                </Link>
              )
            })}

            <Link
              href={quoteHref}
              className="mt-2 inline-flex items-center justify-center rounded-xl bg-[var(--apx-primary-container)] px-4 py-3 text-sm font-semibold text-white"
            >
              Request a Quote
            </Link>
          </div>
        </div>
      ) : null}
    </nav>
  )
}
