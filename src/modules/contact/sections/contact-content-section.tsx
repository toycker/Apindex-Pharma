import { ChevronDown, Mail, MapPin, Phone, Send } from "lucide-react"
import type { ReactNode } from "react"

const GOOGLE_MAP_EMBED_URL =
  "https://www.google.com/maps?q=1200%20Innovation%20Drive%2C%20Cambridge%2C%20MA%2002142%2C%20USA&z=14&hl=en&gl=US&output=embed"

const CONTACT_ITEMS = [
  {
    label: "Global HQ",
    value: (
      <>
        1200 Innovation Drive, Biotech Plaza
        <br />
        Cambridge, MA 02142, USA
      </>
    ),
    icon: MapPin,
    tone: "primary",
    subtext: null,
  },
  {
    label: "Direct Line",
    value: "+1 (555) 890-2100",
    icon: Phone,
    tone: "secondary",
    subtext: "Mon - Fri, 9am - 6pm EST",
  },
  {
    label: "Inquiries",
    value: "precision@apindex.com",
    icon: Mail,
    tone: "primary",
    subtext: "General & Media Relations",
  },
] as const

const COUNTRIES = ["United States", "Switzerland", "Germany", "Japan", "Other"]

const ICON_TONE_CLASS = {
  primary: "text-[var(--apx-primary)]",
  secondary: "text-[var(--apx-secondary)]",
} as const

export default function ContactContentSection() {
  return (
    <section className="bg-[var(--apx-surface)] py-16 sm:py-24">
      <div className="content-container">
        <div className="grid grid-cols-1 gap-12 lg:grid-cols-12 lg:gap-16">
          <div className="space-y-12 lg:col-span-5">
            <div>
              <h2 className="apx-font-headline mb-8 text-[36px] font-bold tracking-[-0.03em] text-[var(--apx-on-surface)]">
                Corporate Headquarters
              </h2>
              <div className="space-y-8">
                {CONTACT_ITEMS.map((item) => {
                  const Icon = item.icon

                  return (
                    <div key={item.label} className="group flex items-start gap-6">
                      <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-[var(--apx-surface-container-high)] transition-transform group-hover:scale-110">
                        <Icon className={`h-7 w-7 ${ICON_TONE_CLASS[item.tone]}`} strokeWidth={2.2} />
                      </div>
                      <div>
                        <h3 className="apx-font-headline mb-1 text-sm font-bold uppercase tracking-[0.22em] text-[var(--apx-on-surface-variant)]">
                          {item.label}
                        </h3>
                        <p className="text-lg leading-[1.65] text-[var(--apx-on-surface)]">
                          {item.value}
                        </p>
                        {item.subtext ? (
                          <p className="mt-1 text-sm text-[var(--apx-on-surface-variant)]">
                            {item.subtext}
                          </p>
                        ) : null}
                      </div>
                    </div>
                  )
                })}
              </div>
            </div>

            <div className="ambient-shadow relative h-72 overflow-hidden rounded-2xl bg-[var(--apx-surface-container-high)] ring-1 ring-[color:rgb(221_193_176/0.25)]">
              <iframe
                title="Apindex Cambridge Headquarters Map"
                src={GOOGLE_MAP_EMBED_URL}
                loading="lazy"
                referrerPolicy="no-referrer-when-downgrade"
                className="absolute inset-0 h-full w-full border-0 saturate-[1.15] contrast-[1.02]"
              />
              <div className="pointer-events-none absolute inset-x-0 bottom-0 h-24 bg-[linear-gradient(180deg,rgba(0,0,0,0)_0%,rgba(27,28,28,0.12)_100%)]" />
              <div className="pointer-events-none absolute inset-x-0 top-0 h-14 bg-[linear-gradient(180deg,rgba(251,249,248,0.14)_0%,rgba(251,249,248,0)_100%)]" />
              <div className="absolute bottom-4 left-4 rounded-lg bg-white/94 px-4 py-2 text-xs font-bold uppercase tracking-[0.22em] text-[var(--apx-on-surface-variant)] shadow-[0_10px_24px_rgba(27,28,28,0.08)] backdrop-blur">
                Cambridge Discovery District
              </div>
            </div>
          </div>

          <div className="lg:col-span-7">
            <div
              id="contact-form"
              className="ambient-shadow rounded-2xl bg-[var(--apx-surface-container-lowest)] p-8 sm:p-12"
            >
              <div className="mb-10">
                <h2 className="apx-font-headline mb-2 text-[44px] font-extrabold tracking-[-0.04em] text-[var(--apx-on-surface)]">
                  Send an Inquiry
                </h2>
                <p className="text-[var(--apx-on-surface-variant)]">
                  Our clinical team typically responds within 24 business hours.
                </p>
              </div>

              <form className="space-y-6">
                <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                  <Field label="Full Name">
                    <input
                      aria-label="Full Name"
                      type="text"
                      placeholder="Dr. Sarah Chen"
                      className="w-full rounded-xl border-none bg-[var(--apx-surface-container-high)] px-4 py-4 outline-none transition-all focus:bg-white focus:ring-2 focus:ring-[var(--apx-primary)]"
                    />
                  </Field>
                  <Field label="Work Email">
                    <input
                      aria-label="Work Email"
                      type="email"
                      placeholder="chen@medical-inst.org"
                      className="w-full rounded-xl border-none bg-[var(--apx-surface-container-high)] px-4 py-4 outline-none transition-all focus:bg-white focus:ring-2 focus:ring-[var(--apx-primary)]"
                    />
                  </Field>
                </div>

                <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                  <Field label="Phone Number">
                    <input
                      aria-label="Phone Number"
                      type="tel"
                      placeholder="+1 (000) 000-0000"
                      className="w-full rounded-xl border-none bg-[var(--apx-surface-container-high)] px-4 py-4 outline-none transition-all focus:bg-white focus:ring-2 focus:ring-[var(--apx-primary)]"
                    />
                  </Field>
                  <Field label="Country">
                    <div className="relative">
                      <select
                        aria-label="Country"
                        className="w-full appearance-none rounded-xl border-none bg-[var(--apx-surface-container-high)] px-4 py-4 pr-12 outline-none transition-all focus:bg-white focus:ring-2 focus:ring-[var(--apx-primary)]"
                      >
                        {COUNTRIES.map((country) => (
                          <option key={country}>{country}</option>
                        ))}
                      </select>
                      <ChevronDown className="pointer-events-none absolute right-4 top-1/2 h-5 w-5 -translate-y-1/2 text-[var(--apx-on-surface-variant)]" />
                    </div>
                  </Field>
                </div>

                <Field label="Message">
                  <textarea
                    aria-label="Message"
                    rows={5}
                    placeholder="Please describe the nature of your clinical or business inquiry..."
                    className="w-full resize-none rounded-xl border-none bg-[var(--apx-surface-container-high)] px-4 py-4 outline-none transition-all focus:bg-white focus:ring-2 focus:ring-[var(--apx-primary)]"
                  />
                </Field>

                <div className="pt-4">
                  <button
                    type="submit"
                    className="ambient-shadow flex w-full items-center justify-center gap-3 rounded-xl bg-gradient-to-r from-[var(--apx-primary)] to-[var(--apx-primary-container)] px-12 py-5 apx-font-headline text-base font-extrabold text-white transition-transform hover:scale-[1.02] md:w-auto"
                  >
                    Submit Message
                    <Send className="h-5 w-5" strokeWidth={2.4} />
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

function Field({
  label,
  children,
}: {
  label: string
  children: ReactNode
}) {
  return (
    <label className="block space-y-2">
      <span className="ml-1 block apx-font-headline text-[11px] font-bold uppercase tracking-[0.22em] text-[var(--apx-on-surface-variant)]">
        {label}
      </span>
      {children}
    </label>
  )
}
