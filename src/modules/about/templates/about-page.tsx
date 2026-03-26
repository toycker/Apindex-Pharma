import AboutGlobalFootprintSection from "@modules/about/sections/about-global-footprint-section"
import AboutHeroSection from "@modules/about/sections/about-hero-section"
import AboutIntroSection from "@modules/about/sections/about-intro-section"
import AboutPurposeSection from "@modules/about/sections/about-purpose-section"
import AboutQuoteSection from "@modules/about/sections/about-quote-section"
import AboutStatsSection from "@modules/about/sections/about-stats-section"
import AboutValidatedExcellenceSection from "@modules/about/sections/about-validated-excellence-section"
import FooterSection from "@modules/landing/sections/footer-section"
import TopNavBar from "@modules/landing/sections/top-nav-bar"

export default function AboutPageTemplate() {
  return (
    <div className="apx-landing apx-font-body bg-[var(--apx-surface)] text-[var(--apx-on-surface)]">
      <TopNavBar />
      <main className="!pb-0">
        <AboutHeroSection />
        <AboutIntroSection />
        <AboutStatsSection />
        <AboutPurposeSection />
        <AboutQuoteSection />
        <AboutGlobalFootprintSection />
        <AboutValidatedExcellenceSection />
      </main>
      <FooterSection />
    </div>
  )
}

