import Image from "next/image"
import Link from "next/link"
import { MdCall, MdLocationOn, MdMail } from "react-icons/md"

type NavLink = {
  label: string
  href: string
}

const QUICK_LINKS: NavLink[] = [
  { label: "Home", href: "/" },
  { label: "About", href: "/about" },
  { label: "Products", href: "/products" },
  { label: "Gallery", href: "/gallery" },
  { label: "Contact", href: "/contact" },
]

export default function FooterSection() {
  return (
    <footer id="contact" className="apx-font-body bg-zinc-50">
      <div className="content-container">
        <div className="mx-auto grid max-w-screen-2xl grid-cols-1 gap-12 py-16 sm:grid-cols-2 lg:grid-cols-4">
          {/* Col 1: Logo + description */}
          <div className="space-y-5">
            <Image
              src="/apindex-logo.jpg"
              alt="Apindex"
              width={1920}
              height={1187}
              quality={100}
              className="h-28 w-auto object-contain"
            />
            <p className="text-sm leading-relaxed text-zinc-500">
              A WHO-GMP certified pharmaceutical company dedicated to delivering
              high-quality medicines across 86+ countries worldwide.
            </p>
          </div>

          {/* Col 2: Quick Links */}
          <div className="space-y-5">
            <h4 className="apx-font-headline font-bold text-on-surface">
              Quick Links
            </h4>
            <ul className="space-y-3">
              {QUICK_LINKS.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-sm text-zinc-600 transition-colors hover:text-primary"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Col 3: Certifications */}
          <div className="space-y-5">
            <h4 className="apx-font-headline font-bold text-on-surface">
              Certifications
            </h4>
            <ul className="space-y-3">
              {[
                "WHO-GMP Certified",
                "ISO 9001:2015",
                "GLP Compliance",
                "FDCA Approved",
                "MSME Registered",
              ].map((cert) => (
                <li key={cert} className="text-sm text-zinc-600">
                  {cert}
                </li>
              ))}
            </ul>
          </div>

          {/* Col 4: Contact */}
          <div className="min-w-0 space-y-5">
            <h4 className="apx-font-headline font-bold text-on-surface">
              Contact Us
            </h4>
            <div className="space-y-4">
              <div className="flex items-start gap-3">
                <MdLocationOn
                  aria-hidden="true"
                  className="mt-0.5 flex-shrink-0 text-lg text-primary"
                />
                <p className="break-words text-sm text-zinc-600">
                  Head Office: 123 Pharma Estate, Innovation Park, Healthcare
                  Zone, 380001
                </p>
              </div>
              <div className="flex items-center gap-3">
                <MdCall
                  aria-hidden="true"
                  className="flex-shrink-0 text-lg text-primary"
                />
                <p className="text-sm text-zinc-600">+91 2345678900</p>
              </div>
              <div className="flex items-center gap-3">
                <MdMail
                  aria-hidden="true"
                  className="flex-shrink-0 text-lg text-primary"
                />
                <p className="break-all text-sm text-zinc-600">
                  contact@apindexpharma.com
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom bar */}
      <div className="mx-auto max-w-screen-2xl px-8 pb-10">
        <div className="flex flex-col items-center justify-center border-t border-outline-variant/20 pt-8">
          <p className="text-sm text-zinc-500">
            &copy; {new Date().getFullYear()} Apindex Pharmaceuticals. All
            rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}
