import ContactContentSection from "@modules/contact/sections/contact-content-section"
import ContactHeroSection from "@modules/contact/sections/contact-hero-section"
import FooterSection from "@modules/landing/sections/footer-section"
import TopNavBar from "@modules/landing/sections/top-nav-bar"

export default function ContactPageTemplate() {
  return (
    <div className="apx-landing apx-font-body bg-[var(--apx-surface)] text-[var(--apx-on-surface)]">
      <TopNavBar />
      <main className="!pb-0">
        <ContactHeroSection />
        <ContactContentSection />
      </main>
      <FooterSection />
    </div>
  )
}
