import CertificationsSection from "@modules/landing/sections/certifications-section"
import DosageFormsSection from "@modules/landing/sections/dosage-forms-section"
import FooterSection from "@modules/landing/sections/footer-section"
import GlobalPresenceSection from "@modules/landing/sections/global-presence-section"
import HeroSection from "@modules/landing/sections/hero-section"
import QualityCommitmentSection from "@modules/landing/sections/quality-commitment-section"
import ServicesSection from "@modules/landing/sections/services-section"
import TopNavBar from "@modules/landing/sections/top-nav-bar"

export default function LandingPageTemplate() {
  return (
    <div className="apx-landing apx-font-body bg-[var(--apx-surface)] text-[var(--apx-on-surface)]">
      <TopNavBar />
      <main className="!pb-0">
        <HeroSection />
        <DosageFormsSection />
        <ServicesSection />
        <GlobalPresenceSection />
        <QualityCommitmentSection />
        <CertificationsSection />
      </main>
      <FooterSection />
    </div>
  )
}
