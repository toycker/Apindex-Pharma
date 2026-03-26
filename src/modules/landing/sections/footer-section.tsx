import Image from "next/image"
import {
  MdAlternateEmail,
  MdCall,
  MdLeaderboard,
  MdLocationOn,
  MdMail,
  MdPublic,
} from "react-icons/md"

type FooterLink = {
  label: string
  href: string
}

const CAPABILITY_LINKS: FooterLink[] = [
  { label: "Contract Manufacturing", href: "#" },
  { label: "3rd Party Manufacturing", href: "#" },
  { label: "Generic Products", href: "#" },
  { label: "R&D Facilities", href: "#" },
]

const CERTIFICATION_LINKS: FooterLink[] = [
  { label: "Privacy Policy", href: "#" },
  { label: "Terms of Service", href: "#" },
]

export default function FooterSection() {
  return (
    <footer id="contact" className="border-t-0 bg-zinc-50">
      <div className="mx-auto grid max-w-screen-2xl grid-cols-1 gap-12 px-12 py-20 md:grid-cols-4">
        <div className="space-y-6">
          <Image
            src="/apindex-logo.jpg"
            alt="Apindex"
            width={1920}
            height={1187}
            quality={100}
            className="h-14 w-auto object-contain sm:h-16"
          />
          <p className="apx-font-body text-sm leading-relaxed text-zinc-500">
            Precision in Chemistry. A pharmaceutical leader dedicated to global health
            standards and innovative manufacturing.
          </p>
          <div className="flex gap-4">
            <MdLeaderboard
              aria-hidden="true"
              className="cursor-pointer text-[var(--apx-primary)] transition-transform hover:scale-110"
            />
            <MdAlternateEmail
              aria-hidden="true"
              className="cursor-pointer text-[var(--apx-primary)] transition-transform hover:scale-110"
            />
            <MdPublic
              aria-hidden="true"
              className="cursor-pointer text-[var(--apx-primary)] transition-transform hover:scale-110"
            />
          </div>
        </div>

        <div className="space-y-6">
          <h4 className="apx-font-headline font-bold text-[var(--apx-on-surface)]">Capabilities</h4>
          <ul className="space-y-3">
            {CAPABILITY_LINKS.map((link) => (
              <li key={link.label}>
                <a
                  href={link.href}
                  className="apx-font-body text-sm text-zinc-600 transition-colors hover:text-[var(--apx-primary)] hover:underline decoration-[var(--apx-secondary)] decoration-2 underline-offset-4"
                >
                  {link.label}
                </a>
              </li>
            ))}
          </ul>
        </div>

        <div className="space-y-6">
          <h4 className="apx-font-headline font-bold text-[var(--apx-on-surface)]">
            Certifications
          </h4>
          <ul className="space-y-3">
            <li className="apx-font-body text-sm text-zinc-600">WHO-GMP Certified</li>
            <li className="apx-font-body text-sm text-zinc-600">ISO 9001:2015 Standards</li>
            {CERTIFICATION_LINKS.map((link) => (
              <li key={link.label}>
                <a
                  href={link.href}
                  className="apx-font-body text-sm text-zinc-600 transition-colors hover:text-[var(--apx-primary)]"
                >
                  {link.label}
                </a>
              </li>
            ))}
          </ul>
        </div>

        <div className="space-y-6">
          <h4 className="apx-font-headline font-bold text-[var(--apx-on-surface)]">Contact Us</h4>
          <div className="space-y-4">
            <div className="flex items-start gap-3">
              <MdLocationOn
                aria-hidden="true"
                className="mt-1 flex-shrink-0 text-[var(--apx-primary)]"
              />
              <p className="text-sm text-zinc-600">
                Head Office: 123 Pharma Estate, Innovation Park, Healthcare Zone,
                380001
              </p>
            </div>
            <div className="flex items-center gap-3">
              <MdCall aria-hidden="true" className="flex-shrink-0 text-[var(--apx-primary)]" />
              <p className="text-sm text-zinc-600">+91 2345678900</p>
            </div>
            <div className="flex items-center gap-3">
              <MdMail aria-hidden="true" className="flex-shrink-0 text-[var(--apx-primary)]" />
              <p className="text-sm text-zinc-600">contact@apindexpharma.com</p>
            </div>
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-screen-2xl px-12 pb-12">
        <div className="flex flex-col items-center justify-between gap-4 border-t border-[color:rgb(221_193_176/0.2)] pt-8 md:flex-row">
          <p className="apx-font-body text-sm text-zinc-500">
            &copy; 2024 Apindex Pharmaceuticals. All rights reserved. Precision in Chemistry.
          </p>
          <div className="flex gap-6 text-xs font-bold uppercase tracking-widest text-zinc-400">
            <span>Quality</span>
            <span>Safety</span>
            <span>Efficacy</span>
          </div>
        </div>
      </div>
    </footer>
  )
}
