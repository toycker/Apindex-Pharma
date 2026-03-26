import Image from "next/image"
import Link from "next/link"

type NavPage = "home" | "about" | "contact"

type NavItem = {
  label: string
  href: string
  homeHref?: string
  aboutHref?: string
  contactHref?: string
}

const NAV_ITEMS: NavItem[] = [
  { label: "About", href: "/about", homeHref: "/about", contactHref: "/about" },
  { label: "Products", href: "#products", aboutHref: "/#products", contactHref: "/#products" },
  {
    label: "Global Presence",
    href: "#global-presence",
    aboutHref: "#global-presence",
    contactHref: "/#global-presence",
  },
  {
    label: "Infrastructure",
    href: "#infrastructure",
    aboutHref: "/#infrastructure",
    contactHref: "/#infrastructure",
  },
  { label: "Contact", href: "/contact", aboutHref: "/contact", contactHref: "/contact" },
]

type TopNavBarProps = {
  currentPage?: NavPage
}

export default function TopNavBar({ currentPage = "home" }: TopNavBarProps) {
  const resolveHref = (item: NavItem) => {
    if (currentPage === "about") {
      return item.aboutHref ?? item.href
    }

    if (currentPage === "contact") {
      return item.contactHref ?? item.href
    }

    return item.homeHref ?? item.href
  }

  return (
    <nav className="glass-nav fixed top-0 z-50 w-full bg-white/80 shadow-sm">
      <div className="mx-auto flex w-full max-w-screen-2xl items-center justify-between px-8 py-4">
        <Link href="/" aria-label="Apindex home" className="relative block h-10 w-[170px]">
          <Image
            src="/apindex-logo.jpg"
            alt="Apindex"
            fill
            priority
            sizes="170px"
            className="object-contain object-left"
          />
        </Link>

        <div className="hidden items-center gap-8 md:flex">
          {NAV_ITEMS.map((item) => (
            <Link
              key={item.label}
              href={resolveHref(item)}
              className={`apx-font-headline text-sm font-semibold uppercase tracking-wide transition-colors ${
                currentPage !== "home" && item.label.toLowerCase() === currentPage
                  ? "border-b-2 border-[var(--apx-primary)] pb-1 text-[var(--apx-primary)]"
                  : "text-zinc-600 hover:text-[var(--apx-primary)]"
              }`}
            >
              {item.label}
            </Link>
          ))}
        </div>

        <a
          href={currentPage === "contact" ? "#contact-form" : "/contact#contact-form"}
          className="ambient-shadow rounded-md bg-gradient-to-r from-[var(--apx-primary)] to-[var(--apx-primary-container)] px-6 py-2.5 text-sm font-semibold text-white transition-transform duration-200 ease-in-out hover:scale-95"
        >
          Request a Quote
        </a>
      </div>
    </nav>
  )
}
