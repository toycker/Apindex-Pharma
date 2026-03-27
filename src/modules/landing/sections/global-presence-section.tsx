import Image from "next/image"

type GlobalStat = {
  value: string
  label: string
  tone: "primary" | "secondary"
}

const GLOBAL_MAP_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuBMNz_jUhspacjupHGXN9NyESzVjiNYyW1181AkmHNdM_zJQZfvbjDM0jyXE0FSiEgHRoRJFYtNH33bKIhf0f0zrMXmSjJ64IOQDY__U5hocGlByFF78fj5a3PKxjvNGTCiV6wz72Nlw-SbAT-6yUzOM5n7ItGoEvTlRJG1op3Wfgj88bBBSEaDop0zrUt2YT5BXkpB4nCYYI7oPFVI01dsQi7UAaNUiX309pFAkOw28YjH3UbwhixwDnzTlHlOwBfDKJE8jYMYeyI"

const GLOBAL_STATS: GlobalStat[] = [
  { value: "86+", label: "Countries Served", tone: "primary" },
  { value: "1250+", label: "Intl. Clients", tone: "secondary" },
  { value: "600+", label: "Sterile Products", tone: "primary" },
  { value: "900+", label: "Non-Sterile", tone: "secondary" },
]

const STAT_TONE_CLASS: Record<GlobalStat["tone"], string> = {
  primary: "text-[var(--apx-primary)]",
  secondary: "text-[var(--apx-secondary-container)]",
}

export default function GlobalPresenceSection() {
  return (
    <section
      id="global-presence"
      className="relative overflow-hidden bg-zinc-900 py-16 lg:py-24 text-white"
    >
      <div className="absolute inset-0 opacity-20">
        <Image
          fill
          sizes="100vw"
          src={GLOBAL_MAP_IMAGE_URL}
          alt="Stylized dark world map with luminous nodes connecting global major cities, representing an international pharmaceutical network"
          className="h-full w-full object-cover"
        />
      </div>

      <div className="relative z-10 mx-auto max-w-screen-2xl px-8">
        <div className="mb-20 text-center">
          <h2 className="apx-font-headline mb-4 text-4xl font-bold">A Global Network of Trust</h2>
          <p className="mx-auto max-w-xl text-zinc-400">
            Exporting excellence to every corner of the world, ensuring health is a
            universal right.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-12 text-center lg:grid-cols-4">
          {GLOBAL_STATS.map((stat) => (
            <div key={stat.label}>
              <div className={`mb-2 text-5xl font-extrabold ${STAT_TONE_CLASS[stat.tone]}`}>
                {stat.value}
              </div>
              <div className="text-xs font-bold uppercase tracking-widest text-zinc-400">
                {stat.label}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
