import Image from "next/image"
import { ShieldCheck } from "lucide-react"

const COMPLIANCE_LOGOS = [
  "https://lh3.googleusercontent.com/aida-public/AB6AXuCVPnj0aNTaPI3tJZQ2CewxA0qqDU2eHOtojlIl9yeRAzCtLXagXSbN5rKj7OLyaDdfk8feGFoFJr5dUE-n4P8qaknhHGEqBpTOnlIMhrnLo9u6pQJ6mhU0qtF8u__cjBLaqsSc6O85G19gEpa2aT2xhughGc0F4gAovlfEoISuZ8nhOe9WMzDLLibzIKPYfe_ifnVrmDo9uSp1wdq2kOq4LR2mnI0tKVEXi2IqEuLRYoFreZwbdbV8pxPdJgpuwmL92Rlq639-6WA",
  "https://lh3.googleusercontent.com/aida-public/AB6AXuAbd7RC1rHhIsE-6wn7l2sP6d9yckgbwVGwVtqI6ca92wDw25aJp44xa4RNtXk55VVcQfauchStBLQDRl11YhYPOy48AiIPtIO1XaSTFSajm8rNL4qRnvE5kdlaC5L308QyiQ8A3ZmUwCbOp9miCMHW8Fe9dKffKXHTvgpMUXQwae_RyykGAe1FnlGmY-Y_OKs9iBSdUjkyM_XRlHOH34p8Nmm-xT9iYXHwHB8OhoDU-BgCkU9A5P_OAs5N7JcDUBTuS7eJKCL4jxs",
]

export default function ContactComplianceSection() {
  return (
    <section className="border-y border-[color:rgb(221_193_176/0.1)] bg-[var(--apx-surface-container-low)] py-12">
      <div className="content-container flex flex-col items-center justify-between gap-8 opacity-70 md:flex-row">
        <div className="flex items-center gap-4">
          <ShieldCheck className="h-9 w-9 text-[var(--apx-secondary)]" strokeWidth={2.1} />
          <p className="text-sm leading-tight text-[var(--apx-on-surface-variant)]">
            Strict adherence to HIPAA,
            <br />
            GDPR, and WHO standards.
          </p>
        </div>

        <div className="flex items-center gap-12">
          {COMPLIANCE_LOGOS.map((logo, index) => (
            <div key={logo} className="relative h-8 w-28 grayscale">
              <Image
                fill
                sizes="112px"
                src={logo}
                alt={`Compliance mark ${index + 1}`}
                className="object-contain"
              />
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
