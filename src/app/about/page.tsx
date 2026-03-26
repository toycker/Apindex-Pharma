import type { Metadata } from "next"
import AboutPageTemplate from "@modules/about/templates/about-page"

export const metadata: Metadata = {
  title: "About",
  description:
    "Learn about Apindex Pharmaceuticals, its global footprint, quality systems, and commitment to precision-driven healthcare manufacturing.",
}

export default function AboutPage() {
  return <AboutPageTemplate />
}
