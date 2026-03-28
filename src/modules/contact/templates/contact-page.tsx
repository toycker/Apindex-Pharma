import ContactContentSection from "@modules/contact/sections/contact-content-section"
import ContactHeroSection from "@modules/contact/sections/contact-hero-section"
export default function ContactPageTemplate() {
  return (
    <div className="apx-landing apx-font-body bg-surface text-on-surface">
      <main className="!pb-0">
        <ContactHeroSection />
        <ContactContentSection />
      </main>
    </div>
  )
}
